/**
 *Submitted for verification at Etherscan.io on 2020-10-16
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
/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */


// 
/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transfered from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// 
/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
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


// 
contract HoneycombV2 is Ownable, IERC721Receiver {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  // Info of each user.
  struct UserInfo {
    uint256 amount;     // How many LP tokens the user has provided.
    uint256 rewardDebt; // Reward debt.
    uint earned;        // Earned HONEY.
    bool propEnabled;
    uint256 propTokenId;
  }

  // Info of each pool.
  struct PoolInfo {
    IERC20 lpToken;           // Address of LP token contract.
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
    address prop;
    address propDict;
  }

  // Info of each batch
  BatchInfo[] public batchInfo;
  // Info of each pool at specified batch.
  mapping (uint256 => PoolInfo[]) public poolInfo;
  // Info of each user at specified batch and pool
  mapping (uint256 => mapping (uint256 => mapping (address => UserInfo))) public userInfo;

  IERC20 public honeyToken;

  event Deposit(address indexed user, uint256 indexed batch, uint256 indexed pid, uint256 amount);
  event Withdraw(address indexed user, uint256 indexed batch, uint256 indexed pid, uint256 amount);
  event EmergencyWithdraw(address indexed user, uint256 indexed batch, uint256 indexed pid, uint256 amount);
  event DepositProp(address indexed user, uint256 indexed batch, uint256 indexed pid, uint256 propTokenId);
  event WithdrawProp(address indexed user, uint256 indexed batch, uint256 indexed pid, uint256 propTokenId);

  constructor (address _honeyToken) public {
    honeyToken = IERC20(_honeyToken);
  }

  function addBatch(uint256 startBlock, uint256 endBlock, uint256 honeyPerBlock, address prop, address propDict) public onlyOwner {
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
      totalAllocPoint: 0,
      prop: prop,
      propDict: propDict
    }));
  }

  function addPool(uint256 batch, IERC20 lpToken, uint256 multiplier) public onlyOwner {
    require(batch < batchInfo.length, "batch must exist");
    
    BatchInfo storage targetBatch = batchInfo[batch];
    if (targetBatch.startBlock <= block.number && block.number < targetBatch.endBlock) {
      updateAllPools(batch);
    }

    uint256 lastRewardBlock = block.number > targetBatch.startBlock ? block.number : targetBatch.startBlock;
    batchInfo[batch].totalAllocPoint = targetBatch.totalAllocPoint.add(multiplier);
    poolInfo[batch].push(PoolInfo({
      lpToken: lpToken,
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
  function pendingHoney(uint256 batch, uint256 pid, address account) external view returns (uint256) {
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

    uint256 power = 100;
    if (user.propEnabled) {
      IHoneyPropDict propDict = IHoneyPropDict(targetBatch.propDict);
      power = propDict.getMiningMultiplier(user.propTokenId);
    }
    return user.amount.mul(power).div(100).mul(accHoneyPerShare).div(1e12).sub(user.rewardDebt);
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

  // Deposit LP tokens for HONEY allocation.
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
    uint256 power = 100;
    if (user.propEnabled) {
      IHoneyPropDict propDict = IHoneyPropDict(targetBatch.propDict);
      power = propDict.getMiningMultiplier(user.propTokenId);
    }
    if (user.amount > 0) {
      uint256 pending = user.amount;
      if (user.propEnabled) {
        pending = pending.mul(power).div(100);
      }
      pending = pending.mul(pool.accHoneyPerShare).div(1e12).sub(user.rewardDebt);
      if (pending > 0) {
        safeHoneyTransfer(batch, pid, msg.sender, pending);
      }
    }

    // 3. Transfer LP Token from user to honeycomb
    if (amount > 0) {
      pool.lpToken.safeTransferFrom(address(msg.sender), address(this), amount);
      user.amount = user.amount.add(amount);
    }

    // 4. Update pool.totalShares & user.rewardDebt
    if (user.propEnabled) {
      pool.totalShares = pool.totalShares.add(amount.mul(power).div(100));
      user.rewardDebt = user.amount.mul(power).div(100).mul(pool.accHoneyPerShare).div(1e12);
    } else {
      pool.totalShares = pool.totalShares.add(amount);
      user.rewardDebt = user.amount.mul(pool.accHoneyPerShare).div(1e12);
    }

    emit Deposit(msg.sender, batch, pid, amount);
  }

  // Withdraw LP tokens.
  function withdraw(uint256 batch, uint256 pid, uint256 amount) public {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");
    UserInfo storage user = userInfo[batch][pid][msg.sender];
    require(user.amount >= amount, "insufficient balance");

    // 1. Update pool.accHoneyPerShare
    updatePool(batch, pid);

    // 2. Transfer pending HONEY to user
    BatchInfo storage targetBatch = batchInfo[batch];
    PoolInfo storage pool = poolInfo[batch][pid];
    uint256 pending = user.amount;
    uint256 power = 100;
    if (user.propEnabled) {
      IHoneyPropDict propDict = IHoneyPropDict(targetBatch.propDict);
      power = propDict.getMiningMultiplier(user.propTokenId);
      pending = pending.mul(power).div(100);
    }
    pending = pending.mul(pool.accHoneyPerShare).div(1e12).sub(user.rewardDebt);
    if (pending > 0) {
      safeHoneyTransfer(batch, pid, msg.sender, pending);
    }

    // 3. Transfer LP Token from honeycomb to user
    pool.lpToken.safeTransfer(address(msg.sender), amount);
    user.amount = user.amount.sub(amount);

    // 4. Update pool.totalShares & user.rewardDebt
    if (user.propEnabled) {
      pool.totalShares = pool.totalShares.sub(amount.mul(power).div(100));
      user.rewardDebt = user.amount.mul(power).div(100).mul(pool.accHoneyPerShare).div(1e12);
    } else {
      pool.totalShares = pool.totalShares.sub(amount);
      user.rewardDebt = user.amount.mul(pool.accHoneyPerShare).div(1e12);
    }
    
    emit Withdraw(msg.sender, batch, pid, amount);
  }

  // Withdraw without caring about rewards. EMERGENCY ONLY.
  function emergencyWithdraw(uint256 batch, uint256 pid) public {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    PoolInfo storage pool = poolInfo[batch][pid];
    UserInfo storage user = userInfo[batch][pid][msg.sender];
    pool.lpToken.safeTransfer(address(msg.sender), user.amount);
    emit EmergencyWithdraw(msg.sender, batch, pid, user.amount);
    user.amount = 0;
    user.rewardDebt = 0;
  }

  function depositProp(uint256 batch, uint256 pid, uint256 propTokenId) public {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    UserInfo storage user = userInfo[batch][pid][msg.sender];
    require(!user.propEnabled, "another prop is already enabled");

    BatchInfo storage targetBatch = batchInfo[batch];
    IERC721 propToken = IERC721(targetBatch.prop);
    require(propToken.ownerOf(propTokenId) == address(msg.sender), "must be the prop's owner");

    // 1. Update pool.accHoneyPerShare
    updatePool(batch, pid);

    // 2. Transfer pending HONEY to user
    PoolInfo storage pool = poolInfo[batch][pid];
    if (user.amount > 0) {
      uint256 pending = user.amount.mul(pool.accHoneyPerShare).div(1e12);
      pending = pending.sub(user.rewardDebt);
      if (pending > 0) {
        safeHoneyTransfer(batch, pid, msg.sender, pending);
      }
    }

    // 3. Transfer Prop from user to honeycomb
    propToken.safeTransferFrom(address(msg.sender), address(this), propTokenId);
    user.propEnabled = true;
    user.propTokenId = propTokenId;

    // 4. Update pool.totalShares & user.rewardDebt
    IHoneyPropDict propDict = IHoneyPropDict(targetBatch.propDict);
    uint256 power = propDict.getMiningMultiplier(user.propTokenId);
    pool.totalShares = pool.totalShares.sub(user.amount);
    pool.totalShares = pool.totalShares.add(user.amount.mul(power).div(100));
    user.rewardDebt = user.amount.mul(power).div(100).mul(pool.accHoneyPerShare).div(1e12);

    emit DepositProp(msg.sender, batch, pid, propTokenId);
  }

  function withdrawProp(uint256 batch, uint256 pid, uint256 propTokenId) public {
    require(batch < batchInfo.length, "batch must exist");
    require(pid < poolInfo[batch].length, "pool must exist");

    UserInfo storage user = userInfo[batch][pid][msg.sender];
    require(user.propEnabled, "no prop is yet enabled");
    require(propTokenId == user.propTokenId, "must be the owner of the prop");

    BatchInfo storage targetBatch = batchInfo[batch];
    IERC721 propToken = IERC721(targetBatch.prop);
    require(propToken.ownerOf(propTokenId) == address(this), "the prop is not staked");

    // 1. Update pool.accHoneyPerShare
    updatePool(batch, pid);

    // 2. Transfer pending HONEY to user
    PoolInfo storage pool = poolInfo[batch][pid];
    IHoneyPropDict propDict = IHoneyPropDict(targetBatch.propDict);
    uint256 power = propDict.getMiningMultiplier(user.propTokenId);
    uint256 pending = user.amount.mul(power).div(100);
    pending = pending.mul(pool.accHoneyPerShare).div(1e12);
    pending = pending.sub(user.rewardDebt);
    if (pending > 0) {
      safeHoneyTransfer(batch, pid, msg.sender, pending);
    }

    // 3. Transfer Prop from honeycomb to user
    propToken.safeTransferFrom(address(this), address(msg.sender), propTokenId);
    user.propEnabled = false;
    user.propTokenId = 0;
  
    // 4. Update pool.totalShares & user.rewardDebt
    pool.totalShares = pool.totalShares.sub(user.amount.mul(power).div(100));
    pool.totalShares = pool.totalShares.add(user.amount);
    user.rewardDebt = user.amount.mul(pool.accHoneyPerShare).div(1e12);

    emit WithdrawProp(msg.sender, batch, pid, propTokenId);
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
      require(address(poolFrom.lpToken) == address(poolTo.lpToken), "must be the same token");
      withdraw(fromBatch, fromPid, amount);
      deposit(toBatch, toPid, amount);
    }
  }

  function migrateProp(uint256 toBatch, uint256 toPid, uint256 propTokenId, uint256 fromBatch, uint256 fromPid) public {
    require(toBatch < batchInfo.length, "target batch must exist");
    require(toPid < poolInfo[toBatch].length, "target pool must exist");
    require(fromBatch < batchInfo.length, "source batch must exist");
    require(fromPid < poolInfo[fromBatch].length, "source pool must exist");

    BatchInfo storage sourceBatch = batchInfo[fromBatch];
    BatchInfo storage targetBatch = batchInfo[toBatch];
    require(block.number < targetBatch.endBlock, "batch ended");
    require(targetBatch.prop == sourceBatch.prop, "prop not compatible");
    require(targetBatch.propDict == sourceBatch.propDict, "propDict not compatible");
    UserInfo storage userFrom = userInfo[fromBatch][fromPid][msg.sender];
    require(userFrom.propEnabled, "no prop is yet enabled");
    require(propTokenId == userFrom.propTokenId, "propTokenId not yours");
    UserInfo storage userTo = userInfo[toBatch][toPid][msg.sender];
    require(!userTo.propEnabled, "another prop is already enabled");

    withdrawProp(fromBatch, fromPid, propTokenId);
    depositProp(toBatch, toPid, propTokenId);
  }

  // Safe honey transfer function, just in case if rounding error causes pool to not have enough HONEYs.
  function safeHoneyTransfer(uint256 batch, uint256 pid, address to, uint256 amount) internal {
    uint256 honeyBal = honeyToken.balanceOf(address(this));
    require(honeyBal > 0, "insufficient HONEY balance");

    UserInfo storage user = userInfo[batch][pid][to];
    if (amount > honeyBal) {
      honeyToken.transfer(to, honeyBal);
      user.earned = user.earned.add(honeyBal);
    } else {
      honeyToken.transfer(to, amount);
      user.earned = user.earned.add(amount);
    }
  }

  function onERC721Received(address, address, uint256, bytes calldata) external override returns(bytes4) {
    return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
  }
}