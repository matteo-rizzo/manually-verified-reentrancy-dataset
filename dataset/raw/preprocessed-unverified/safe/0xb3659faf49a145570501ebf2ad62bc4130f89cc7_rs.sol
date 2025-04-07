/**
 *Submitted for verification at Etherscan.io on 2021-02-10
*/

pragma solidity 0.6.12;



/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
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


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the `nonReentrant` modifier
 * available, which can be aplied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}





contract UniverseFarm is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeToken for address;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many tokens the user has provided.
        mapping(uint256 => uint256) accReward;  // Accumulated reward since position opened
        mapping(uint256 => uint256) startIndex; // Start ETH index
    }

    address public merkleDistributor;
    IERC20 public jTesta;
    IERC20 public testa;
    IPlanetFarmConfig public config;
    uint112 public startLiquidity;
    uint112 public currentLiquidity;
    uint256 public startBlock;
    uint256 public initStartBlock;
    int public progressive = 0;
    uint256[] public accETHReward;
    uint256 public activationCount;
    uint256 public totalStake;
    uint256 public prevRoundETHReward;
    uint256 public round;
    uint256 public profit;
    
    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo; 
   
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Harvest(address indexed user, uint256 amount);
    event HarvestAndWithdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(
        uint256 _profit,
        uint256 _startBlock,
        IERC20 _testa,
        IERC20 _jTesta,
        IPlanetFarmConfig _config,
        address _merkleDistributor
    ) public {
        profit = _profit;
        startBlock = _startBlock;
        initStartBlock = _startBlock;
        testa = _testa;
        jTesta = _jTesta;
        config = _config;
        startLiquidity = _config.getLiquidity();
        accETHReward.push(0);
        merkleDistributor = _merkleDistributor;
    }

    /// @dev Require that the caller must be an EOA account to avoid flash loans.
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Not EOA");
        _;
    }
    
    receive() external payable {}

    function setConfig(IPlanetFarmConfig _config) public onlyOwner {
        config = _config;
    }

    function setMerkleDistributor(address _merkleDistributor) public onlyOwner {
        merkleDistributor = _merkleDistributor;
    }

    function setProfit(uint256 _profit) public onlyOwner {
        profit = _profit;
    }
    
    function setToken(IERC20 _testa, IERC20 _jTesta) public onlyOwner {
        testa = _testa;
        jTesta = _jTesta;
    }

    function harvestAndWithdraw(uint256 _amount) public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 jTestaSupply = jTesta.balanceOf(address(this));
        ( , int maxProgressive) = config.getProgressive();
        require(getBlockPass() <= config.getActivateAtBlock());
        require((progressive == maxProgressive) && (jTestaSupply != 0), "Must have jTestaSupply and reach maxProgressive to harvest");
        require(user.amount >= _amount, "No JTesta cannot withdraw");
        
        uint256 rewardAmount = getUserReward(msg.sender);
        uint256 userProfit = rewardAmount.mul(profit).div(10000);
        uint256 _harvestFee = config.getTestaFee(userProfit);

        require(testa.balanceOf(msg.sender) > _harvestFee, "Must have enough testa before harvest");
        testa.safeTransferFrom(msg.sender, config.getCompany(), _harvestFee);
        removeReward(msg.sender, rewardAmount);
        SafeToken.safeTransferETH(merkleDistributor, rewardAmount.sub(userProfit));
        SafeToken.safeTransferETH(msg.sender, userProfit);
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            jTesta.safeTransfer(msg.sender, _amount);
            totalStake = totalStake.sub(_amount);
        }
        emit HarvestAndWithdraw(msg.sender, _amount);
    }

    function harvest() public nonReentrant {
        UserInfo storage user = userInfo[msg.sender];
        uint256 jTestaSupply = jTesta.balanceOf(address(this));
        ( , int maxProgressive) = config.getProgressive();
        require(getBlockPass() <= config.getActivateAtBlock());
        require((progressive == maxProgressive) && (jTestaSupply != 0), "Must have jTestaSupply and reach maxProgressive to harvest");
        require(user.amount > 0, "No JTesta cannot withdraw");
        
        uint256 rewardAmount = getUserReward(msg.sender);
        uint256 userProfit = rewardAmount.mul(profit).div(10000);
        uint256 _harvestFee = config.getTestaFee(userProfit);
        
        require(testa.balanceOf(msg.sender) > _harvestFee, "Must have enough testa before harvest");
        testa.safeTransferFrom(msg.sender, config.getCompany(), _harvestFee);
        removeReward(msg.sender, rewardAmount);
        SafeToken.safeTransferETH(merkleDistributor, rewardAmount.sub(userProfit));
        SafeToken.safeTransferETH(msg.sender, userProfit);
        emit Harvest(msg.sender, rewardAmount);
    }
    
    function firstActivate() public onlyEOA nonReentrant {
        require(jTesta.balanceOf(msg.sender) >= config.getJTestaAmount(), "Insufficient jTesta amount");
        require(initStartBlock == startBlock);
        require(block.number >= initStartBlock, "Cannot activate until the specific block time arrive");

        currentLiquidity = config.getLiquidity();
        startBlock = block.number;
        startLiquidity = currentLiquidity;   
        // send Testa to user who press activate button
        safeTestaTransfer(msg.sender, config.getTestaReward());
    }

    function activate() public onlyEOA nonReentrant {
        require(jTesta.balanceOf(msg.sender) >= config.getJTestaAmount(), "Insufficient jTesta amount");
        require(startBlock != initStartBlock && startBlock > initStartBlock);
        require(getBlockPass() >= config.getActivateAtBlock(), "Cannot activate until specific amount of blocks pass");
        (int minProgressive, int maxProgressive) = config.getProgressive();
        currentLiquidity = config.getLiquidity();
        accETHReward.push(accETHReward[activationCount] + (address(this).balance).sub(prevRoundETHReward).mul(1e12).div(totalStake));
        prevRoundETHReward = address(this).balance;
        activationCount++;
        uint256 requiredLiquidity = config.getRequiredLiquidity(startLiquidity);
        
        if(currentLiquidity > requiredLiquidity){
            progressive++;
        }else{
            progressive--;
        }

        if(progressive <= minProgressive){
            progressive = minProgressive;
            uint256 totalReward = address(this).balance;
            resetGlobalReward();
            SafeToken.safeTransferETH(config.getCompany(), totalReward);
        }else if(progressive >= maxProgressive){
            progressive = maxProgressive;
        }
        startBlock = block.number;  
        startLiquidity = currentLiquidity;

        // send Testa to user who press activate button
        safeTestaTransfer(msg.sender, config.getTestaReward());
    }

	function updateUserReward(address userAddress) internal {
		UserInfo storage user = userInfo[userAddress];
		if (user.startIndex[round] != activationCount) {
			uint256 userReward = getUserReward(userAddress);
			user.accReward[round] = userReward;
			user.startIndex[round] = activationCount;
		}
	}
	
	function removeReward(address userAddress,uint256 rewardAmount) internal {
	    UserInfo storage user = userInfo[userAddress];
	    user.accReward[round] = 0;
	    user.startIndex[round] = activationCount;
        prevRoundETHReward = prevRoundETHReward.sub(rewardAmount);
	}
	
	function resetGlobalReward() internal {
	    delete accETHReward;
        accETHReward.push(0);
        activationCount = 0;
        prevRoundETHReward = 0;
        round++;
	}

	function getUserReward(address userAddress) public view returns(uint256) {
        UserInfo storage user = userInfo[userAddress];
        uint256 prevReward = accETHReward[activationCount] - accETHReward[user.startIndex[round]];
        uint256 total = user.accReward[round].add(user.amount.mul(prevReward).div(1e12));
		return total;
    }

    function getUserAccReward(address userAddress) public view  returns(uint256) {
        UserInfo storage user = userInfo[userAddress];
        return user.accReward[round];
    }

    function getUserStartIndex(address userAddress) public view  returns(uint256) {
        UserInfo storage user = userInfo[userAddress];
        return user.startIndex[round];
    }

    function getTestaPoolBalance() public view returns (uint256){
        return testa.balanceOf(address(this));
    }
    
    function getProgressive() public view returns (int){
        return progressive;
    }

    function getLatestBlock() public view returns (uint256) {
        return block.number;
    }
    
    function getBlockPass() public view returns (uint256){
        return block.number.sub(startBlock);
    }

    function getStartedBlock() public view returns (uint256) {
        return startBlock;
    }
    
    function totalETH() public view returns (uint256) {
        return address(this).balance;
    }
    
    // Deposit LP tokens to TestaFarm for Testa allocation.
    function deposit(uint256 amount) public {
        require(amount > 0 , "invalid amount");
        UserInfo storage user = userInfo[msg.sender];
		updateUserReward(msg.sender);
        jTesta.safeTransferFrom(msg.sender, address(this), amount);
        user.amount = user.amount.add(amount);
		
		totalStake = totalStake.add(amount);
        emit Deposit(msg.sender, amount);
    }

    // Withdraw LP tokens from TestaFarm.
    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= _amount, "Not enought token to withdraw");
        if(_amount > 0) {
			uint256 rewardAmount = getUserReward(msg.sender);
			removeReward(msg.sender, rewardAmount);
            SafeToken.safeTransferETH(config.getCompany(), rewardAmount);
            user.amount = user.amount.sub(_amount);
            jTesta.safeTransfer(msg.sender, _amount);
            totalStake = totalStake.sub(_amount);
        }
        emit Withdraw(msg.sender, _amount);
    }
    
    function emergencyWithdraw(uint256 amount) public onlyOwner{
        uint256 totalETHBal = address(this).balance;
        if(amount > totalETHBal){
            SafeToken.safeTransferETH(msg.sender, totalETHBal);
        }else{
            SafeToken.safeTransferETH(msg.sender, amount);
        }
    }

    // Safe testa transfer function, just in case if rounding error causes pool to not have enough Testa.
    function safeTestaTransfer(address _to, uint256 _amount) internal {
        uint256 testaBal = testa.balanceOf(address(this));
        if (_amount > testaBal) {
            testa.safeTransfer(_to, testaBal);
        } else {
            testa.safeTransfer(_to, _amount);
        }
    } 
}