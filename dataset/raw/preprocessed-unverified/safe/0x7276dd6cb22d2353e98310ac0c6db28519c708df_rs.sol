/**
 *Submitted for verification at Etherscan.io on 2019-12-10
*/

pragma solidity 0.5.9;


/**
 * @dev Collection of functions related to the address type,
 */



/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */



// @title Kyber Network interface



contract PermissionGroups {

    address public admin;
    address public pendingAdmin;
    mapping(address=>bool) public operators;
    mapping(address=>bool) public alerters;

    constructor(address _admin) public {
        admin = _admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    modifier onlyOperator() {
        require(operators[msg.sender]);
        _;
    }

    modifier onlyAlerter() {
        require(alerters[msg.sender]);
        _;
    }

    event TransferAdminPending(address pendingAdmin);

    /**
     * @dev Allows the current admin to set the pendingAdmin address.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        emit TransferAdminPending(pendingAdmin);
        pendingAdmin = newAdmin;
    }

    /**
     * @dev Allows the current admin to set the admin in one tx. Useful initial deployment.
     * @param newAdmin The address to transfer ownership to.
     */
    function transferAdminQuickly(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0));
        emit TransferAdminPending(newAdmin);
        emit AdminClaimed(newAdmin, admin);
        admin = newAdmin;
    }

    event AdminClaimed( address newAdmin, address previousAdmin);

    /**
     * @dev Allows the pendingAdmin address to finalize the change admin process.
     */
    function claimAdmin() public {
        require(pendingAdmin == msg.sender);
        emit AdminClaimed(pendingAdmin, admin);
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    event AlerterAdded (address newAlerter, bool isAdd);

    function addAlerter(address newAlerter) public onlyAdmin {
        require(!alerters[newAlerter]); // prevent duplicates.
        alerters[newAlerter] = true;
        emit AlerterAdded(newAlerter, true);
    }

    function removeAlerter (address alerter) public onlyAdmin {
        require(alerters[alerter]);
        alerters[alerter] = false;
        emit AlerterAdded(alerter, false);
    }

    event OperatorAdded(address newOperator, bool isAdd);

    function addOperator(address newOperator) public onlyAdmin {
        require(!operators[newOperator]); // prevent duplicates.
        operators[newOperator] = true;
        emit OperatorAdded(newOperator, true);
    }

    function removeOperator (address operator) public onlyAdmin {
        require(operators[operator]);
        operators[operator] = false;
        emit OperatorAdded(operator, false);
    }
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */



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




// File: contracts/Utils.sol

/// @title Kyber constants contract
contract Utils {

   ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
   uint  constant internal PRECISION = (10**18);
   uint  constant internal MAX_QTY   = (10**28); // 10B tokens
   uint  constant internal MAX_RATE  = (PRECISION * 10**6); // up to 1M tokens per ETH
   uint  constant internal MAX_DECIMALS = 18;
   uint  constant internal ETH_DECIMALS = 18;
   mapping(address=>uint) internal decimals;

   function setDecimals(ERC20 token) internal {
       if (token == ETH_TOKEN_ADDRESS) decimals[address(token)] = ETH_DECIMALS;
       else decimals[address(token)] = token.decimals();
   }

   function getDecimals(ERC20 token) internal view returns(uint) {
       if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
       uint tokenDecimals = decimals[address(token)];
       // technically, there might be token with decimals 0
       // moreover, very possible that old tokens have decimals 0
       // these tokens will just have higher gas fees.
       if(tokenDecimals == 0) return token.decimals();

       return tokenDecimals;
   }

   function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
       require(srcQty <= MAX_QTY);
       require(rate <= MAX_RATE);

       if (dstDecimals >= srcDecimals) {
           require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
           return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
       } else {
           require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
           return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
       }
   }

   function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
       require(dstQty <= MAX_QTY);
       require(rate <= MAX_RATE);

       //source quantity is rounded up. to avoid dest quantity being too low.
       uint numerator;
       uint denominator;
       if (srcDecimals >= dstDecimals) {
           require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
           numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
           denominator = rate;
       } else {
           require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
           numerator = (PRECISION * dstQty);
           denominator = (rate * (10**(dstDecimals - srcDecimals)));
       }
       return (numerator + denominator - 1) / denominator; //avoid rounding down errors
   }
}

