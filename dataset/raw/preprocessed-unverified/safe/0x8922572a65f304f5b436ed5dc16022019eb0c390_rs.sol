/**
 *Submitted for verification at Etherscan.io on 2021-09-14
*/

/**
 *Submitted for verification at Etherscan.io on 2021-09-14
*/

// SPDX-License-Identifier: No License (None)
pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.0.0, only sets of type `address` (`AddressSet`) and `uint256`
 * (`UintSet`) are supported.
 */


abstract 




contract TokenVault {
    
    address public owner;
    address public reimbursementToken;
    address public factory;
    
    
    constructor(address _owner,address _token) {
        owner = _owner;
        reimbursementToken = _token;
        factory = msg.sender;
    }
    
    function transferToken(address to, uint256 amount) external {
        require(msg.sender == factory,"caller should be factory");
        safeTransfer(reimbursementToken, to, amount);
    }

    // vault owner can withdraw unreserved tokens
    function withdrawTokens(uint256 amount) external {
        require(msg.sender == owner, "caller should be owner");
        uint256 available = Reimbursement(factory).getAvailableTokens(address(this));
        require(available >= amount, "not enough available tokens");
        safeTransfer(reimbursementToken, msg.sender, amount);
    }

    // allow owner to withdraw third-party tokens from contract address
    function rescueTokens(address someToken) external {
        require(msg.sender == owner, "caller should be owner");
        require(someToken != reimbursementToken, "Only third-party token");
        uint256 available = IBEP20(someToken).balanceOf(address(this));
        safeTransfer(someToken, msg.sender, available);
    }
    
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

}

