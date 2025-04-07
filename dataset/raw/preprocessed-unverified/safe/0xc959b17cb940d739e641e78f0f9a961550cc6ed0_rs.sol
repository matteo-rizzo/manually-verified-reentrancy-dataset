/**
 *Submitted for verification at Etherscan.io on 2020-10-30
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
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


// 
/**
 * @dev Collection of functions related to the address type
 */


// 
/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */


// 
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

// 
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

// 
contract HoneycombV3 is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  // Info of each user.
  struct UserInfo {
    uint256 amount;     // How many staking tokens the user has provided.
    uint256 rewardDebt; // Reward debt.
    uint256 mined;
    uint256 collected;
  }

  struct CollectingInfo {
    uint256 collectableTime;
    uint256 amount;
    bool collected;
  }

  // Info of each pool.
  struct PoolInfo {
    IERC20 stakingToken;           // Address of staking token contract.
    uint256 allocPoint;       // How many allocation points assigned to this pool.
    uint256 lastRewardBlock;  // Last block number that HONEYs distribution occurs.
    uint256 accHoneyPerShare; // Accumulated HONEYs per share, times 1e12.
    uint256 totalShares;
  }

  struct BatchInfo {
    uint256 startBlock;
    uint256 endBlock;
    uint256 honeyPerBlock;
    uint256 totalAllocPoint;
  }

  // Info of each batch
  BatchInfo[] public batchInfo;
  // Info of each pool at specified batch.
  mapping (uint256 => PoolInfo[]) public poolInfo;
  // Info of each user at specified batch and pool
  mapping (uint256 => mapping (uint256 => mapping (address => UserInfo))) public userInfo;
  mapping (uint256 => mapping (uint256 => mapping (address => CollectingInfo[]))) public collectingInfo;

  IERC20 public honeyToken;
  uint256 public collectingDuration = 86400 * 3;
  uint256 public instantCollectBurnRate = 4000; // 40%
  address public burnDestination;

  event Deposit(address indexed user, uint256 indexed batch, uint256 indexed pid, uint256 amount);
  event Withdraw(address indexed user, uint256 indexed batch, uint256 indexed pid, uint256 amount);
  event EmergencyWithdraw(address indexed user, uint256 indexed batch, uint256 indexed pid, uint256 amount);

  constructor (address _honeyToken, address _burnDestination) public {
    honeyToken = IERC20(_honeyToken);
    burnDestination = _burnDestination;
  }

  function addBatch(uint256 startBlock, uint256 endBlock, uint256 honeyPerBlock) public onlyOwner {
    require(endBlock > startBlock, "endBlock should be larger than startBlock");
    require(endBlock > block.number, "endBlock should be larger than the current block number");
    require(startBlock > block.number, "startBlock should be larger than the current block number");
    
    if (batchInfo.length > 0) {
      uint256 lastEndBlock = batchInfo[batchInfo.length - 1].endBlock;
      require(startBlock >= lastEndBlock, "startBlock should be >= the endBlock of the last batch");
    }

    uint256 senderHoneyBalance = honeyToken.balanceOf(address(msg.sender));
    uint256 requiredHoney = endBlock.sub(startBlock).mul(honeyPerBlock);
    require(senderHoneyBalance >= requiredHoney, "insufficient HONEY for the batch");

    honeyToken.safeTransferFrom(address(msg.sender), address(this), requiredHoney);
    batchInfo.push(BatchInfo({
      startBlock: startBlock,
      endBlock: endBlock,
      honeyPerBlock: honeyPerBlock,
      totalAllocPoint: 0
    }));
  }

  function addPool(uint256 batch, IERC20 stakingToken, uint256 multiplier) public onlyOwner {
    require(batch < batchInfo.length, "batch must exist");
    
    BatchInfo storage targetBatch = batchInfo[batch];
    if (targetBatch.startBlock <= block.number && block.number < targetBatch.endBlock) {
      updateAllPools(batch);
    }

    uint256 lastRewardBlock = block.number > targetBatch.startBlock ? block.number : targetBatch.startBlock;
    batchInfo[batch].totalAllocPoint = targetBatch.totalAllocPoint.add(multiplier);
    poolInfo[batch].push(PoolInfo({
      stakingToken: stakingToken,
      allocPoint: multiplier,
      lastRewardBlock: lastRewardBlock,
      accHoneyPerShare: 0,
      totalShares: 0
    }));
  }

  // Return rewardable block count over the given _from to _to block.
  function getPendingBlocks(uint256 batch, uint256 from, uint256 to) public view returns (uint256) {
    require(batch < batchInfo.length, "batch must exist");   
 
    BatchInfo storage targetBatch = batchInfo[batch];

    if (to < targetBatch.startBlock) {
      return 0;
    }
    
    if (to > targetBatch.endBlock) {
      if (from > targetBatch.endBlock) {
        return 0;
      } else {
        return targetBatch.endBlock.sub(from);
      }
    } else {
      return to.sub(from);
    }
  }

  // View function to see pending HONEYs on frontend.
  function minedHoney(uint256 batch, uint256 pid, address account) external view returns (uint256) {
    require(batch < batchInfo.length, "batch must exist");   
    require(pid < poolInfo[batch].length, "pool must exist");
    BatchInfo storage targetBatch = batchInfo[batch];

    if (block.number < targetBatch.startBlock) {
      return 0;
    }

    PoolInfo storage pool = poolInfo[batch][pid];
    UserInfo storage user = userInfo[batch][pid][account];
    uint256 accHoneyPerShare = pool.accHoneyPerShare;
    if (block.number > pool.lastRewardBlock && pool.totalShares != 0) {
      uint256 pendingBlocks = getPendingBlocks(batch, pool.lastRewardBlock, block.number);
      uint256 honeyReward = pendingBlocks.mul(targetBatch.honeyPerBlock).mul(pool.allocPoint).div(targetBatch.totalAllocPoint);
      accHoneyPerShare = accHoneyPerShare.add(honeyReward.mul(1e12).div(pool.totalShares));
    }
    return user.amount.mul(accHoneyPerShare).div(1e12).sub(user.rewardDebt).add(user.mined);
  }

  function updateAllPools(uint256 batch) public {
    require(batch < batchInfo.length, "batch must exist");

    uint256 length = poolInfo[batch].length;
    for (uint256 pid = 0; pid < length; ++pid) {
      updatePool(batch, pid);
    }
  }

  // Update reward variables of the given pool to be up-to-date.
  function updatePool(uint256 batch, uint256 pid) public {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    BatchInfo storage targetBatch = batchInfo[batch];
    PoolInfo storage pool = poolInfo[batch][pid];

    if (block.number < targetBatch.startBlock || block.number <= pool.lastRewardBlock || pool.lastRewardBlock > targetBatch.endBlock) {
      return;
    }
    if (pool.totalShares == 0) {
      pool.lastRewardBlock = block.number;
      return;
    }
    uint256 pendingBlocks = getPendingBlocks(batch, pool.lastRewardBlock, block.number);
    uint256 honeyReward = pendingBlocks.mul(targetBatch.honeyPerBlock).mul(pool.allocPoint).div(targetBatch.totalAllocPoint);
    pool.accHoneyPerShare = pool.accHoneyPerShare.add(honeyReward.mul(1e12).div(pool.totalShares));
    pool.lastRewardBlock = block.number;
  }

  // Deposit staking tokens for HONEY allocation.
  function deposit(uint256 batch, uint256 pid, uint256 amount) public {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    BatchInfo storage targetBatch = batchInfo[batch];

    require(block.number < targetBatch.endBlock, "batch ended");

    PoolInfo storage pool = poolInfo[batch][pid];
    UserInfo storage user = userInfo[batch][pid][msg.sender];

    // 1. Update pool.accHoneyPerShare
    updatePool(batch, pid);

    // 2. Transfer pending HONEY to user
    if (user.amount > 0) {
      uint256 pending = user.amount.mul(pool.accHoneyPerShare).div(1e12).sub(user.rewardDebt);
      if (pending > 0) {
        addToMined(batch, pid, msg.sender, pending);
      }
    }

    // 3. Transfer Staking Token from user to honeycomb
    if (amount > 0) {
      pool.stakingToken.safeTransferFrom(address(msg.sender), address(this), amount);
      user.amount = user.amount.add(amount);
    }

    // 4. Update user.rewardDebt
    pool.totalShares = pool.totalShares.add(amount);
    user.rewardDebt = user.amount.mul(pool.accHoneyPerShare).div(1e12);
    emit Deposit(msg.sender, batch, pid, amount);
  }

  // Withdraw staking tokens.
  function withdraw(uint256 batch, uint256 pid, uint256 amount) public {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");
    UserInfo storage user = userInfo[batch][pid][msg.sender];
    require(user.amount >= amount, "insufficient balance");

    // 1. Update pool.accHoneyPerShare
    updatePool(batch, pid);

    // 2. Transfer pending HONEY to user
    PoolInfo storage pool = poolInfo[batch][pid];
    uint256 pending = user.amount.mul(pool.accHoneyPerShare).div(1e12).sub(user.rewardDebt);
    if (pending > 0) {
      addToMined(batch, pid, msg.sender, pending);
    }

    // 3. Transfer Staking Token from honeycomb to user
    pool.stakingToken.safeTransfer(address(msg.sender), amount);
    user.amount = user.amount.sub(amount);

    // 4. Update user.rewardDebt
    pool.totalShares = pool.totalShares.sub(amount);
    user.rewardDebt = user.amount.mul(pool.accHoneyPerShare).div(1e12);
    emit Withdraw(msg.sender, batch, pid, amount);
  }

  // Withdraw without caring about rewards. EMERGENCY ONLY.
  function emergencyWithdraw(uint256 batch, uint256 pid) public {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    PoolInfo storage pool = poolInfo[batch][pid];
    UserInfo storage user = userInfo[batch][pid][msg.sender];
    pool.stakingToken.safeTransfer(address(msg.sender), user.amount);
    emit EmergencyWithdraw(msg.sender, batch, pid, user.amount);
    user.amount = 0;
    user.rewardDebt = 0;
  }

  function migrate(uint256 toBatch, uint256 toPid, uint256 amount, uint256 fromBatch, uint256 fromPid) public {
    require(toBatch < batchInfo.length, "target batch must exist");
    require(toPid < poolInfo[toBatch].length, "target pool must exist");
    require(fromBatch < batchInfo.length, "source batch must exist");
    require(fromPid < poolInfo[fromBatch].length, "source pool must exist");

    BatchInfo storage targetBatch = batchInfo[toBatch];
    require(block.number < targetBatch.endBlock, "batch ended");

    UserInfo storage userFrom = userInfo[fromBatch][fromPid][msg.sender];
    if (userFrom.amount > 0) {
      PoolInfo storage poolFrom = poolInfo[fromBatch][fromPid];
      PoolInfo storage poolTo = poolInfo[toBatch][toPid];
      require(address(poolFrom.stakingToken) == address(poolTo.stakingToken), "must be the same token");
      withdraw(fromBatch, fromPid, amount);
      deposit(toBatch, toPid, amount);
    }
  }

  // Safe honey transfer function, just in case if rounding error causes pool to not have enough HONEYs.
  function safeHoneyTransfer(uint256 batch, uint256 pid, address to, uint256 amount) internal {
    uint256 honeyBal = honeyToken.balanceOf(address(this));
    require(honeyBal > 0, "insufficient HONEY balance");

    UserInfo storage user = userInfo[batch][pid][to];
    if (amount > honeyBal) {
      honeyToken.transfer(to, honeyBal);
      user.collected = user.collected.add(honeyBal);
    } else {
      honeyToken.transfer(to, amount);
      user.collected = user.collected.add(amount);
    }
  }

  function addToMined(uint256 batch, uint256 pid, address account, uint256 amount) internal {
    UserInfo storage user = userInfo[batch][pid][account];
    user.mined = user.mined.add(amount);
  }

  function startCollecting(uint256 batch, uint256 pid) external {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    withdraw(batch, pid, 0);
    
    UserInfo storage user = userInfo[batch][pid][msg.sender];
    CollectingInfo[] storage collecting = collectingInfo[batch][pid][msg.sender];

    if (user.mined > 0) {
      collecting.push(CollectingInfo({
        collectableTime: block.timestamp + collectingDuration,
        amount: user.mined,
        collected: false
      }));
      user.mined = 0;
    }
  }

  function collectingHoney(uint256 batch, uint256 pid, address account) external view returns (uint256) {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    CollectingInfo[] storage collecting = collectingInfo[batch][pid][account];
    uint256 total = 0;
    for (uint i = 0; i < collecting.length; ++i) {
      if (!collecting[i].collected && block.timestamp < collecting[i].collectableTime) {
        total = total.add(collecting[i].amount);
      }
    }
    return total;
  }

  function collectableHoney(uint256 batch, uint256 pid, address account) external view returns (uint256) {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    CollectingInfo[] storage collecting = collectingInfo[batch][pid][account];
    uint256 total = 0;
    for (uint i = 0; i < collecting.length; ++i) {
      if (!collecting[i].collected && block.timestamp >= collecting[i].collectableTime) {
        total = total.add(collecting[i].amount);
      }
    }
    return total;
  }

  function collectHoney(uint256 batch, uint256 pid) external {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    CollectingInfo[] storage collecting = collectingInfo[batch][pid][msg.sender];
    require(collecting.length > 0, "nothing to collect");

    uint256 total = 0;
    for (uint i = 0; i < collecting.length; ++i) {
      if (!collecting[i].collected && block.timestamp >= collecting[i].collectableTime) {
        total = total.add(collecting[i].amount);
        collecting[i].collected = true;
      }
    }

    safeHoneyTransfer(batch, pid, msg.sender, total);
  }

  function instantCollectHoney(uint256 batch, uint256 pid) external {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    withdraw(batch, pid, 0);
    
    UserInfo storage user = userInfo[batch][pid][msg.sender];
    if (user.mined > 0) {
      uint256 portion = 10000 - instantCollectBurnRate;
      safeHoneyTransfer(batch, pid, msg.sender, user.mined.mul(portion).div(10000));
      honeyToken.transfer(burnDestination, user.mined.mul(instantCollectBurnRate).div(10000));
      user.mined = 0;
    }
  }

  function setInstantCollectBurnRate(uint256 value) public onlyOwner {
    require(value <= 10000, "Value range: 0 ~ 10000");
    instantCollectBurnRate = value;
  }

  function setCollectingDuration(uint256 value) public onlyOwner {
    collectingDuration = value;
  }
}