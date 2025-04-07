/**
 *Submitted for verification at Etherscan.io on 2021-03-11
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


// 
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
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

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


// 


// 


// 


// 
interface ISTABLEX is IERC20 {
  function mint(address account, uint256 amount) external;

  function burn(address account, uint256 amount) external;

  function a() external view returns (IAddressProvider);
}

// 


// 


// 


// 


// 


// 


// 


// 


// 


// 


// 


// 
interface IMIMO is IERC20 {

  function burn(address account, uint256 amount) external;
  
  function mint(address account, uint256 amount) external;

}

// 


// 


// 


// 


// 


// 


// 


// 
/* solium-disable security/no-block-members */
/**
 * @title  VotingEscrow
 * @notice Lockup GOV, receive vGOV (voting weight that decays over time)
 * @dev    Supports:
 *            1) Tracking MIMO Locked up
 *            2) Decaying voting weight lookup
 *            3) Closure of contract
 */
contract VotingEscrow is IVotingEscrow, ReentrancyGuard {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 public constant MAXTIME = 1460 days; // 365 * 4 years
  bool public expired = false;
  IERC20 public override stakingToken;

  mapping(address => LockedBalance) public locked;

  string public override name;
  string public override symbol;
  // solhint-disable-next-line
  uint256 public constant override decimals = 18;

  // AddressProvider
  IGovernanceAddressProvider public a;

  constructor(
    IERC20 _stakingToken,
    IGovernanceAddressProvider _a,
    string memory _name,
    string memory _symbol
  ) public {
    require(address(_stakingToken) != address(0));
    require(address(_a) != address(0));

    stakingToken = _stakingToken;
    a = _a;

    name = _name;
    symbol = _symbol;
  }

  modifier onlyManager() {
    require(a.controller().hasRole(a.controller().MANAGER_ROLE(), msg.sender), "Caller is not a Manager");
    _;
  }

  /** @dev Modifier to ensure contract has not yet expired */
  modifier contractNotExpired() {
    require(!expired, "Contract is expired");
    _;
  }

  /**
   * @dev Creates a new lock
   * @param _value Total units of StakingToken to lockup
   * @param _unlockTime Time at which the stake should unlock
   */
  function createLock(uint256 _value, uint256 _unlockTime) external override nonReentrant contractNotExpired {
    LockedBalance memory locked_ = LockedBalance({ amount: locked[msg.sender].amount, end: locked[msg.sender].end });

    require(_value > 0, "Must stake non zero amount");
    require(locked_.amount == 0, "Withdraw old tokens first");
    require(_unlockTime > block.timestamp, "Can only lock until time in the future");

    _depositFor(msg.sender, _value, _unlockTime, locked_, LockAction.CREATE_LOCK);
  }

  /**
   * @dev Increases amount of stake thats locked up & resets decay
   * @param _value Additional units of StakingToken to add to exiting stake
   */
  function increaseLockAmount(uint256 _value) external override nonReentrant contractNotExpired {
    LockedBalance memory locked_ = LockedBalance({ amount: locked[msg.sender].amount, end: locked[msg.sender].end });

    require(_value > 0, "Must stake non zero amount");
    require(locked_.amount > 0, "No existing lock found");
    require(locked_.end > block.timestamp, "Cannot add to expired lock. Withdraw");

    _depositFor(msg.sender, _value, 0, locked_, LockAction.INCREASE_LOCK_AMOUNT);
  }

  /**
   * @dev Increases length of lockup & resets decay
   * @param _unlockTime New unlocktime for lockup
   */
  function increaseLockLength(uint256 _unlockTime) external override nonReentrant contractNotExpired {
    LockedBalance memory locked_ = LockedBalance({ amount: locked[msg.sender].amount, end: locked[msg.sender].end });

    require(locked_.amount > 0, "Nothing is locked");
    require(locked_.end > block.timestamp, "Lock expired");
    require(_unlockTime > locked_.end, "Can only increase lock time");

    _depositFor(msg.sender, 0, _unlockTime, locked_, LockAction.INCREASE_LOCK_TIME);
  }

  /**
   * @dev Withdraws all the senders stake, providing lockup is over
   */
  function withdraw() external override {
    _withdraw(msg.sender);
  }

  /**
   * @dev Ends the contract, unlocking all stakes.
   * No more staking can happen. Only withdraw.
   */
  function expireContract() external override onlyManager contractNotExpired {
    expired = true;
    emit Expired();
  }

  /***************************************
                    GETTERS
    ****************************************/

  /**
   * @dev Gets the user's votingWeight at the current time.
   * @param _owner User for which to return the votingWeight
   * @return uint256 Balance of user
   */
  function balanceOf(address _owner) public view override returns (uint256) {
    return balanceOfAt(_owner, block.timestamp);
  }

  /**
   * @dev Gets a users votingWeight at a given block timestamp
   * @param _owner User for which to return the balance
   * @param _blockTime Timestamp for which to calculate balance. Can not be in the past
   * @return uint256 Balance of user
   */
  function balanceOfAt(address _owner, uint256 _blockTime) public view override returns (uint256) {
    require(_blockTime >= block.timestamp, "Must pass block timestamp in the future");

    LockedBalance memory currentLock = locked[_owner];

    if (currentLock.end <= _blockTime) return 0;
    uint256 remainingLocktime = currentLock.end.sub(_blockTime);
    if (remainingLocktime > MAXTIME) {
      remainingLocktime = MAXTIME;
    }

    return currentLock.amount.mul(remainingLocktime).div(MAXTIME);
  }

  /**
   * @dev Deposits or creates a stake for a given address
   * @param _addr User address to assign the stake
   * @param _value Total units of StakingToken to lockup
   * @param _unlockTime Time at which the stake should unlock
   * @param _oldLocked Previous amount staked by this user
   * @param _action See LockAction enum
   */
  function _depositFor(
    address _addr,
    uint256 _value,
    uint256 _unlockTime,
    LockedBalance memory _oldLocked,
    LockAction _action
  ) internal {
    LockedBalance memory newLocked = LockedBalance({ amount: _oldLocked.amount, end: _oldLocked.end });

    // Adding to existing lock, or if a lock is expired - creating a new one
    newLocked.amount = newLocked.amount.add(_value);
    if (_unlockTime != 0) {
      newLocked.end = _unlockTime;
    }
    locked[_addr] = newLocked;

    if (_value != 0) {
      stakingToken.safeTransferFrom(_addr, address(this), _value);
    }

    emit Deposit(_addr, _value, newLocked.end, _action, block.timestamp);
  }

  /**
   * @dev Withdraws a given users stake, providing the lockup has finished
   * @param _addr User for which to withdraw
   */
  function _withdraw(address _addr) internal nonReentrant {
    LockedBalance memory oldLock = LockedBalance({ end: locked[_addr].end, amount: locked[_addr].amount });
    require(block.timestamp >= oldLock.end || expired, "The lock didn't expire");
    require(oldLock.amount > 0, "Must have something to withdraw");

    uint256 value = uint256(oldLock.amount);

    LockedBalance memory currentLock = LockedBalance({ end: 0, amount: 0 });
    locked[_addr] = currentLock;

    stakingToken.safeTransfer(_addr, value);

    emit Withdraw(_addr, value, block.timestamp);
  }
}