/**
 *Submitted for verification at Etherscan.io on 2020-11-01
*/

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.6.12;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */


/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


/**
 * @dev Collection of functions related to the address type
 */


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
abstract 

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
abstract contract Claimable is Ownable {
  address s_pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == s_pendingOwner, "Claimable: not pending owner");
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner override {
    s_pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(s_owner, s_pendingOwner);
    s_owner = s_pendingOwner;
    s_pendingOwner = address(0);
  }
}

struct Account {
    uint256 nonce;  
    uint256 balance;
    uint256 issueBlock;
    uint256 pending;
    uint256 withdrawal;
    uint256 releaseBlock;
    bytes32 secretHash;
}



struct Supply {
    uint256 total;
    uint256 minimum;
    uint256 pending;
}



struct Limits {
    uint256 releaseDelay;
    uint256 maxTokensPerIssue;
    uint256 maxTokensPerBlock;
}

struct Entities {
    address manager;
    address token;
    address wallet;
}

contract Pool is Claimable {
    using AccountUtils for Account;
    using SupplyUtils for Supply;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bytes32 private s_uid;
    Supply private s_supply;
    Limits private s_limits;
    Entities private s_entities;
    uint256 private s_lastIssuedBlock;
    uint256 private s_totalIssuedInBlock;

    mapping(address => Account) private s_accounts;

    uint8 public constant VERSION_NUMBER = 0x1;
    uint256 public constant MAX_RELEASE_DELAY = 11_520; // about 48h
    string public constant NAME = "Kirobo Pool";
    string public constant VERSION = "1";
    bytes32 public DOMAIN_SEPARATOR;
    bytes public DOMAIN_SEPARATOR_ASCII;
    uint256 public CHAIN_ID;

    // keccak256("acceptTokens(address recipient,uint256 value,bytes32 secretHash)");
    bytes32 public constant ACCEPT_TYPEHASH = 0xf728cfc064674dacd2ced2a03acd588dfd299d5e4716726c6d5ec364d16406eb;

    // keccak256("payment(address from,uint256 value,uint256 nonce)");
    bytes32 public constant PAYMENT_TYPEHASH = 0x841d82f71fa4558203bb763733f6b3326ecaf324143e12fb9b6a9ed958fc4ee0;

    // keccak256("buyTokens(address recipient,uint256 eth,uint256 kiro,uint256 expires)");
    bytes32 public constant BUY_TYPEHASH = 0x866880cdfbc2380b3f4581d70707601f3d190bc04c3ee9cfcdac070a5f87b758;

    event TokensIssued(address indexed account, uint256 value, bytes32 secretHash);
    event TokensAccepted(address indexed account, bool directCall);
    event TokensDistributed(address indexed account, uint256 value);
    event Payment(address indexed account, uint256 value);
    event Deposit(address indexed account, uint256 value);
    event WithdrawalRequested(address indexed account, uint256 value);
    event WithdrawalCanceled(address indexed account);
    event Withdrawal(address indexed account, uint256 value);
    event EtherTransfered(address indexed to, uint256 value);
    event TokensTransfered(address indexed to, uint256 value);
    event ManagerChanged(address from, address to);
    event WalletChanged(address from, address to);
    event ReleaseDelayChanged(uint256 from, uint256 to);
    event MaxTokensPerIssueChanged(uint256 from, uint256 to);
    event MaxTokensPerBlockChanged(uint256 from, uint256 to);

    modifier onlyAdmins() {
        require(msg.sender == s_owner || msg.sender == s_entities.manager, "Pool: not owner or manager");
        _;
    }

    constructor(address tokenContract) public {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
     
        s_entities.token = tokenContract;
        s_limits = Limits({releaseDelay: 240, maxTokensPerIssue: 10*1000*(10**18), maxTokensPerBlock: 50*1000*(10**18)});
        s_uid = bytes32(
          uint256(VERSION_NUMBER) << 248 |
          uint256(blockhash(block.number-1)) << 192 >> 16 |
          uint256(address(this))
        );

        CHAIN_ID = chainId;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"),
                keccak256(bytes(NAME)),
                keccak256(bytes(VERSION)),
                chainId,
                address(this),
                s_uid
            )
        );
        DOMAIN_SEPARATOR_ASCII = _hashToAscii(
            DOMAIN_SEPARATOR
        );
    }

    receive () external payable {
        require(false, "Pool: not accepting ether");
    }


    // ----------- Owner Functions ------------


    function setManager(address manager) external onlyOwner() {
        require(manager != address(this), "Pool: self cannot be mananger");
        require(manager != s_entities.token, "Pool: token cannot be manager");
        emit ManagerChanged(s_entities.manager, manager);
        s_entities.manager = manager;
    }

    function setWallet(address wallet) external onlyOwner() {
        require(wallet != address(this), "Pool: self cannot be wallet");
        require(wallet != s_entities.token, "Pool: token cannot be wallt");
        emit WalletChanged(s_entities.wallet, wallet);
        s_entities.wallet = wallet;
    }

    function setReleaseDelay(uint256 blocks) external onlyOwner() {
        require(blocks <= MAX_RELEASE_DELAY, "Pool: exeeds max release delay");
        emit ReleaseDelayChanged(s_limits.releaseDelay, blocks);
        s_limits.releaseDelay = blocks;
    }

    function setMaxTokensPerIssue(uint256 tokens) external onlyOwner() {
        emit MaxTokensPerIssueChanged(s_limits.maxTokensPerIssue, tokens);
        s_limits.maxTokensPerIssue = tokens;
    }

    function setMaxTokensPerBlock(uint256 tokens) external onlyOwner() {
        emit MaxTokensPerBlockChanged(s_limits.maxTokensPerBlock, tokens);
        s_limits.maxTokensPerBlock = tokens;
    }

    function resyncTotalSupply(uint256 value) external onlyAdmins() returns (uint256) {
        uint256 tokens = ownedTokens();
        require(tokens >= s_supply.total, "Pool: internal error, check contract logic"); 
        require(value >= s_supply.total, "Pool: only transferTokens can decrease total supply");
        require(value <= tokens, "Pool: not enough tokens");
        s_supply.update(value);
    }


    // ----------- Admins Functions ------------


    function transferEther(uint256 value) external onlyAdmins() {
        require(s_entities.wallet != address(0), "Pool: wallet not set");
        payable(s_entities.wallet).transfer(value);
        emit EtherTransfered(s_entities.wallet, value);
    }

    function transferTokens(uint256 value) external onlyAdmins() {
        require(s_entities.wallet != address(0), "Pool: wallet not set");
        s_supply.decrease(value);
        IERC20(s_entities.token).safeTransfer(s_entities.wallet, value);
        emit TokensTransfered(s_entities.wallet, value);
    }

    function distributeTokens(address to, uint256 value) external onlyAdmins() {
        _distributeTokens(to, value);
    }
    
    function _distributeTokens(address to, uint256 value) private {
        require(value <= s_limits.maxTokensPerIssue, "Pool: exeeds max tokens per call");
        require(s_accounts[to].issueBlock < block.number, "Pool: too soon");
        _validateTokensPerBlock(value);
        Account storage sp_account = s_accounts[to];
        sp_account.issueBlock = block.number;
        sp_account.initNonce();
        s_supply.give(value);
        sp_account.take(value);
        emit TokensDistributed(to, value);
    }

    /**
     * @dev Issueing tokens for an address to be used for payments.
     * The owner of the receiving address must accept via a signed message or a direct call.
     * @param to The tokens recipient. 
     * @param value The number of tokens to issue.
     * @param secretHash The keccak256 of the confirmation secret.
    */
    function issueTokens(address to, uint256 value, bytes32 secretHash) external onlyAdmins() {
        require(value <= s_limits.maxTokensPerIssue, "Pool: exeeds max tokens per call");
        _validateTokensPerBlock(value);
        Account storage sp_account = s_accounts[to];
        uint256 prevPending = sp_account.pending;
        sp_account.initNonce();
        sp_account.secretHash = secretHash;
        sp_account.pending = value;
        sp_account.issueBlock = block.number;
        s_supply.updatePending(prevPending, value);
        emit TokensIssued(to, value, secretHash);
    }

    function executeAcceptTokens(
        address recipient,
        uint256 value,
        bytes calldata c_secret,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bool eip712
    )
        external 
        onlyAdmins()
    {
        require(s_accounts[recipient].secretHash == keccak256(c_secret), "Pool: wrong secret");
        require(
            validateAcceptTokens(recipient, value, keccak256(c_secret), v, r ,s, eip712),
            "Pool: wrong signature or data"
        );
        _acceptTokens(recipient, value);
        emit TokensAccepted(recipient, false);
    }

    function executePayment(address from, uint256 value, uint8 v, bytes32 r, bytes32 s, bool eip712)
        external
        onlyAdmins()
    {
        require(validatePayment(from, value, v, r, s, eip712), "Pool: wrong signature or data");
        Account storage sp_account = s_accounts[from];
        sp_account.updateNonce();
        sp_account.payment(value);
        s_supply.payment(value);
        emit Payment(from, value);
    }
  

    // ----------- External Functions ------------


    function executeBuyTokens(uint256 kiro, uint256 expires, uint8 v, bytes32 r, bytes32 s, bool eip712) 
        external
        payable
    {
        require(validateBuyTokens(msg.sender, msg.value, kiro, expires, v, r, s, eip712), "Pool: wrong signature or data");
        require(now <= expires, "Pool: too late");
        _distributeTokens(msg.sender, kiro);
    }

    function acceptTokens(uint256 value, bytes calldata c_secret) external {
        require(s_accounts[msg.sender].secretHash == keccak256(c_secret), "Pool: wrong secret");
        _acceptTokens(msg.sender, value);
        emit TokensAccepted(msg.sender, true);
    }

    function depositTokens(uint256 value) external {
        // require(
        //     IERC20(s_entities.token).allowance(msg.sender, address(this)) >= value,
        //    "IERC20 allowance too low"
        // );
        Account storage sp_account = s_accounts[msg.sender]; 
        sp_account.initNonce();
        sp_account.deposit(value);
        s_supply.deposit(value);
        IERC20(s_entities.token).safeTransferFrom(msg.sender, address(this), value);
        emit Deposit(msg.sender, value);
    }

    function requestWithdrawal(uint256 value) external {
        require(s_accounts[msg.sender].balance >= value, "Pool: not enough tokens");
        require(value > 0, "Pool: withdrawal value must be larger then 0");
        s_accounts[msg.sender].withdrawal = value;
        s_accounts[msg.sender].releaseBlock = block.number + s_limits.releaseDelay;
        emit WithdrawalRequested(msg.sender, value);
    }

    function cancelWithdrawal() external {
        s_accounts[msg.sender].withdrawal = 0;
        s_accounts[msg.sender].releaseBlock = 0;
        emit WithdrawalCanceled(msg.sender);
    }

    function withdrawTokens() external {
        Account storage sp_account = s_accounts[msg.sender];   
        require(sp_account.withdrawal > 0, "Pool: no withdraw request");
        require(sp_account.releaseBlock <= block.number, "Pool: too soon");
        uint256 value = sp_account.withdrawal > sp_account.balance ? sp_account.balance : sp_account.withdrawal;
        sp_account.withdraw(value);
        s_supply.widthdraw(value);
        IERC20(s_entities.token).safeTransfer(msg.sender, value);
        emit Withdrawal(msg.sender, value);
    }

    function account(address addr) external view
        returns (
            uint256 nonce,  
            uint256 balance,
            uint256 issueBlock,
            uint256 pending,
            uint256 withdrawal,
            uint256 releaseBlock,
            bytes32 secretHash,
            uint256 externalBalance
        ) 
    {
        Account storage sp_account = s_accounts[addr];
        uint256 extBalance = IERC20(s_entities.token).balanceOf(addr);
        return (
            sp_account.nonce,
            sp_account.balance,
            sp_account.issueBlock,
            sp_account.pending,
            sp_account.withdrawal,
            sp_account.releaseBlock,
            sp_account.secretHash,
            extBalance
        );
    }

    function entities() view external
        returns (
            address manager,
            address token,
            address wallet
        )
    {
        return (
            s_entities.manager,
            s_entities.token,
            s_entities.wallet
        );
    }

    function limits() external view
        returns (
            uint256 releaseDelay, 
            uint256 maxTokensPerIssue,
            uint256 maxTokensPerBlock
        )
    {
        return (
            s_limits.releaseDelay,
            s_limits.maxTokensPerIssue,
            s_limits.maxTokensPerBlock
        );
    }

    function supply() view external 
        returns (
            uint256 total,
            uint256 minimum,
            uint256 pending,
            uint256 available
        ) 
    {
        return (
            s_supply.total,
            s_supply.minimum,
            s_supply.pending,
            s_supply.available()
        );
    }

    function uid() view external returns (bytes32) {
        return s_uid;
    }

    function totalSupply() view external returns (uint256) {
        return s_supply.total;
    }

    function availableSupply() view external returns (uint256) {
        return s_supply.available();
    }


    // ----------- Public Functions ------------


    function generateBuyTokensMessage(address recipient, uint256 eth, uint256 kiro, uint256 expires)
        public view
        returns (bytes memory)
    {
        Account storage sp_account = s_accounts[recipient]; 
    
        return abi.encode(
            BUY_TYPEHASH,
            recipient,
            eth,
            kiro,
            expires,
            sp_account.issueBlock
        );
    }

    function generateAcceptTokensMessage(address recipient, uint256 value, bytes32 secretHash)
        public view 
        returns (bytes memory)
    {
        require(s_accounts[recipient].secretHash == secretHash, "Pool: wrong secret hash");
        require(s_accounts[recipient].pending == value, "Pool: value must equal pending(issued tokens)");
            
        return abi.encode(
            ACCEPT_TYPEHASH,
            recipient,
            value,
            secretHash
        );
    }

    function generatePaymentMessage(address from, uint256 value)
        public view
        returns (bytes memory)
    {
        Account storage sp_account = s_accounts[from]; 
        require(sp_account.balance >= value, "Pool: account balnace too low");
        
        return abi.encode(
            PAYMENT_TYPEHASH,
            from,
            value,
            sp_account.nonce
        );
    }

    function validateBuyTokens(
        address from,
        uint256 eth,
        uint256 kiro,
        uint256 expires,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bool eip712
    )
        public view 
        returns (bool)
    {
        bytes32 message = _messageToRecover(
            keccak256(generateBuyTokensMessage(from, eth, kiro, expires)),
            eip712
        );
        address addr = ecrecover(message, v, r, s);
        return addr == s_entities.manager;      
    }

    function validateAcceptTokens(
        address recipient,
        uint256 value,
        bytes32 secretHash,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bool eip712
    )
        public view 
        returns (bool)
    {
        bytes32 message = _messageToRecover(
            keccak256(generateAcceptTokensMessage(recipient, value, secretHash)),
            eip712
        );
        address addr = ecrecover(message, v, r, s);
        return addr == recipient;
    }

    function validatePayment(address from, uint256 value, uint8 v, bytes32 r, bytes32 s, bool eip712)
        public view 
        returns (bool)
    {
        bytes32 message = _messageToRecover(
            keccak256(generatePaymentMessage(from, value)),
            eip712
        );
        address addr = ecrecover(message, v, r, s);
        return addr == from;      
    }

    function ownedTokens() view public returns (uint256) {
        return IERC20(s_entities.token).balanceOf(address(this));
    }


    // ----------- Private Functions ------------


    function _validateTokensPerBlock(uint256 value) private {
        if (s_lastIssuedBlock < block.number) {
            s_lastIssuedBlock = block.number;
            s_totalIssuedInBlock = value;
        } else {
            s_totalIssuedInBlock.add(value);
        }
        require(s_totalIssuedInBlock <= s_limits.maxTokensPerBlock, "Pool: exeeds max tokens per block");
    }

    function _acceptTokens(address recipient, uint256 value) private {
        require(s_accounts[recipient].issueBlock < block.number, "Pool: too soon");
        s_accounts[recipient].acceptPending(value);
        s_supply.acceptPending(value);
    }

    function _messageToRecover(bytes32 hashedUnsignedMessage, bool eip712)
        private view 
        returns (bytes32)
    {
        if (eip712) {
            return keccak256(abi.encodePacked
            (
                "\x19\x01",
                DOMAIN_SEPARATOR,
                hashedUnsignedMessage
            ));
        }
        return keccak256(abi.encodePacked
        (
            "\x19Ethereum Signed Message:\n128",
            DOMAIN_SEPARATOR_ASCII,
            _hashToAscii(hashedUnsignedMessage)
        ));
    }

    function _hashToAscii(bytes32 hash) private pure returns (bytes memory) {
        bytes memory s = new bytes(64);
        for (uint i = 0; i < 32; i++) {
            byte  b = hash[i];
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = _char(hi);
            s[2*i+1] = _char(lo);
        }
        return s;
    }

    function _char(byte b) private pure returns (byte c) {
        if (b < byte(uint8(10))) {
            return byte(uint8(b) + 0x30);
        } else {
            return byte(uint8(b) + 0x57);
        }
    }

}