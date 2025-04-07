/**
 *Submitted for verification at Etherscan.io on 2021-03-04
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @title Initializable
 *
 * @dev Helper contract to support initializer functions. To use it, replace
 * the constructor with a function that has the `initializer` modifier.
 * WARNING: Unlike constructors, initializer functions must be manually
 * invoked. This applies both to deploying an Initializable contract, as well
 * as extending an Initializable contract via inheritance.
 * WARNING: When used with inheritance, manual care must be taken to not invoke
 * a parent initializer twice, or ensure that all initializers are idempotent,
 * because this is not dealt with automatically as with constructors.
 */
contract Initializable {

  /**
   * @dev Indicates that the contract has been initialized.
   */
  bool private initialized;

  /**
   * @dev Indicates that the contract is in the process of being initialized.
   */
  bool private initializing;

  /**
   * @dev Modifier to use in the initializer function of a contract.
   */
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  /// @dev Returns true if and only if the function is running in the constructor
  function isConstructor() private view returns (bool) {
    // extcodesize checks the size of the code stored in an address, and
    // address returns the current address. Since the code is still not
    // deployed when running a constructor, any checks on its code size will
    // yield zero, making it an effective way to detect if a contract is
    // under construction or not.
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  // Reserved storage space to allow for layout changes in the future.
  uint256[50] private ______gap;
}

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
contract ContextUpgradeSafe is Initializable {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.

    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {


    }


    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }

    uint256[50] private __gap;
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
contract OwnableUpgradeSafe is Initializable, ContextUpgradeSafe {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {


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

    uint256[49] private __gap;
}

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
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuardUpgradeSafe is Initializable {
    bool private _notEntered;


    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {


        // Storing an initial non-zero value makes deployment a bit more
        // expensive, but in exchange the refund on every call to nonReentrant
        // will be lower in amount. Since refunds are capped to a percetange of
        // the total transaction's gas, it is best to keep them low in cases
        // like this one, to increase the likelihood of the full refund coming
        // into effect.
        _notEntered = true;

    }


    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }

    uint256[49] private __gap;
}



/**
 * @notice
 */


/// @dev Slots reserved for possible storage layout changes (it neither spends gas nor adds extra bytecode)
contract ReservedSlots {
    uint256[100] private __gap;
}

// File: contracts/lib/SafeMath96.sol







abstract contract DelegatableVotes {
    using SafeMath96 for uint96;
    using DelegatableCheckpoints for DelegatableCheckpoints.Record;

    /**
     * @notice Votes computation data for each account
     * @dev Data adjusted to account "delegated" votes
     * @dev For the contract address, stores shared for all accounts data
     */
    mapping (address => DelegatableCheckpoints.Record) public book;

    /**
     * @dev Data on votes which an account may delegate or has already delegated
     */
    mapping (address => uint192) internal delegatables;

    /// @notice The event is emitted when a delegate account' vote balance changes
    event CheckpointBalanceChanged(address indexed delegate, uint previousBalance, uint newBalance);

    /// @notice An event that's emitted when an account changes its delegate
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    /**
     * @notice Get the "delegatee" account for the message sender
     */
    function delegatee() public view returns (address) {
        return book[msg.sender].delegatee;
    }

    /**
     * @notice Delegate votes from `msg.sender` to `delegatee`
     * @param delegateer The address to delegate votes to
     */
    function delegate(address delegateer) public {
        require(delegateer != address(this), "delegate: can't delegate to contract address");
        return _delegate(msg.sender, delegateer);
    }

    /**
     * @notice Get the current votes balance for `account`
     * @param account The address to get votes balance
     * @return The number of current votes for `account`
     */
    function getCurrentVotes(address account) external view returns (uint96) {
        uint192 userData = book[account].getLatestData();
        if (userData == 0) return 0;

        uint192 sharedData = book[address(this)].getLatestData();
        return _computeUserVotes(userData, sharedData);
    }

    /**
     * @notice Determine the prior number of votes for the given account as of the given block
     * @dev To prevent misinformation, the call reverts if the block requested is not finalized
     * @param account The address of the account to get votes for
     * @param blockNumber The block number to get votes at
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(address account, uint blockNumber) public view returns (uint96) {
        return getPriorVotes(account, blockNumber, 0, 0);
    }

    /**
     * @notice Gas-optimized version of the `getPriorVotes` function -
     * it accepts IDs of checkpoints to look for voice data as of the given block in
     * (if the checkpoints miss the data, it get searched through all checkpoints recorded)
     * @dev Call (off-chain) the `findCheckpoints` function to get needed IDs
     * @param account The address of the account to get votes for
     * @param blockNumber The block number to get votes at
     * @param userCheckpointId ID of the checkpoint to look for the user data first
     * @param userCheckpointId ID of the checkpoint to look for the shared data first
     * @return The number of votes the account had as of the given block
     */
    function getPriorVotes(
        address account,
        uint blockNumber,
        uint32 userCheckpointId,
        uint32 sharedCheckpointId
    ) public view returns (uint96)
    {
        uint192 userData = book[account].getPriorData(blockNumber, userCheckpointId);
        if (userData == 0) return 0;

        uint192 sharedData = book[address(this)].getPriorData(blockNumber, sharedCheckpointId);
        return _computeUserVotes(userData, sharedData);
    }

    /// @notice Returns IDs of checkpoints which store the given account' voice computation data
    /// @dev Intended for off-chain use (by UI)
    function findCheckpoints(address account, uint256 blockNumber)
    external view returns (uint32 userCheckpointId, uint32 sharedCheckpointId)
    {
        require(account != address(0), "findCheckpoints: zero account");
        (userCheckpointId, ) = book[account].findCheckpoint(blockNumber);
        (sharedCheckpointId, ) = book[address(this)].findCheckpoint(blockNumber);
    }

    function _getCheckpoint(address account, uint32 checkpointId)
    internal view returns (uint32 fromBlock, uint192 data)
    {
        (fromBlock, data) = book[account].getCheckpoint(checkpointId);
    }

    function _writeSharedData(uint192 data) internal {
        book[address(this)].writeCheckpoint(data);
    }

    function _writeUserData(address account, uint192 data) internal {
        DelegatableCheckpoints.Record storage src = book[account];
        address delegateer = src.delegatee;
        DelegatableCheckpoints.Record storage dst = delegateer == address(0) ? src : book[delegateer];

        dst.writeCheckpoint(
           // keep in mind voices which others could have delegated
            _computeUserData(dst.getLatestData(), data, delegatables[account])
        );
        delegatables[account] = data;
    }

    function _moveUserData(address account, address from, address to) internal {
        DelegatableCheckpoints.Record storage src;
        DelegatableCheckpoints.Record storage dst;

        if (from == address(0)) { // no former delegatee
            src = book[account];
            dst = book[to];
        }
        else if (to == address(0)) { // delegation revoked
            src = book[from];
            dst = book[account];
        }
        else {
            src = book[from];
            dst = book[to];
        }
        uint192 delegatable = delegatables[account];

        uint192 srcPrevData = src.getLatestData();
        uint192 srcData = _computeUserData(srcPrevData, 0, delegatable);
        if (srcPrevData != srcData) src.writeCheckpoint(srcData);

        uint192 dstPrevData = dst.getLatestData();
        uint192 dstData = _computeUserData(dstPrevData, delegatable, 0);
        if (dstPrevData != dstData) dst.writeCheckpoint(dstData);
    }

    function _delegate(address delegator, address delegateer) internal {
        address currentDelegate = book[delegator].delegatee;
        book[delegator].delegatee = delegateer;

        emit DelegateChanged(delegator, currentDelegate, delegateer);

        _moveUserData(delegator, currentDelegate, delegateer);
    }

    function _computeUserVotes(uint192 userData, uint192 sharedData) internal pure virtual returns (uint96 votes);

    function _computeUserData(uint192 prevData, uint192 newDelegated, uint192 prevDelegated)
    internal pure virtual returns (uint192 userData)
    {
        (uint96 prevA, uint96 prevB) = _unpackData(prevData);
        (uint96 newDelegatedA, uint96 newDelegatedB) = _unpackData(newDelegated);
        (uint96 prevDelegatedA, uint96 prevDelegatedB) = _unpackData(prevDelegated);
        userData = _packData(
            _getNewValue(prevA, newDelegatedA, prevDelegatedA),
            _getNewValue(prevB, newDelegatedB, prevDelegatedB)
        );
    }

    function _unpackData(uint192 data) internal pure virtual returns (uint96 valA, uint96 valB) {
        return (uint96(data >> 96), uint96((data << 96) >> 96));
    }

    function _packData(uint96 valA, uint96 valB) internal pure  virtual returns (uint192 data) {
        return ((uint192(valA) << 96) | uint192(valB));
    }

    function _getNewValue(uint96 val, uint96 more, uint96 less) internal pure  virtual returns (uint96 newVal) {
        if (more == less) {
            newVal = val;
        } else if (more > less) {
            newVal = val.add(more.sub(less));
        } else {
            uint96 decrease = less.sub(more);
            newVal = val > decrease ? val.sub(decrease) : 0;
        }
    }

    uint256[50] private _gap; // reserved
}

contract YieldFarm is
    OwnableUpgradeSafe,
    ReentrancyGuardUpgradeSafe,
    ReservedSlots,
    DelegatableVotes,
    IVestedLPMining
{
    using SafeMath for uint256;
    using SafeMath96 for uint96;
    using SafeMath32 for uint32;

    using SafeERC20 for IERC20;

    /// @dev properties grouped to optimize storage costs

    struct User {
        uint32 lastUpdateBlock;   // block when the params (below) were updated
        uint32 vestingBlock;      // block by when all entitled TWA tokens to be vested
        uint96 pendedTwa;         // amount of TWAs tokens entitled but not yet vested to the user
        uint96 twaAdjust;         // adjustments for pended TWA tokens amount computation
                                  // (with regard to LP token deposits/withdrawals in the past)
        uint256 lptAmount;        // amount of LP tokens the user has provided to a pool
        /** @dev
         * At any time, the amount of TWA tokens entitled to a user but not yet vested is the sum of:
         * (1) TWA token amount entitled after the user last time deposited or withdrawn LP tokens
         *     = (user.lptAmount * pool.accTwaPerLpt) - user.twaAdjust
         * (2) TWA token amount entitled before the last deposit or withdrawal but not yet vested
         *     = user.pendedTwa
         *
         * Whenever a user deposits or withdraws LP tokens to a pool:
         *   1. `pool.accTwaPerLpt` for the pool gets updated;
         *   2. TWA token amounts to be entitled and vested to the user get computed;
         *   3. Token amount which may be vested get sent to the user;
         *   3. User' `lptAmount`, `twaAdjust` and `pendedTwa` get updated.
         *
         * Note comments on vesting rules in the `function _computeTwaVesting` code bellow.
         */
    }

    struct Pool {
        IERC20 lpToken;           // address of the LP token contract
        bool votesEnabled;        // if the pool is enabled to write votes
        uint8 poolType;           // pool type (1 - Uniswap, 2 - Balancer)
        uint32 allocPoint;        // points assigned to the pool, which affect TWAs distribution between pools
        uint32 lastUpdateBlock;   // latest block when the pool params which follow was updated
        uint256 accTwaPerLpt;     // accumulated distributed TWAs per one deposited LP token, times 1e12
    }
    // scale factor for `accTwaPerLpt`
    uint256 internal constant SCALE = 1e12;

    /// @dev new slot
    // The TWA TOKEN
    IERC20 public twa;
    // Total amount of TWA tokens pended (not yet vested to users)
    uint96 public twaVestingPool;

    // Vesting duration in blocks
    uint32 public twaVestingPeriodInBlocks;
    // The block number when TWA mining starts
    uint32 public startBlock;

    /// @dev new slot
    // The migrator contract (only the owner may assign it)
    ILpTokenMigrator public migrator;

    // Params of each pool
    Pool[] public pools;
    // Pid (i.e. the index in `pools`) of each pool by its LP token address
    mapping(address => uint256) public poolPidByAddress;
    // Params of each user that stakes LP tokens, by the Pid and the user address
    mapping (uint256 => mapping (address => User)) public users;
    // Sum of allocation points for all pools
    uint256 public totalAllocPoint = 0;

    /// @inheritdoc IVestedLPMining
    function initialize(
        IERC20 _twa,
        uint256 _startBlock,
        uint256 _twaVestingPeriodInBlocks
    ) external override initializer {
        __Ownable_init();
        __ReentrancyGuard_init_unchained();

        twa = _twa;
        startBlock = SafeMath32.fromUint(_startBlock, "YieldFarm: too big startBlock");
        twaVestingPeriodInBlocks = SafeMath32.fromUint(_twaVestingPeriodInBlocks, "YieldFarm: too big vest period");
    }

    /// @inheritdoc IVestedLPMining
    function poolLength() external view override returns (uint256) {
        return pools.length;
    }

    /// @inheritdoc IVestedLPMining
    function add(uint256 _allocPoint, IERC20 _lpToken, uint8 _poolType, bool _votesEnabled) public override onlyOwner {
        require(!isLpTokenAdded(_lpToken), "YieldFarm: token already added");

        massUpdatePools();
        uint32 blockNum = _currBlock();
        uint32 lastUpdateBlock = blockNum > startBlock ? blockNum : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);

        uint256 pid = pools.length;
        pools.push(Pool({
            lpToken: _lpToken,
            votesEnabled: _votesEnabled,
            poolType: _poolType,
            allocPoint: SafeMath32.fromUint(_allocPoint, "YieldFarm: too big allocation"),
            lastUpdateBlock: lastUpdateBlock,
            accTwaPerLpt: 0
        }));
        poolPidByAddress[address(_lpToken)] = pid;

        emit AddLpToken(address(_lpToken), pid, _allocPoint);
    }

    /// @inheritdoc IVestedLPMining
    function set(uint256 _pid, uint256 _allocPoint, uint8 _poolType, bool _votesEnabled) public override onlyOwner {
        massUpdatePools();
        totalAllocPoint = totalAllocPoint.sub(uint256(pools[_pid].allocPoint)).add(_allocPoint);
        pools[_pid].allocPoint = SafeMath32.fromUint(_allocPoint, "YieldFarm: too big allocation");
        pools[_pid].votesEnabled = _votesEnabled;
        pools[_pid].poolType = _poolType;

        emit SetLpToken(address(pools[_pid].lpToken), _pid, _allocPoint);
    }

    /// @inheritdoc IVestedLPMining
    function setMigrator(ILpTokenMigrator _migrator) public override onlyOwner {
        migrator = _migrator;

        emit SetMigrator(address(_migrator));
    }

    /// @inheritdoc IVestedLPMining
    function setTwaVestingPeriodInBlocks(uint256 _twaVestingPeriodInBlocks) public override onlyOwner {
        twaVestingPeriodInBlocks = SafeMath32.fromUint(
            _twaVestingPeriodInBlocks,
            "YieldFarm: too big twaVestingPeriodInBlocks"
        );

        emit SetTwaVestingPeriodInBlocks(_twaVestingPeriodInBlocks);
    }

    /// @inheritdoc IVestedLPMining
    /// @dev Anyone may call, so we have to trust the migrator contract
    function migrate(uint256 _pid) public override nonReentrant {
        require(address(migrator) != address(0), "YieldFarm: no migrator");
        Pool storage pool = pools[_pid];
        IERC20 lpToken = pool.lpToken;
        uint256 bal = lpToken.balanceOf(address(this));
        lpToken.safeApprove(address(migrator), bal);
        IERC20 newLpToken = migrator.migrate(lpToken, pool.poolType);
        require(bal == newLpToken.balanceOf(address(this)), "YieldFarm: invalid migration");
        pool.lpToken = newLpToken;

        delete poolPidByAddress[address(lpToken)];
        poolPidByAddress[address(newLpToken)] = _pid;

        emit MigrateLpToken(address(lpToken), address(newLpToken), _pid);
    }

    /// @inheritdoc IVestedLPMining
    function getMultiplier(uint256 _from, uint256 _to) public pure override returns (uint256) {
        return _to.sub(_from, "YieldFarm: _to exceeds _from");
    }

    /// @inheritdoc IVestedLPMining
    function pendingTwa(uint256 _pid, address _user) external view override returns (uint256) {
        if (_pid >= pools.length) return 0;

        Pool memory _pool = pools[_pid];
        User storage user = users[_pid][_user];

        _computePoolReward(_pool);
        uint96 newlyEntitled = _computeTwaToEntitle(
            user.lptAmount,
            user.twaAdjust,
            _pool.accTwaPerLpt
        );

        return uint256(newlyEntitled.add(user.pendedTwa));
    }

    /// @inheritdoc IVestedLPMining
    function vestableTwa(uint256 _pid, address user) external view override returns (uint256) {
        Pool memory _pool = pools[_pid];
        User memory _user = users[_pid][user];

        _computePoolReward(_pool);
        ( , uint256 newlyVested) = _computeTwaVesting(_user, _pool.accTwaPerLpt);

        return newlyVested;
    }

    /// @inheritdoc IVestedLPMining
    function isLpTokenAdded(IERC20 _lpToken) public view override returns (bool) {
        uint256 pid = poolPidByAddress[address(_lpToken)];
        return pools.length > pid && address(pools[pid].lpToken) == address(_lpToken);
    }

    /// @inheritdoc IVestedLPMining
    function massUpdatePools() public override {
        uint256 length = pools.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    /// @inheritdoc IVestedLPMining
    function updatePool(uint256 _pid) public override nonReentrant {
        Pool storage pool = pools[_pid];
        _doPoolUpdate(pool);
    }

    /// @inheritdoc IVestedLPMining
    function deposit(uint256 _pid, uint256 _amount) public override nonReentrant {
        _validatePoolId(_pid);

        Pool storage pool = pools[_pid];
        User storage user = users[_pid][msg.sender];

        _doPoolUpdate(pool);
        _vestUserTwa(user, pool.accTwaPerLpt);

        if(_amount != 0) {
            pool.lpToken.safeTransferFrom(msg.sender, address(this), _amount);
            user.lptAmount = user.lptAmount.add(_amount);
        }
        user.twaAdjust = _computeTwaAdjustment(user.lptAmount, pool.accTwaPerLpt);
        emit Deposit(msg.sender, _pid, _amount);

        _doCheckpointVotes(msg.sender);
    }

    /// @inheritdoc IVestedLPMining
    function withdraw(uint256 _pid, uint256 _amount) public override nonReentrant {
        _validatePoolId(_pid);

        Pool storage pool = pools[_pid];
        User storage user = users[_pid][msg.sender];
        require(user.lptAmount >= _amount, "YieldFarm: amount exceeds balance");

        _doPoolUpdate(pool);
        _vestUserTwa(user, pool.accTwaPerLpt);

        if(_amount != 0) {
            user.lptAmount = user.lptAmount.sub(_amount);
            pool.lpToken.safeTransfer(msg.sender, _amount);
        }
        user.twaAdjust = _computeTwaAdjustment(user.lptAmount, pool.accTwaPerLpt);
        emit Withdraw(msg.sender, _pid, _amount);

        _doCheckpointVotes(msg.sender);
    }

    /// @inheritdoc IVestedLPMining
    function emergencyWithdraw(uint256 _pid) public override nonReentrant {
        _validatePoolId(_pid);

        Pool storage pool = pools[_pid];
        User storage user = users[_pid][msg.sender];

        pool.lpToken.safeTransfer(msg.sender, user.lptAmount);
        emit EmergencyWithdraw(msg.sender, _pid, user.lptAmount);

        if (user.pendedTwa > 0) {
            // TODO: Make user.pendedTwa be updated as of the pool' lastUpdateBlock
            if (user.pendedTwa > twaVestingPool) {
                twaVestingPool = twaVestingPool.sub(user.pendedTwa);
            } else {
                twaVestingPool = 0;
            }
        }

        user.lptAmount = 0;
        user.twaAdjust = 0;
        user.pendedTwa = 0;
        user.vestingBlock = 0;

        _doCheckpointVotes(msg.sender);
    }

    function emergencyWithdrawTWA() external override onlyOwner {
        uint256 twaAmount = twa.balanceOf(address(this));
        twa.safeTransfer(msg.sender, twaAmount);
        emit EmergencyWithdrawTWA(msg.sender, twaAmount);
    }

    /// @inheritdoc IVestedLPMining
    function checkpointVotes(address _user) public override nonReentrant {
        _doCheckpointVotes(_user);
    }

    /// @inheritdoc IVestedLPMining
    function getCheckpoint(address account, uint32 checkpointId) external override view returns (uint32 fromBlock, uint96 twaAmount, uint96 pooledTwaShare) {
        uint192 data;
        (fromBlock, data) = _getCheckpoint(account, checkpointId);
        (twaAmount, pooledTwaShare) = _unpackData(data);
    }

    function _doCheckpointVotes(address _user) internal {
        uint256 length = pools.length;
        uint96 userPendedTwa = 0;
        uint256 userTotalLpTwa = 0;
        uint96 totalLpTwa = 0;
        for (uint256 pid = 0; pid < length; ++pid) {
            userPendedTwa = userPendedTwa.add(users[pid][_user].pendedTwa);

            Pool storage pool = pools[pid];
            uint96 lpTwa = SafeMath96.fromUint(
                twa.balanceOf(address(pool.lpToken)),
                // this and similar error messages are not intended for end-users
                "YieldFarm::_doCheckpointVotes:1"
            );
            totalLpTwa = totalLpTwa.add(lpTwa);

            if (!pool.votesEnabled) {
                continue;
            }

            uint256 lptTotalSupply = pool.lpToken.totalSupply();
            uint256 lptAmount = users[pid][_user].lptAmount;
            if (lptAmount != 0 && lptTotalSupply != 0) {
                uint256 twaPerLpt = uint256(lpTwa).mul(SCALE).div(lptTotalSupply);
                uint256 userLpTwa = lptAmount.mul(twaPerLpt).div(SCALE);
                userTotalLpTwa = userTotalLpTwa.add(userLpTwa);

                emit CheckpointUserLpVotes(_user, pid, userLpTwa);
            }
        }

        uint96 lpTwaUserShare = (userTotalLpTwa == 0 || totalLpTwa == 0)
            ? 0
            : SafeMath96.fromUint(
                userTotalLpTwa.mul(SCALE).div(totalLpTwa),
                "YieldFarm::_doCheckpointVotes:2"
            );

        emit CheckpointTotalLpVotes(totalLpTwa);
        emit CheckpointUserVotes(_user, uint256(userPendedTwa), lpTwaUserShare);

        _writeUserData(_user, _packData(userPendedTwa, lpTwaUserShare));
        _writeSharedData(_packData(totalLpTwa, 0));
    }

    function _transferTwa(address _to, uint256 _amount) internal {        
        if (_amount > 0 && _amount <= twa.balanceOf(address(this))) {
            SafeERC20.safeTransfer(twa, _to, _amount);
        }
    }

    /// @dev must be guarded for reentrancy
    function _doPoolUpdate(Pool storage pool) internal {
        Pool memory _pool = pool;
        uint32 prevBlock = _pool.lastUpdateBlock;
        uint256 prevAcc = _pool.accTwaPerLpt;

        uint256 twaReward = _computePoolReward(_pool);
        if (twaReward != 0) {
            twaVestingPool = twaVestingPool.add(
                SafeMath96.fromUint(twaReward, "YieldFarm::_doPoolUpdate:1"),
                "YieldFarm::_doPoolUpdate:2"
            );
        }
        if (_pool.accTwaPerLpt > prevAcc) {
            pool.accTwaPerLpt = _pool.accTwaPerLpt;
        }
        if (_pool.lastUpdateBlock > prevBlock) {
            pool.lastUpdateBlock = _pool.lastUpdateBlock;
        }
    }

    function _vestUserTwa(User storage user, uint256 accTwaPerLpt) internal {
        User memory _user = user;
        uint32 prevVestingBlock = _user.vestingBlock;
        uint32 prevUpdateBlock = _user.lastUpdateBlock;
        (uint256 newlyEntitled, uint256 newlyVested) = _computeTwaVesting(_user, accTwaPerLpt);

        if (newlyEntitled != 0) {
            user.pendedTwa = _user.pendedTwa;
        }
        if (newlyVested != 0) {
            if (newlyVested > twaVestingPool) newlyVested = uint256(twaVestingPool);
            twaVestingPool = twaVestingPool.sub(
                SafeMath96.fromUint(newlyVested, "YieldFarm::_vestUserTwa:1"),
                "YieldFarm::_vestUserTwa:2"
            );
            _transferTwa(msg.sender, newlyVested);
        }
        if (_user.vestingBlock > prevVestingBlock) {
            user.vestingBlock = _user.vestingBlock;
        }
        if (_user.lastUpdateBlock > prevUpdateBlock) {
            user.lastUpdateBlock = _user.lastUpdateBlock;
        }
    }

    /* @dev Compute the amount of TWA tokens to be entitled and vested to a user of a pool
     * ... and update the `_user` instance (in the memory):
     *   `_user.pendedTwa` gets increased by `newlyEntitled - newlyVested`
     *   `_user.vestingBlock` set to the updated value
     *   `_user.lastUpdateBlock` set to the current block
     *
     * @param _user - user to compute tokens for
     * @param accTwaPerLpt - value of the pool' `pool.accTwaPerLpt`
     * @return newlyEntitled - TWA amount to entitle (on top of tokens entitled so far)
     * @return newlyVested - TWA amount to vest (on top of tokens already vested)
     */
    function _computeTwaVesting(User memory _user, uint256 accTwaPerLpt) internal view returns (uint256 newlyEntitled, uint256 newlyVested) {
        uint32 prevBlock = _user.lastUpdateBlock;
        _user.lastUpdateBlock = _currBlock();
        if (prevBlock >= _user.lastUpdateBlock) {
            return (0, 0);
        }

        uint32 age = _user.lastUpdateBlock - prevBlock;

        // Tokens which are to be entitled starting from the `user.lastUpdateBlock`, shall be
        // vested proportionally to the number of blocks already minted within the period between
        // the `user.lastUpdateBlock` and `twaVestingPeriodInBlocks` following the current block
        newlyEntitled = uint256(_computeTwaToEntitle(_user.lptAmount, _user.twaAdjust, accTwaPerLpt));
        uint256 newToVest = newlyEntitled == 0 ? 0 : (
            newlyEntitled.mul(uint256(age)).div(uint256(age + twaVestingPeriodInBlocks))
        );

        // Tokens which have been pended since the `user.lastUpdateBlock` shall be vested:
        // - in full, if the `user.vestingBlock` has been mined
        // - otherwise, proportionally to the number of blocks already mined so far in the period
        //   between the `user.lastUpdateBlock` and the `user.vestingBlock` (not yet mined)
        uint256 pended = uint256(_user.pendedTwa);
        age = _user.lastUpdateBlock >= _user.vestingBlock
            ? twaVestingPeriodInBlocks
            : _user.lastUpdateBlock - prevBlock;
        uint256 pendedToVest = pended == 0 ? 0 : (
            age >= twaVestingPeriodInBlocks
                ? pended
                : pended.mul(uint256(age)).div(uint256(_user.vestingBlock - prevBlock))
        );

        newlyVested = pendedToVest.add(newToVest);
        _user.pendedTwa = SafeMath96.fromUint(
            uint256(_user.pendedTwa).add(newlyEntitled).sub(newlyVested),
            "YieldFarm::computeTwaVest:1"
        );

        // Amount of TWA token pended (i.e. not yet vested) from now
        uint256 remainingPended = pended == 0 ? 0 : pended.sub(pendedToVest);
        uint256 unreleasedNewly = newlyEntitled == 0 ? 0 : newlyEntitled.sub(newToVest);
        uint256 pending = remainingPended.add(unreleasedNewly);

        // Compute the vesting block (i.e. when the pended tokens to be all vested)
        uint256 period = 0;
        if (remainingPended == 0 || pending == 0) {
            // newly entitled TWAs only or nothing remain pended
            period = twaVestingPeriodInBlocks;
        } else {
            // "old" TWAs and, perhaps, "new" TWAs are pending - the weighted average applied
            age = _user.vestingBlock - _user.lastUpdateBlock;
            period = (
                (remainingPended.mul(age))
                .add(unreleasedNewly.mul(twaVestingPeriodInBlocks))
            ).div(pending);
        }
        _user.vestingBlock = _user.lastUpdateBlock + (
            twaVestingPeriodInBlocks > uint32(period) ? uint32(period) : twaVestingPeriodInBlocks
        );

        return (newlyEntitled, newlyVested);
    }

    function _getTwaPerBlock(uint256 blockNum) internal view returns(uint256 twaPerBlock) {
        if (startBlock <= blockNum && blockNum < startBlock.add(91000)) { // first phase less than around 14 days
            return 1923076923076923076; //1.923076923076923076
        }
        if (startBlock.add(91000) <= blockNum && blockNum < (startBlock.add(91000).add(390000))) { // second phase less than around 2 months
            return 192307692307692307; //0.192307692307692307
        }
        if ((startBlock.add(91000).add(390000)) <= blockNum && blockNum < (startBlock.add(91000).add(390000).add(4745000))) { // third phase less than around 2 years
            return 73761854583772391; // 0.073761854583772392
        }
        return 0;
    }

    function getCurrentTwaPerBlock() external view returns(uint256 twaPerBlock) {
        return _getTwaPerBlock(_currBlock());
    }

    function _computePoolReward(Pool memory _pool) internal view returns (uint256 poolTwaReward) {
        poolTwaReward = 0;
        uint32 blockNum = _currBlock();
        uint256 twaPerBlock = _getTwaPerBlock(blockNum);
        if (blockNum > _pool.lastUpdateBlock) {
            uint256 multiplier = uint256(blockNum - _pool.lastUpdateBlock); // can't overflow
            _pool.lastUpdateBlock = blockNum;

            uint256 lptBalance = _pool.lpToken.balanceOf(address(this));
            if (lptBalance != 0) {
                poolTwaReward = multiplier
                    .mul(uint256(twaPerBlock))
                    .mul(uint256(_pool.allocPoint))
                    .div(totalAllocPoint);

                _pool.accTwaPerLpt = _pool.accTwaPerLpt.add(poolTwaReward.mul(SCALE).div(lptBalance));
            }
        }
    }

    function _computeUserVotes(uint192 userData, uint192 sharedData) internal override pure returns (uint96 votes) {
        (uint96 ownTwa, uint96 pooledTwaShare) = _unpackData(userData);
        (uint96 totalPooledTwa, ) = _unpackData(sharedData);

        if (pooledTwaShare == 0) {
            votes = ownTwa;
        } else {
            uint256 pooledTwa = uint256(pooledTwaShare).mul(totalPooledTwa).div(SCALE);
            votes = ownTwa.add(SafeMath96.fromUint(pooledTwa, "YieldFarm::_computeVotes"));
        }
    }

    function _computeTwaToEntitle(uint256 userLpt, uint96 userTwaAdjust, uint256 poolAccTwaPerLpt) private pure returns (uint96) {
        return userLpt == 0 ? 0 : (
            SafeMath96.fromUint(userLpt.mul(poolAccTwaPerLpt).div(SCALE), "YieldFarm::computeTwa:1")
                .sub(userTwaAdjust, "YieldFarm::computeTwa:2")
        );
    }

    function _computeTwaAdjustment(uint256 lptAmount, uint256 accTwaPerLpt) private pure returns (uint96) {
        return SafeMath96.fromUint(
            lptAmount.mul(accTwaPerLpt).div(SCALE),
            "YieldFarm::_computeTwaAdj"
        );
    }

    function _validatePoolId(uint256 pid) private view {
        require(pid < pools.length, "YieldFarm: invalid pool id");
    }

    function _currBlock() private view returns (uint32) {
        return SafeMath32.fromUint(block.number, "YieldFarm::_currBlock:overflow");
    }
}