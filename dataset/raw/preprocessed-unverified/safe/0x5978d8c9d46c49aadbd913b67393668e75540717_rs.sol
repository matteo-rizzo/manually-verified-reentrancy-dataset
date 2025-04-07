/**
 *Submitted for verification at Etherscan.io on 2021-02-25
*/

pragma solidity 0.5.8;

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
contract Context {
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
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
  mapping (address => bool) public farmAddresses;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev Initializes the contract setting the deployer as the initial owner.
   */
  constructor() internal {
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
    require(_owner == _msgSender(), 'Ownable: caller is not the owner');
    _;
  }

  modifier onlyFarmContract() {
    require(isOwner() || isFarmContract(), 'Ownable: caller is not the farm or owner');
    _;
  }

  function isOwner() private view returns (bool) {
    return _owner == _msgSender();
  }

  function isFarmContract() public view returns (bool) {
    return farmAddresses[_msgSender()];
  }

  /**
   * @dev Transfers ownership of the contract to a new account (`newOwner`).
   * Can only be called by the current owner.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(
      newOwner != address(0),
      'Ownable: new owner is the zero address'
    );
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  function setFarmAddress(address _farmAddress, bool _status) public onlyOwner {
    require(
      _farmAddress != address(0),
      'Ownable: farm address is the zero address'
    );
    farmAddresses[_farmAddress] = _status;
  }
}

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


contract EtherGalaxy is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
  }

  struct PoolInfo {
    IERC20 lpToken;
    uint256 allocPoint;
    uint256 lastRewardBlock;
    uint256 accEtherPerShare;
  }

  uint256 public bonusEndBlock;
  uint256 public rewardsEndBlock;
  uint256 public constant ethPerBlock = 57870370370370 wei; // 10ETH / 172800 blocks
  uint256 public constant BONUS_MULTIPLIER = 3;

  PoolInfo[] public poolInfo;
  mapping(address => bool) public lpTokenExistsInPool;
  mapping(uint256 => mapping(address => UserInfo)) public userInfo;
  uint256 public totalAllocPoint;
  uint256 public startBlock;

  uint256 public constant blockIn2Weeks = 80640;
  uint256 public constant blockIn2Years = 4204800;

  event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
  event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
  event EmergencyWithdraw(
    address indexed user,
    uint256 indexed pid,
    uint256 amount
  );

  constructor(
  ) public {
    startBlock = block.number;
    bonusEndBlock = startBlock + blockIn2Weeks;
    rewardsEndBlock = startBlock + blockIn2Years;
  }

  function () external payable {}

  function poolLength() external view returns (uint256) {
    return poolInfo.length;
  }

  function add(
    uint256 _allocPoint,
    IERC20 _lpToken,
    bool _withUpdate
  ) public onlyOwner {
    require(
      !lpTokenExistsInPool[address(_lpToken)],
      'Galaxy: LP Token Address already exists in pool'
    );
    if (_withUpdate) {
      massUpdatePools();
    }
    uint256 blockNumber = min(block.number, rewardsEndBlock);
    uint256 lastRewardBlock = blockNumber > startBlock
    ? blockNumber
    : startBlock;
    totalAllocPoint = totalAllocPoint.add(_allocPoint);
    poolInfo.push(
      PoolInfo({
      lpToken: _lpToken,
      allocPoint: _allocPoint,
      lastRewardBlock: lastRewardBlock,
      accEtherPerShare: 0
      })
    );
    lpTokenExistsInPool[address(_lpToken)] = true;
  }

  function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
    if (_withUpdate) {
      massUpdatePools();
    }
    totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
    poolInfo[_pid].allocPoint = _allocPoint;
  }

  function getMultiplier(uint256 _from, uint256 _to)
  public
  view
  returns (uint256)
  {
    if (_to <= bonusEndBlock) {
      return _to.sub(_from).mul(BONUS_MULTIPLIER);
    } else if (_from >= bonusEndBlock) {
      return _to.sub(_from);
    } else {
      return
      bonusEndBlock.sub(_from).mul(BONUS_MULTIPLIER).add(
        _to.sub(bonusEndBlock)
      );
    }
  }

  function pendingEther(uint256 _pid, address _user)
  external
  view
  returns (uint256)
  {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][_user];
    uint256 accEtherPerShare = pool.accEtherPerShare;
    uint256 blockNumber = min(block.number, rewardsEndBlock);
    uint256 lpSupply = pool.lpToken.balanceOf(address(this));
    if (blockNumber > pool.lastRewardBlock && lpSupply != 0) {
      uint256 multiplier = getMultiplier(
        pool.lastRewardBlock,
        blockNumber
      );
      uint256 etherReward = multiplier
      .mul(ethPerBlock)
      .mul(pool.allocPoint)
      .div(totalAllocPoint);
      accEtherPerShare = accEtherPerShare.add(
        etherReward.mul(1e12).div(lpSupply)
      );
    }
    return user.amount.mul(accEtherPerShare).div(1e12).sub(user.rewardDebt);
  }

  function massUpdatePools() public {
    uint256 length = poolInfo.length;
    for (uint256 pid = 0; pid < length; ++pid) {
      updatePool(pid);
    }
  }

  function updatePool(uint256 _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    uint256 blockNumber = min(block.number, rewardsEndBlock);
    if (blockNumber <= pool.lastRewardBlock) {
      return;
    }
    uint256 lpSupply = pool.lpToken.balanceOf(address(this));
    if (lpSupply == 0) {
      pool.lastRewardBlock = blockNumber;
      return;
    }
    uint256 multiplier = getMultiplier(pool.lastRewardBlock, blockNumber);
    uint256 etherReward = multiplier
    .mul(ethPerBlock)
    .mul(pool.allocPoint)
    .div(totalAllocPoint);
    pool.accEtherPerShare = pool.accEtherPerShare.add(
      etherReward.mul(1e12).div(lpSupply)
    );
    pool.lastRewardBlock = blockNumber;
  }

  function deposit(uint256 _pid, uint256 _amount) public {
    require(_amount > 0, 'Galaxy: invalid amount');
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    updatePool(_pid);
    if (user.amount > 0) {
      uint256 pending = user.amount.mul(pool.accEtherPerShare).div(1e12).sub(user.rewardDebt);
      if (pending > 0) {
        safeEtherTransfer(msg.sender, pending);
      }
    }
    pool.lpToken.safeTransferFrom(
      address(msg.sender),
      address(this),
      _amount
    );
    user.amount = user.amount.add(_amount);
    user.rewardDebt = user.amount.mul(pool.accEtherPerShare).div(1e12);
    emit Deposit(msg.sender, _pid, _amount);
  }

  function withdraw(uint256 _pid, uint256 _amount) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    require(user.amount >= _amount, 'Galaxy: Insufficient Amount to withdraw');
    updatePool(_pid);
    uint256 pending = user.amount.mul(pool.accEtherPerShare).div(1e12).sub(user.rewardDebt);
    if(pending > 0) {
      safeEtherTransfer(msg.sender, pending);
    }
    if(_amount > 0) {
      user.amount = user.amount.sub(_amount);
      pool.lpToken.safeTransfer(address(msg.sender), _amount);
    }
    user.rewardDebt = user.amount.mul(pool.accEtherPerShare).div(1e12);
    emit Withdraw(msg.sender, _pid, _amount);
  }

  function emergencyWithdraw(uint256 _pid) public {
    PoolInfo storage pool = poolInfo[_pid];
    UserInfo storage user = userInfo[_pid][msg.sender];
    uint256 amount = user.amount;
    require(amount > 0, 'Galaxy: insufficient balance');
    user.amount = 0;
    user.rewardDebt = 0;
    pool.lpToken.safeTransfer(address(msg.sender), amount);
    emit EmergencyWithdraw(msg.sender, _pid, amount);
  }

  function safeEtherTransfer(address payable _to, uint256 _amount) internal {
    if (address(this).balance >= _amount) {
      _to.transfer(_amount);
    } else {
      _to.transfer(address(this).balance);
    }
  }

  function areRewardsActive() public view returns (bool) {
    return rewardsEndBlock > block.number;
  }

  function min(uint256 a, uint256 b) public pure returns (uint256) {
    if (a > b) {
      return b;
    }
    return a;
  }
}