contract Reimbursement is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Stake {
        uint256 startTime;  // stake start at timestamp
        uint256 amount;     // staked tokens amount
    }

    struct Setting {
        address token;  // reimbursement token
        bool isMintable; // token can be minted by this contract
        address owner;  // owner of reimbursement vault
        uint64 period;  // staking period in seconds (365 days)
        uint32 reimbursementRatio;     // the ratio of deposited amount to reimbursement amount (with 2 decimals)
        IUniswapV2Pair swapPair;   // uniswap compatible pair for token and native coin (ETH, BNB)
        bool isReversOrder; // if `true` then `token1 = token` otherwise `token0 = token`
    }

    mapping(address => Setting) public settings; // vault address (licensee address) => setting
    mapping(address => uint256) public totalReserved;    // vault address (licensee address) => total amount used for reimbursement
    mapping(address => mapping(address => uint256)) public balances;    // vault address => user address => eligible reimbursement balance
    mapping(address => mapping(address => Stake)) public staking;    // vault address => user address => Stake
    mapping(address => EnumerableSet.AddressSet) vaults;   // user address => licensee address list that user mat get reimbursement
    mapping(address => mapping(address => uint256)) licenseeFees;    // vault => contract => fee (with 2 decimals). I.e. 30 means 0.3%
    mapping(address => EnumerableSet.AddressSet) licenseeVaults;    // licensee address => list of vaults

    event StakeToken(address indexed vault, address indexed user, uint256 date, uint256 amount);
    event UnstakeToken(address indexed vault, address indexed user, uint256 date, uint256 amount);
    event SetLicenseeFee(address indexed vault, address indexed projectContract, uint256 fee);
    event VaultCreated(address indexed vault, address indexed owner, address indexed token);
    event SetVaultOwner(address indexed vault, address indexed oldOwner, address indexed newOwner);
    event ReimbursementAdded(address indexed vault, address indexed user, uint256 amount);

    // set percentage of fee (with 2 decimals) by licensee for selected `projectContract`
    function setLicenseeFee(address vault, address projectContract, uint256 fee) external {
        require(settings[vault].owner == msg.sender, "Only vault owner");
        licenseeFees[vault][projectContract] = fee;
        emit SetLicenseeFee(vault, projectContract, fee);
    }

    // get percentage of fee (with 2 decimals) set by licensee for selected `projectContract`
    function getLicenseeFee(address vault, address projectContract) external view returns(uint256 fee) {
        return licenseeFees[vault][projectContract];
    }

    // get list of licensee vaults addresses belong to licensee
    function getLicenseeVaults(address licensee) external view returns(address[] memory vault) {
        return licenseeVaults[licensee]._values;
    }

    // get list of vault addresses where user has tokens.
    function getVaults(address user) external view returns(address[] memory vault) {
        return vaults[user]._values;
    }

    // get numbers of vault where user has tokens.
    function getVaultsLength(address user) external view returns(uint256) {
        return vaults[user].length();
    }

    // get vault address by index
    function getVault(address user, uint256 index) external view returns(address) {
        return vaults[user].at(index);
    }

    // Get vault owner
    function getVaultOwner(address vault) external view returns(address) {
        return settings[vault].owner;
    }

    // change vault owner. Only current owner can call it.
    function setVaultOwner(address vault, address newOwner) external {
        require(msg.sender == settings[vault].owner, "caller should be owner");
        require(newOwner != address(0), "Wrong new owner address");
        emit SetVaultOwner(vault, settings[vault].owner, newOwner);
        settings[vault].owner = newOwner;
    }

    // get list of vault and balance where user can get reimbursement 
    function getVaultsBalance(address user) external view returns(address[] memory vault, uint256[] memory balance) {
        vault = vaults[user]._values;
        balance = new uint256[](vault.length);
        for (uint i = 0; i < vault.length; i++) {
            balance[i] = balances[vault[i]][user];
        }
    }

    // get available (not reserved) tokens amount in vault
    function getAvailableTokens(address vault) public view returns(uint256 available) {
        available = IBEP20(settings[vault].token).balanceOf(vault) - totalReserved[vault];
    }

    // vault owner can withdraw unreserved tokens
    function withdrawTokens(address vault, uint256 amount) external {
        require(msg.sender == settings[vault].owner, "caller should be owner");
        uint256 available = getAvailableTokens(vault);
        require(available >= amount, "not enough available tokens");
        TokenVault(vault).transferToken(msg.sender, amount);
    }

    // Stake `amount` of token to `vault` to receive reimbursement
    function stake(address vault, uint256 amount) external {
        uint256 balance = balances[vault][msg.sender];
        require(balance != 0, "No tokens for reimbursement");
        Stake storage s = staking[vault][msg.sender];
        uint256 currentStake = s.amount;
        safeTransferFrom(settings[vault].token, msg.sender, vault, amount);
        totalReserved[vault] += amount;
        if (currentStake != 0) {
            // recalculate time due new amount: old interval * old amount = new interval * new amount
            uint256 interval = block.timestamp - s.startTime;
            interval = interval * currentStake / (currentStake + amount);
            s.startTime = block.timestamp - interval;
            s.amount = currentStake + amount;
        } else {
            s.startTime = block.timestamp;
            s.amount = amount;
        }
        emit StakeToken(vault, msg.sender, block.timestamp, amount);
    }

    // Withdraw staked tokens + reward from vault.
    function unstake(address vault) external {
        Stake memory s = staking[vault][msg.sender];
        Setting memory set = settings[vault];
        uint256 amount;
        uint256 balance = balances[vault][msg.sender];
        if (set.period == 0) {
            require(balance != 0, "No reimbursement");
            amount = balance;
        } else {
            require(s.amount != 0, "No stake");
            uint256 interval = block.timestamp - s.startTime;
            amount = s.amount * 100 * interval / (set.period * set.reimbursementRatio);
        }
        delete staking[vault][msg.sender];   // remove staking record.
        if (amount > balance) amount = balance;
        balance -= amount;
        balances[vault][msg.sender] = balance;
        if (balance == 0) {
            vaults[msg.sender].remove(vault); // remove vault from vaults list where user has reimbursement tokens
        }
        if (set.isMintable) {
            totalReserved[vault] -= s.amount;
            TokenVault(vault).transferToken(msg.sender, s.amount); // withdraw staked amount
            IBEP20(set.token).mint(msg.sender, amount); // mint reimbursement token
            amount += s.amount; // total amount: rewards + staking
        } else {
            amount += s.amount; // total amount: rewards + staking
            totalReserved[vault] -= amount;
            TokenVault(vault).transferToken(msg.sender, amount); // withdraw staked amount + rewards
        }
        emit UnstakeToken(vault, msg.sender, block.timestamp, amount);
    }

    // get information about user's fee
    // address user - address of user whp paid the fee
    // uint256 feeAmount - amount of fee in native coin (ETH, BNB)
    // address vault - licensee vault address that licensee get after registration. Use it as Licensee ID.
    // returns address of fee receiver or address(0) if licensee can't receive the fee (should be returns to user)
    function requestReimbursement(address user, uint256 feeAmount, address vault) external returns(address licenseeAddress){
        uint256 licenseeFee = licenseeFees[vault][msg.sender];
        if (licenseeFee == 0) return address(0); // project contract not added to reimbursement
        Setting memory set = settings[vault];
        (uint256 reserve0, uint256 reserve1,) = set.swapPair.getReserves();
        if (set.isReversOrder) (reserve0, reserve1) = (reserve1, reserve0);
        uint256 amount = reserve0 * feeAmount / reserve1;

        if (!set.isMintable) {
            uint256 reserve = totalReserved[vault];
            uint256 available = IBEP20(set.token).balanceOf(vault) - reserve;
            if (available < amount) return address(0);  // not enough reimbursement tokens
            totalReserved[vault] = reserve + amount;
        }

        uint256 balance = balances[vault][user];
        if (balance == 0) vaults[user].add(vault);
        balances[vault][user] = balance + amount;
        emit ReimbursementAdded(vault, user, amount);
        return set.owner;
    }

    // create new vault (register Licensee)
    function newVault(
        address token,              // reimbursement token
        bool isMintable,            // token can be minted by this contract
        uint64 period,              // staking period in seconds (365 days)
        uint32 reimbursementRatio,   // the ratio of deposited amount to reimbursement amount (with 2 decimals). 
        address swapPair,           // uniswap compatible pair for token and native coin (ETH, BNB)
        uint32[] memory licenseeFee,         // percentage of Licensee fee (with 2 decimals). I.e. 30 means 0.3%
        address[] memory projectContract     // contract that has right to request reimbursement
    ) 
        external 
        returns(address vault) // vault - is the vault contract address where project has to transfer tokens. A licensee has to use it as Licensee ID.
    {
        if (isMintable) {
            require(msg.sender == owner(), "Only owner may add mintable token");
        }
        bool isReversOrder;
        if (IUniswapV2Pair(swapPair).token1() == token) {
            isReversOrder == true;
        } else {
            require(IUniswapV2Pair(swapPair).token0() == token, "Wrong swap pair");
        }
        vault = address(new TokenVault(msg.sender, token));
        licenseeVaults[msg.sender].add(vault);
        settings[vault] = Setting(token, isMintable, msg.sender, period, reimbursementRatio, IUniswapV2Pair(swapPair), isReversOrder);
        require(licenseeFee.length == projectContract.length, "Wrong length");
        for (uint i = 0; i < projectContract.length; i++) {
            require(licenseeFee[i] <= 10000, "Wrong fee");
            licenseeFees[vault][projectContract[i]] = licenseeFee[i];
            emit SetLicenseeFee(vault, projectContract[i], licenseeFee[i]);
        }
        emit VaultCreated(vault, msg.sender, token);
    }

    // This contract should not received any tokens, but due issue in ERC20 standard we can't disallow someone to do it.
    // If someone accidentally transfer tokens to this contract, the owner will be able to rescue it and refund sender.
    function rescueTokens(address someToken) external onlyOwner {
        uint256 available = IBEP20(someToken).balanceOf(address(this));
        safeTransfer(someToken, msg.sender, available);
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

}