// File: contracts/Utils2.sol

contract Utils2 is Utils {

   /// @dev get the balance of a user.
   /// @param token The token type
   /// @return The balance
   function getBalance(ERC20 token, address user) public view returns(uint) {
       if (token == ETH_TOKEN_ADDRESS)
           return user.balance;
       else
           return token.balanceOf(user);
   }

   function getDecimalsSafe(ERC20 token) internal returns(uint) {

       if (decimals[address(token)] == 0) {
           setDecimals(token);
       }

       return decimals[address(token)];
   }

   function calcDestAmount(ERC20 src, ERC20 dest, uint srcAmount, uint rate) internal view returns(uint) {
       return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
   }

   function calcSrcAmount(ERC20 src, ERC20 dest, uint destAmount, uint rate) internal view returns(uint) {
       return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
   }

   function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)
       internal pure returns(uint)
   {
       require(srcAmount <= MAX_QTY);
       require(destAmount <= MAX_QTY);

       if (dstDecimals >= srcDecimals) {
           require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
           return (destAmount * PRECISION / ((10 ** (dstDecimals - srcDecimals)) * srcAmount));
       } else {
           require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
           return (destAmount * PRECISION * (10 ** (srcDecimals - dstDecimals)) / srcAmount);
       }
   }
}


/**
 * @title Contracts that should be able to recover tokens or ethers can inherit this contract.
 * @author Ilan Doron
 * @dev Allows to recover any tokens or Ethers received in a contract.
 * Should prevent any accidental loss of tokens.
 */
contract Withdrawable is PermissionGroups {
    using SafeERC20 for ERC20;
    constructor(address _admin) public PermissionGroups (_admin) {}

    event TokenWithdraw(ERC20 token, uint amount, address sendTo);

    /**
     * @dev Withdraw all ERC20 compatible tokens
     * @param token ERC20 The address of the token contract
     */
    function withdrawToken(ERC20 token, uint amount, address sendTo) external onlyAdmin {
        token.safeTransfer(sendTo, amount);
        emit TokenWithdraw(token, amount, sendTo);
    }

    event EtherWithdraw(uint amount, address sendTo);

    /**
     * @dev Withdraw Ethers
     */
    function withdrawEther(uint amount, address payable sendTo) external onlyAdmin {
        sendTo.transfer(amount);
        emit EtherWithdraw(amount, sendTo);
    }
}


