/**
 *Submitted for verification at Etherscan.io on 2021-02-07
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

// Note that it's ownable and the owner wields tremendous power. The ownership
// will be transferred to a governance smart contract once Testa is sufficiently
// distributed and the community can show to govern itself.
//
// Have fun reading it. Hopefully it's bug-free. God bless.
contract SpaceFarm is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        mapping (uint256 => uint256) pendingTesta;
        mapping (uint256 => uint256) rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of Testa
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accTestaPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accTestaPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 jETHToken;           // Address of LP token contract.
        IUniswapV2Pair uniswap;
        uint112 startLiquidity;
        uint256 allocPoint;       // How many allocation points assigned to this pool. Testa to distribute per block.
        uint256 lastRewardBlock;  // Last block number that Testa distribution occurs.
        uint256 accTestaPerShare; // Accumulated Testa per share, times 1e18. See below.
        uint256 debtIndexKey;
        uint256 startBlock;
        uint256 initStartBlock;
    }

    // The Testa TOKEN!
    address public testa;
    address public jTesta;
    // Testa tokens created per block.
    uint256 public testaPerBlock;
    uint256 public jTestaAmount;
    // Bonus muliplier for early testa makers.
    uint256 public constant BONUS_MULTIPLIER = 10;
    // The migrator contract. It has a lot of power. Can only be set through governance (owner).
    IMigratorChef public migrator;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;
    // Total allocation poitns. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    uint256 public activeReward = 10;
    int public progressive = 0;
    int public maxProgressive;
    int public minProgressive;
    uint256 public numberOfBlock;
    uint112 public startLiquidity;
    uint112 public currentLiquidity;
    AggregatorV3Interface public priceFeed;
    
    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(
        address _testa,
        address _jTesta,
        address _priceFeed,
        int _minProgressive,
        int _maxProgressive,
        uint256 activateAtBlock,
        uint256 _testaPerBlock,
        uint256 _jTestaAmount
    ) public {
        testa = _testa;
        jTesta = _jTesta;
        priceFeed = AggregatorV3Interface(_priceFeed);
        minProgressive = _minProgressive;
        maxProgressive = _maxProgressive;
        numberOfBlock = activateAtBlock;
        testaPerBlock = _testaPerBlock;
        jTestaAmount = _jTestaAmount;
    }

    /// @dev Require that the caller must be an EOA account to avoid flash loans.
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Not EOA");
        _;
    }

    modifier validPool(uint256 _pid) {
        require(_pid < poolInfo.length);
        _;
    }

    function setjTestaAmount(uint256 _jTestaAmount) public onlyOwner {
        jTestaAmount = _jTestaAmount;
    }

    function setTestaPerBlock(uint256 _testaPerBlock) public onlyOwner{
        testaPerBlock = _testaPerBlock;
    }

    function setProgressive(int _maxProgressive, int _minProgressive) public onlyOwner{
        maxProgressive = _maxProgressive;
        minProgressive = _minProgressive;
    }

    function setNumberOfBlock(uint256 _numberOfBlock) public onlyOwner{
        numberOfBlock = _numberOfBlock;
    }

    function setActiveReward(uint256 _activeReward) public onlyOwner{
        activeReward = _activeReward;
    }

    function harvestAndWithdraw(uint256 _pid, uint256 _amount) public nonReentrant validPool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 jETHSupply = pool.jETHToken.balanceOf(address(this));

        require(getCountDown(_pid) <= numberOfBlock);
        require((progressive == maxProgressive) && (jETHSupply != 0), "Must have jETHSupply and reach maxProgressive to harvest");
        require(user.amount >= _amount, "No jETHToken cannot withdraw");
        updatePool(_pid);
        
        uint256 testaAmount = pendingTesta( _pid, msg.sender);
        
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            user.rewardDebt[pool.debtIndexKey] = user.amount.mul(pool.accTestaPerShare).div(1e18);
            user.pendingTesta[pool.debtIndexKey] = 0;
            pool.jETHToken.safeTransfer(address(msg.sender), _amount);
            safeTestaTransfer(msg.sender, testaAmount);
        }
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function harvest(uint256 _pid) public nonReentrant validPool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 lpSupply = pool.jETHToken.balanceOf(address(this));

        require(getCountDown(_pid) <= numberOfBlock);
        require((progressive == maxProgressive) && (lpSupply != 0), "Must have jETHSupply and reach maxProgressive to harvest");
        require(user.amount > 0, "No jETHToken cannot withdraw");
        updatePool(_pid);
        
        uint256 testaAmount = pendingTesta( _pid, msg.sender);
        user.rewardDebt[pool.debtIndexKey] = user.amount.mul(pool.accTestaPerShare).div(1e18);
        user.pendingTesta[pool.debtIndexKey] = 0;
        safeTestaTransfer(msg.sender, testaAmount);
    }
    
    function firstActivate(uint256 _pid) public onlyEOA nonReentrant validPool(_pid) {
        require(IERC20(jTesta).balanceOf(msg.sender) >= jTestaAmount, "Insufficient jTesta amount");
        currentLiquidity = getLiquidity(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.initStartBlock == pool.startBlock);
        require(block.number >= pool.initStartBlock, "Cannot activate until the specific block time arrive");
        pool.startBlock = getLatestBlock();
        pool.startLiquidity = currentLiquidity;
        // send Testa to user who press activate button
        safeTestaTransfer(msg.sender, getTestaReward(_pid));
    }

    function activate(uint256 _pid) public onlyEOA nonReentrant validPool(_pid) {
        require(IERC20(jTesta).balanceOf(msg.sender) >= jTestaAmount, "Insufficient jTesta amount");
        currentLiquidity = getLiquidity(_pid);
        PoolInfo storage pool = poolInfo[_pid];
        require(pool.initStartBlock != pool.startBlock);
        require(getCountDown(_pid) >= numberOfBlock, "Cannot activate until specific amount of blocks pass");
        
        if(currentLiquidity > pool.startLiquidity){
            progressive++;
        }else{
            progressive--;
        }
            
        if(progressive <= minProgressive){
            progressive = minProgressive;
            clearPool(_pid);
        }else if(progressive >= maxProgressive){
            progressive = maxProgressive;
        }
        pool.startBlock = getLatestBlock();  
        pool.startLiquidity = currentLiquidity;
        // send Testa to user who press activate button
        safeTestaTransfer(msg.sender, getTestaReward(_pid));
    }

    function getTestaPoolBalance() public view returns (uint256){
        return IERC20(testa).balanceOf(address(this));
    }
    
    function getProgressive() public view returns (int){
        return progressive;
    }
    
    function getLatestBlock() public view returns (uint256) {
        return block.number;
    }
    
    function getCountDown(uint256 _pid) public view returns (uint256){
        require(getLatestBlock() > getStartedBlock(_pid));
        return getLatestBlock().sub(getStartedBlock(_pid));
    }

    function getStartedBlock(uint256 _pid) public view returns (uint256){
        PoolInfo storage pool = poolInfo[_pid];
        return pool.startBlock;
    }
    
    function getLiquidity(uint256 _pid) public view returns (uint112){
        PoolInfo storage pool = poolInfo[_pid];
        ( , uint112 _reserve1, ) = pool.uniswap.getReserves();
        return _reserve1;
    }

    function getLatestPrice() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        // If the round is not complete yet, timestamp is 0
        require(timeStamp > 0, "Round not complete");
        return price;
    }

    function getTestaReward(uint256 _pid) public view returns (uint256){
         PoolInfo storage pool = poolInfo[_pid];
        (uint112 _reserve0, uint112 _reserve1, ) = pool.uniswap.getReserves();
        uint256 reserve = uint256(_reserve0).mul(1e18).div(uint256(_reserve1));
        uint256 ethPerDollar = uint256(getLatestPrice()).mul(1e10); // 1e8
        uint256 testaPerDollar = ethPerDollar.mul(1e18).div(reserve);
        uint256 _activeReward = activeReward.mul(1e18);
        uint256 testaAmount = _activeReward.mul(1e18).div(testaPerDollar);
        return testaAmount;
    }
    
    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function checkPoolDuplicate(IERC20 jETHToken) internal {
        uint256 length = poolInfo.length;
        for(uint256 pid = 0; pid < length; ++pid) {
            require(poolInfo[pid].jETHToken != jETHToken, "add: existing pool?");
        }
    }

    // Add a new lp to the pool. Can only be called by the owner.
    // XXX DO NOT add the same LP token more than once. Rewards will be messed up if you do.
    function add(uint256 startBlock, uint256 _allocPoint, address _lpToken, address _jETHToken, bool _withUpdate) public onlyOwner {
        checkPoolDuplicate(IERC20(_jETHToken));
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        IUniswapV2Pair uniswap = IUniswapV2Pair(_lpToken);
        ( , uint112 _reserve1, ) = uniswap.getReserves(); 
        
        poolInfo.push(PoolInfo({
            jETHToken: IERC20(_jETHToken),
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accTestaPerShare: 0,
            debtIndexKey: 0,
            uniswap: uniswap,
            startLiquidity: _reserve1,
            startBlock: startBlock,
            initStartBlock: startBlock
        }));

        
    }

    // Update the given pool's Testa allocation point. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner validPool(_pid) {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    // Set the migrator contract. Can only be called by the owner.
    function setMigrator(IMigratorChef _migrator) public onlyOwner {
        migrator = _migrator;
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from);
    }
    
    function clearPool(uint256 _pid) internal validPool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        pool.accTestaPerShare = 0;
        pool.lastRewardBlock = block.number;
        pool.debtIndexKey++;
    }

    // View function to see pending Testa on frontend.
    function pendingTesta(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accTestaPerShare = pool.accTestaPerShare;
        uint256 jETHSupply = pool.jETHToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && jETHSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 testaReward = multiplier.mul(testaPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accTestaPerShare = accTestaPerShare.add(testaReward.mul(1e18).div(jETHSupply));
        }
        uint256 rewardDebt = user.rewardDebt[pool.debtIndexKey];
        return user.amount.mul(accTestaPerShare).div(1e18).sub(rewardDebt).add(user.pendingTesta[pool.debtIndexKey]);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public validPool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 jETHSupply = pool.jETHToken.balanceOf(address(this));
        if (jETHSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 testaReward = multiplier.mul(testaPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accTestaPerShare = pool.accTestaPerShare.add(testaReward.mul(1e18).div(jETHSupply));
        pool.lastRewardBlock = block.number;
    }

    // Deposit LP tokens to TestaFarm for Testa allocation.
    function deposit(uint256 _pid, uint256 _amount) public validPool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);

        if (user.amount > 0) {
          user.pendingTesta[pool.debtIndexKey] = pendingTesta(_pid, msg.sender);
        }
        
        if(_amount > 0) {
            pool.jETHToken.safeTransferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
        }
        
        user.rewardDebt[pool.debtIndexKey] = user.amount.mul(pool.accTestaPerShare).div(1e18);
        emit Deposit(msg.sender, _pid, _amount);
    }

    // Withdraw LP tokens from TestaFarm.
    function withdraw(uint256 _pid, uint256 _amount) public validPool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "No jETHToken cannot withdraw");
        updatePool(_pid);
        
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.jETHToken.safeTransfer(address(msg.sender), _amount);
        }
        user.rewardDebt[pool.debtIndexKey] = user.amount.mul(pool.accTestaPerShare).div(1e18);
        user.pendingTesta[pool.debtIndexKey] = 0;
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public validPool(_pid) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 _amount = user.amount;
        user.amount = 0;
        user.rewardDebt[pool.debtIndexKey] = 0;
        pool.jETHToken.safeTransfer(address(msg.sender), _amount);
        emit EmergencyWithdraw(msg.sender, _pid, user.amount);
    }

    // Safe testa transfer function, just in case if rounding error causes pool to not have enough Testa.
    function safeTestaTransfer(address _to, uint256 _amount) internal {
        uint256 testaBal = IERC20(testa).balanceOf(address(this));
        if (_amount > testaBal) {
            testa.call(abi.encodeWithSignature("transfer(address,uint256)", _to, testaBal));
        } else {
            testa.call(abi.encodeWithSignature("transfer(address,uint256)", _to, _amount));
        }
    }
}