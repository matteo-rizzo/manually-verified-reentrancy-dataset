/**
 *Submitted for verification at Etherscan.io on 2021-09-10
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


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
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
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
abstract contract Ownable is Context {
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
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

contract DintFarmer is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  struct PoolInfo {
    IERC20 lpToken;
    uint256 APY;
    uint256 linearFactor;
    uint256 depositCap;
    uint256 tokenLimit;
    IERC20 cashoutToken;
    uint256 withdrawFee;
    uint256 deposited;
    bool paused;
    bool stopDeposit;
  }

  struct FarmEntry {
    uint256 startTime;
    uint256 amount;
  }

  uint public poolCount = 0;

  uint256 public developerFee = 10;

  address public feeRecipient;
  address public devAddress;

  mapping(uint256 => PoolInfo) public poolInfo;
  mapping(address => mapping(uint256 => FarmEntry[])) public farmEntry;
  mapping(address => uint256) public tokensBlocked;
  mapping(address => uint256) public collectedFees;
  mapping(address => uint256) public collectedDevFees;
  mapping(uint256 => mapping(address => uint256)) public userTotal;

  event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
  event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
  event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

  constructor(
    address _feeRecipient,
    address _devAddress
  ) public {
    feeRecipient = _feeRecipient;
    devAddress = _devAddress;
  }

  function poolLength() external view returns (uint256) {
    return poolCount;
  }

  function add(IERC20 _lpToken, uint256 _apy, uint256 _linearFactor, uint256 _depositCap, uint256 _tokenLimit, IERC20 _cashoutToken, uint256 _withdrawFee) public onlyOwner {
    require(_cashoutToken.balanceOf(address(this)) - tokensBlocked[address(_cashoutToken)] > _tokenLimit * (_apy / 100), "DintFarmer::add: not enough cashout tokens to pay 1 year bonus.");
    require(_apy > 0 && _linearFactor >= 0 && _depositCap > 0 && _tokenLimit > 0 && _withdrawFee >= 0, "DintFarmer::add: wrong inputs.");


    tokensBlocked[address(_cashoutToken)] += _tokenLimit * _apy / 100;

    poolInfo[poolCount] = PoolInfo({
      lpToken: _lpToken,
      APY: _apy,
      linearFactor: _linearFactor,
      depositCap: _depositCap,
      tokenLimit: _tokenLimit,
      cashoutToken: _cashoutToken,
      withdrawFee: _withdrawFee, 
      deposited: 0, 
      paused: false,
      stopDeposit: false
    });
    ++poolCount;
  }

  function setPause(uint256 _pid, bool _paused) public onlyOwner {
    require(address(poolInfo[_pid].lpToken) != address(0), "DintFarmer::setPause: Pool not found");
    poolInfo[_pid].paused = _paused;
  }
  function stopDeposit(uint256 _pid, bool _stopped) public onlyOwner {
    require(address(poolInfo[_pid].lpToken) != address(0), "DintFarmer::stopDeposit: Pool not found");
    poolInfo[_pid].stopDeposit = _stopped;
  }

  function setDeveloperFee(uint256 _fee) public onlyOwner {
    developerFee = _fee;
  }
  function setFeeRecipient(address _feeRecipient) public onlyOwner {
    feeRecipient = _feeRecipient;
  }

  function getEntries(uint256 _pid, address _user) public view returns (FarmEntry[] memory entries){
    entries = farmEntry[_user][_pid];
  }

  function deposit(uint256 _pid, uint256 _amount) public {
    require(address(poolInfo[_pid].lpToken) != address(0), "DintFarmer::deposit: Pool not found");
    require(_amount > 0, "DintFarmer::deposit: amount must be greater than 0");

    PoolInfo storage pool = poolInfo[_pid];
    uint256 totalDeposit = userTotal[_pid][msg.sender];

    require(pool.stopDeposit == false && pool.paused == false, "DintFarmer::deposit: Deposit disabled");
    require(_amount + totalDeposit <= pool.tokenLimit * pool.depositCap / 100, "DintFarmer::deposit: amount too high");
    require(_amount + pool.deposited <= pool.tokenLimit, "DintFarmer::deposit: Token limit exceeded");

    pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);

    pool.deposited += _amount;

    farmEntry[address(msg.sender)][_pid].push(FarmEntry({
      amount: _amount,
      startTime: block.timestamp
    }));

    userTotal[_pid][msg.sender] += _amount;

    emit Deposit(msg.sender, _pid, _amount);
  }

  function withdraw(uint256 _pid, uint256 _entry, uint256 _amount) public {
    require(address(poolInfo[_pid].lpToken) != address(0), "DintFarmer::withdraw: Pool not found");
    require(farmEntry[address(msg.sender)][_pid][_entry].amount > 0, "DintFarmer::withdraw: Pool entry not found");

    PoolInfo storage pool = poolInfo[_pid];
    FarmEntry storage entry = farmEntry[address(msg.sender)][_pid][_entry];

    require(pool.paused == false, "DintFarmer::deposit: Deposit disabled");
    require(_amount <= entry.amount, "DintFarmer::withdraw: amount too high");
    uint256 elapsed = block.timestamp - entry.startTime;
    uint256 reward = getReward(pool.APY, pool.linearFactor, elapsed, _amount);
    uint256 totalFee = reward * pool.withdrawFee / 100;
    uint256 devFee = totalFee * developerFee / 100;

    pool.cashoutToken.safeTransfer(address(msg.sender), reward.sub(totalFee));
    
    collectedFees[address(pool.cashoutToken)] += totalFee.sub(devFee);
    collectedDevFees[address(pool.cashoutToken)] += devFee;

    tokensBlocked[address(pool.cashoutToken)] -= (_amount * pool.APY / 100) - totalFee;

    pool.lpToken.safeTransfer(address(msg.sender), _amount);
    entry.amount -= _amount;

    emit Withdraw(msg.sender, _pid, _amount);
  }

  function collectDevFees(IERC20 token) public {
    require(msg.sender == devAddress, "Only dev");
    require(collectedDevFees[address(token)] > 0, "DintFarmer::collectDevFees: nothing to collect");

    token.safeTransfer(address(msg.sender), collectedDevFees[address(token)]);

    collectedDevFees[address(token)] = 0;
  }

  function collectFees(IERC20 token) public onlyOwner {
    require(collectedFees[address(token)] > 0, "DintFarmer::collectFees: nothing to collect");

    token.safeTransfer(address(msg.sender), collectedFees[address(token)]);

    collectedFees[address(token)] = 0;
  }

  function withdrawTokens(IERC20 token, uint256 _amount) public {
    require(token.balanceOf(address(this)) - collectedDevFees[address(token)] - collectedFees[address(token)] - tokensBlocked[address(token)] >= _amount, "DintFarmer::withdrawTokens: not enough tokens");

    token.safeTransfer(address(msg.sender), _amount);
  }

  function unassignedTokenCount(IERC20 token) public view returns (uint256){
    return token.balanceOf(address(this)) - collectedDevFees[address(token)] - collectedFees[address(token)] - tokensBlocked[address(token)];
  }

  function emergencyWithdraw(uint256 _pid, uint256 _entry) public {
    PoolInfo storage pool = poolInfo[_pid];
    FarmEntry storage entry = farmEntry[address(msg.sender)][_pid][_entry];
    pool.lpToken.safeTransfer(address(msg.sender), entry.amount);
    emit EmergencyWithdraw(msg.sender, _pid, entry.amount);
    entry.amount = 0;
    tokensBlocked[address(pool.cashoutToken)] -= entry.amount * pool.APY / 100;
  }

  function getReward(uint256 _apy, uint256 _linearFactor, uint256 _elapsed, uint256 _amount) private pure returns (uint256 withdrawFee) {
    withdrawFee = ((_amount * _apy / 100) * (_elapsed * 100 / 31536000) * ((_elapsed * 100 / 31536000)**(_linearFactor)) / 10**(2+_linearFactor*2));
  }

}