contract KyberSwapLimitOrder is Withdrawable {

    //userAddress => concatenated token addresses => nonce
    mapping(address => mapping(uint256 => uint256)) public nonces;
    bool public tradeEnabled;
    KyberNetworkProxyInterface public kyberNetworkProxy;
    uint256 public constant MAX_DEST_AMOUNT = 2 ** 256 - 1;
    uint256 public constant PRECISION = 10**4;
    using SafeMath for uint256;
    using SafeERC20 for ERC20;

    //Constructor
    constructor(
        address _admin,
        KyberNetworkProxyInterface _kyberNetworkProxy
    )
        public
        Withdrawable(_admin) {
            require(_admin != address(0));
            require(address(_kyberNetworkProxy) != address(0));

            kyberNetworkProxy = _kyberNetworkProxy;
        }

    event TradeEnabled(bool tradeEnabled);

    function enableTrade() external onlyAdmin {
        tradeEnabled = true;
        emit TradeEnabled(tradeEnabled);
    }

    function disableTrade() external onlyAdmin {
        tradeEnabled = false;
        emit TradeEnabled(tradeEnabled);
    }

    function listToken(ERC20 token)
        external
        onlyAdmin
    {
        require(address(token) != address(0));
        /*
        No need to set allowance to zero first, as there's only 1 scenario here (from zero to max allowance).
        No one else can set allowance on behalf of this contract to Kyber.
        */
        token.safeApprove(address(kyberNetworkProxy), MAX_DEST_AMOUNT);
    }

    struct VerifyParams {
        address user;
        uint8 v;
        uint256 concatenatedTokenAddresses;
        uint256 nonce;
        bytes32 hashedParams;
        bytes32 r;
        bytes32 s;
    }

    struct TradeInput {
        ERC20 srcToken;
        uint256 srcQty;
        ERC20 destToken;
        address payable destAddress;
        uint256 minConversionRate;
        uint256 feeInPrecision;
    }

    event LimitOrderExecute(address indexed user, uint256 nonce, address indexed srcToken,
        uint256 actualSrcQty, uint256 destAmount, address indexed destToken,
        address destAddress, uint256 feeInSrcTokenWei);

    function executeLimitOrder(
        address user,
        uint256 nonce,
        ERC20 srcToken,
        uint256 srcQty,
        ERC20 destToken,
        address payable destAddress,
        uint256 minConversionRate,
        uint256 feeInPrecision,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        onlyOperator
        external
    {
        require(tradeEnabled);

        VerifyParams memory verifyParams;
        verifyParams.user = user;
        verifyParams.concatenatedTokenAddresses = concatTokenAddresses(address(srcToken), address(destToken));
        verifyParams.nonce = nonce;
        verifyParams.hashedParams = keccak256(abi.encodePacked(
            user, nonce, srcToken, srcQty, destToken, destAddress, minConversionRate, feeInPrecision));
        verifyParams.v = v;
        verifyParams.r = r;
        verifyParams.s = s;
        require(verifyTradeParams(verifyParams));

        TradeInput memory tradeInput;
        tradeInput.srcToken = srcToken;
        tradeInput.srcQty = srcQty;
        tradeInput.destToken = destToken;
        tradeInput.destAddress = destAddress;
        tradeInput.minConversionRate = minConversionRate;
        tradeInput.feeInPrecision = feeInPrecision;
        trade(tradeInput, verifyParams);
    }

    event OldOrdersInvalidated(address user, uint256 concatenatedTokenAddresses, uint256 nonce);

    function invalidateOldOrders(uint256 concatenatedTokenAddresses, uint256 nonce) external {
        require(validAddressInNonce(nonce));
        require(isValidNonce(msg.sender, concatenatedTokenAddresses, nonce));
        updateNonce(msg.sender, concatenatedTokenAddresses, nonce);
        emit OldOrdersInvalidated(msg.sender, concatenatedTokenAddresses, nonce);
    }

    function concatTokenAddresses(address srcToken, address destToken) public pure returns (uint256) {
        return ((uint256(srcToken) >> 32) << 128) + (uint256(destToken) >> 32);
    }

    function validAddressInNonce(uint256 nonce) public view returns (bool) {
        //check that first 16 bytes in nonce corresponds to first 16 bytes of contract address
        return (nonce >> 128) == (uint256(address(this)) >> 32);
    }

    function isValidNonce(address user, uint256 concatenatedTokenAddresses, uint256 nonce) public view returns (bool) {
        return nonce > nonces[user][concatenatedTokenAddresses];
    }

    function verifySignature(bytes32 hash, uint8 v, bytes32 r, bytes32 s, address user) public pure returns (bool) {
        //Users have to sign the message using wallets (Trezor, Ledger, Geth)
        //These wallets prepend a prefix to the data to prevent some malicious signing scheme
        //Eg. website that tries to trick users to sign an Ethereum message
        //https://ethereum.stackexchange.com/questions/15364/ecrecover-from-geth-and-web3-eth-sign
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
        return ecrecover(prefixedHash, v, r, s) == user;
    }

    //used SafeMath lib
    function deductFee(uint256 srcQty, uint256 feeInPrecision) public pure returns
    (uint256 actualSrcQty, uint256 feeInSrcTokenWei) {
        require(feeInPrecision <= 100 * PRECISION);
        feeInSrcTokenWei = srcQty.mul(feeInPrecision).div(100 * PRECISION);
        actualSrcQty = srcQty.sub(feeInSrcTokenWei);
    }

    event NonceUpdated(address user, uint256 concatenatedTokenAddresses, uint256 nonce);

    function updateNonce(address user, uint256 concatenatedTokenAddresses, uint256 nonce) internal {
        nonces[user][concatenatedTokenAddresses] = nonce;
        emit NonceUpdated(user, concatenatedTokenAddresses, nonce);
    }

    function verifyTradeParams(VerifyParams memory verifyParams) internal view returns (bool) {
        require(validAddressInNonce(verifyParams.nonce));
        require(isValidNonce(verifyParams.user, verifyParams.concatenatedTokenAddresses, verifyParams.nonce));
        require(verifySignature(
            verifyParams.hashedParams,
            verifyParams.v,
            verifyParams.r,
            verifyParams.s,
            verifyParams.user
            ));
        return true;
    }

    function trade(TradeInput memory tradeInput, VerifyParams memory verifyParams) internal {
        tradeInput.srcToken.safeTransferFrom(verifyParams.user, address(this), tradeInput.srcQty);
        uint256 actualSrcQty;
        uint256 feeInSrcTokenWei;
        (actualSrcQty, feeInSrcTokenWei) = deductFee(tradeInput.srcQty, tradeInput.feeInPrecision);

        updateNonce(verifyParams.user, verifyParams.concatenatedTokenAddresses, verifyParams.nonce);
        uint256 destAmount = kyberNetworkProxy.tradeWithHint(
            tradeInput.srcToken,
            actualSrcQty,
            tradeInput.destToken,
            tradeInput.destAddress,
            MAX_DEST_AMOUNT,
            tradeInput.minConversionRate,
            address(this), //walletId
            "PERM" //hint: only Permissioned reserves to be used
        );

        emit LimitOrderExecute(
            verifyParams.user,
            verifyParams.nonce,
            address(tradeInput.srcToken),
            actualSrcQty,
            destAmount,
            address(tradeInput.destToken),
            tradeInput.destAddress,
            feeInSrcTokenWei
        );
    }
}


contract MonitorHelper is Utils2, PermissionGroups, Withdrawable {
    KyberSwapLimitOrder public ksContract;
    KyberNetworkProxyInterface public kyberProxy;
    uint public slippageRate = 300; // 3%

    constructor(KyberSwapLimitOrder _ksContract, KyberNetworkProxyInterface _kyberProxy) public Withdrawable(msg.sender) {
        ksContract = _ksContract;
        kyberProxy = _kyberProxy;
    }

    function setKSContract(KyberSwapLimitOrder _ksContract) public onlyAdmin {
        ksContract = _ksContract;
    }

    function setKyberProxy(KyberNetworkProxyInterface _kyberProxy) public onlyAdmin {
        kyberProxy = _kyberProxy;
    }

    function setSlippageRate(uint _slippageRate) public onlyAdmin {
        slippageRate = _slippageRate;
    }

    function getNonces(address []memory users, uint256[] memory concatenatedTokenAddresses)
    public view
    returns (uint256[] memory nonces) {
        require(users.length == concatenatedTokenAddresses.length);
        nonces = new uint256[](users.length);
        for(uint i=0; i< users.length; i ++) {
            nonces[i]= ksContract.nonces(users[i],concatenatedTokenAddresses[i]);
        }
        return (nonces);
    }

    function getNonceFromKS(address user, uint256 concatenatedTokenAddress)
    public view
    returns (uint256 nonces) {
        nonces = ksContract.nonces(user, concatenatedTokenAddress);
        return nonces;
    }

    function getBalancesAndAllowances(address[] memory wallets, ERC20[] memory tokens)
    public view
    returns (uint[] memory balances, uint[] memory allowances) {
        require(wallets.length == tokens.length);
        balances = new uint[](wallets.length);
        allowances = new uint[](wallets.length);
        for(uint i = 0; i < wallets.length; i++) {
            balances[i] = tokens[i].balanceOf(wallets[i]);
            allowances[i] = tokens[i].allowance(wallets[i], address(ksContract));
        }
        return (balances, allowances);
    }

    function getBalances(address[] memory wallets, ERC20[] memory tokens)
    public view
    returns (uint[] memory balances) {
        require(wallets.length == tokens.length);
        balances = new uint[](wallets.length);
        for(uint i = 0; i < wallets.length; i++) {
            balances[i] = tokens[i].balanceOf(wallets[i]);
        }
        return balances;
    }

    function getBalancesSingleWallet(address wallet, ERC20[] memory tokens)
    public view
    returns (uint[] memory balances) {
        balances = new uint[](tokens.length);
        for(uint i = 0; i < tokens.length; i++) {
            balances[i] = tokens[i].balanceOf(wallet);
        }
        return balances;
    }

    function getAllowances(address[] memory wallets, ERC20[] memory tokens)
    public view
    returns (uint[] memory allowances) {
        require(wallets.length == tokens.length);
        allowances = new uint[](wallets.length);
        for(uint i = 0; i < wallets.length; i++) {
            allowances[i] = tokens[i].allowance(wallets[i], address(ksContract));
        }
        return allowances;
    }

    function getAllowancesSingleWallet(address wallet, ERC20[] memory tokens)
    public view
    returns (uint[] memory allowances) {
        allowances = new uint[](tokens.length);
        for(uint i = 0; i < tokens.length; i++) {
            allowances[i] = tokens[i].allowance(wallet, address(ksContract));
        }
        return allowances;
    }

    function checkOrdersExecutable(
        address[] memory senders, ERC20[] memory srcs,
        uint[] memory srcAmounts, ERC20[] memory dests,
        uint[] memory rates, uint[] memory nonces
    )
    public view
    returns (bool[] memory executables) {
        require(senders.length == srcs.length);
        require(senders.length == dests.length);
        require(senders.length == srcAmounts.length);
        require(senders.length == rates.length);
        require(senders.length == nonces.length);
        executables = new bool[](senders.length);
        bool isOK = true;
        uint curRate = 0;
        uint allowance = 0;
        uint balance = 0;
        for(uint i = 0; i < senders.length; i++) {
            isOK = true;
            balance = srcs[i].balanceOf(senders[i]);
            if (balance < srcAmounts[i]) { isOK = false; }
            if (isOK) {
                allowance = srcs[i].allowance(senders[i], address(ksContract));
                if (allowance < srcAmounts[i]) { isOK = false; }
            }
            if (isOK && address(ksContract) != address(0)) {
                isOK = ksContract.validAddressInNonce(nonces[i]);
                if (isOK) {
                    uint concatTokenAddresses = ksContract.concatTokenAddresses(address(srcs[i]), address(dests[i]));
                    isOK = ksContract.isValidNonce(senders[i], concatTokenAddresses, nonces[i]);
                }
            }
            if (isOK) {
                curRate = assemblyGetExpectedRate(srcs[i], dests[i], srcAmounts[i]);
                if (curRate * 10000 < rates[i] * (10000 + slippageRate)) { isOK = false; }
            }
            executables[i] = isOK;
        }
        return executables;
    }

    function assemblyGetExpectedRate(ERC20 src, ERC20 dest, uint srcQty)
        public view
        returns (uint rate)
    {
        bytes4 sig = bytes4(keccak256("getExpectedRate(address,address,uint256)"));
        address addr = address(kyberProxy);  // kyber proxy
        uint success;

        assembly {
            let x := mload(0x40)        // "free memory pointer"
            mstore(x,sig)               // function signature
            mstore(add(x,0x04),src)     // src address padded to 32 bytes
            mstore(add(x,0x24),dest)    // dest padded to 32 bytes
            mstore(add(x,0x44),srcQty)  // uint 32 bytes
            mstore(0x40,add(x,0xa4))    // set free storage pointer to empty space after output

            // input size = sig + ERC20 (address) + ERC20 + uint
            // = 4 + 32 + 32 + 32 = 100 = 0x64
            success := staticcall(
                gas,  // gas
                addr, // Kyber addr
                x,    // Inputs at location x
                0x64, // Inputs size bytes
                add(x, 0x64),    // output storage after input
                0x40) // Output size are (uint, uint) = 64 bytes

            rate := mload(add(x,0x64))  //Assign first output to rate, second output not used,
            mstore(0x40,x)    // Set empty storage pointer back to start position
        }
        if (success != 1) { rate = 0; }
    }
}