/**
 *Submitted for verification at Etherscan.io on 2021-03-10
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


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
 * @dev Interface of the ERC20 standard as defined in the EIP.
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
/******************
@title WadRayMath library
@author Aave
@dev Provides mul and div function for wads (decimal numbers with 18 digits precision) and rays (decimals with 27 digits)
 */


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


//
/*
    GenericMiner is based on ERC2917. https://github.com/gnufoo/ERC2917-Proposal

    The Objective of GenericMiner is to implement a decentralized staking mechanism, which calculates _users' share
    by accumulating stake * time. And calculates _users revenue from anytime t0 to t1 by the formula below:

        user_accumulated_stake(time1) - user_accumulated_stake(time0)
       _____________________________________________________________________________  * (gross_stake(t1) - gross_stake(t0))
       total_accumulated_stake(time1) - total_accumulated_stake(time0)

*/
contract GenericMiner is IGenericMiner {
  using SafeMath for uint256;
  using WadRayMath for uint256;

  mapping(address => UserInfo) private _users;

  uint256 public override totalStake;
  IGovernanceAddressProvider public override a;

  uint256 private _balanceTracker;
  uint256 private _accAmountPerShare;

  constructor(IGovernanceAddressProvider _addresses) public {
    require(address(_addresses) != address(0));
    a = _addresses;
  }

  /**
    Releases the outstanding MIMO balance to the user.
    @param _user the address of the user for which the MIMO tokens will be released.
  */
  function releaseMIMO(address _user) public override {
    UserInfo storage userInfo = _users[_user];
    _refresh();
    uint256 pending = userInfo.stake.rayMul(_accAmountPerShare.sub(userInfo.accAmountPerShare));
    _balanceTracker = _balanceTracker.sub(pending);
    userInfo.accAmountPerShare = _accAmountPerShare;
    require(a.mimo().transfer(_user, pending));
  }

  /**
    Returns the number of tokens a user has staked.
    @param _user the address of the user.
    @return number of staked tokens
  */
  function stake(address _user) public view override returns (uint256) {
    return _users[_user].stake;
  }

  /**
    Returns the number of tokens a user can claim via `releaseMIMO`.
    @param _user the address of the user.
    @return number of MIMO tokens that the user can claim
  */
  function pendingMIMO(address _user) public view override returns (uint256) {
    uint256 currentBalance = a.mimo().balanceOf(address(this));
    uint256 reward = currentBalance.sub(_balanceTracker);
    uint256 accAmountPerShare = _accAmountPerShare.add(reward.rayDiv(totalStake));

    return _users[_user].stake.rayMul(accAmountPerShare.sub(_users[_user].accAmountPerShare));
  }

  /**
    Returns the userInfo stored of a user.
    @param _user the address of the user.
    @return `struct UserInfo {
      uint256 stake;
      uint256 rewardDebt;
    }`
  **/
  function userInfo(address _user) public view override returns (UserInfo memory) {
    return _users[_user];
  }

  /**
    Refreshes the global state and subsequently decreases the stake a user has.
    This is an internal call and meant to be called within derivative contracts.
    @param user the address of the user
    @param value the amount by which the stake will be reduced
  */
  function _decreaseStake(address user, uint256 value) internal {
    require(value > 0, "STAKE_MUST_BE_GREATER_THAN_ZERO"); //TODO cleanup error message

    UserInfo storage userInfo = _users[user];
    require(userInfo.stake >= value, "INSUFFICIENT_STAKE_FOR_USER"); //TODO cleanup error message
    _refresh();
    uint256 pending = userInfo.stake.rayMul(_accAmountPerShare.sub(userInfo.accAmountPerShare));
    _balanceTracker = _balanceTracker.sub(pending);
    userInfo.stake = userInfo.stake.sub(value);
    userInfo.accAmountPerShare = _accAmountPerShare;
    totalStake = totalStake.sub(value);

    require(a.mimo().transfer(user, pending));
    emit StakeDecreased(user, value);
  }

  /**
    Refreshes the global state and subsequently increases a user's stake.
    This is an internal call and meant to be called within derivative contracts.
    @param user the address of the user
    @param value the amount by which the stake will be increased
  */
  function _increaseStake(address user, uint256 value) internal {
    require(value > 0, "STAKE_MUST_BE_GREATER_THAN_ZERO"); //TODO cleanup error message

    UserInfo storage userInfo = _users[user];
    _refresh();

    uint256 pending;
    if (userInfo.stake > 0) {
      pending = userInfo.stake.rayMul(_accAmountPerShare.sub(userInfo.accAmountPerShare));
      _balanceTracker = _balanceTracker.sub(pending);
    }

    totalStake = totalStake.add(value);
    userInfo.stake = userInfo.stake.add(value);
    userInfo.accAmountPerShare = _accAmountPerShare;

    if (pending > 0) {
      require(a.mimo().transfer(user, pending));
    }

    emit StakeIncreased(user, value);
  }

  /**
    Refreshes the global state and subsequently updates a user's stake.
    This is an internal call and meant to be called within derivative contracts.
    @param user the address of the user
    @param stake the new amount of stake for the user
  */
  function _updateStake(address user, uint256 stake) internal returns (bool) {
    uint256 oldStake = _users[user].stake;
    if (stake > oldStake) {
      _increaseStake(user, stake.sub(oldStake));
    }
    if (stake < oldStake) {
      _decreaseStake(user, oldStake.sub(stake));
    }
  }

  /**
    Internal read function to calculate the number of MIMO tokens that
    have accumulated since the last token release.
    @dev This is an internal call and meant to be called within derivative contracts.
    @return newly accumulated token balance
  */
  function _newTokensReceived() internal view returns (uint256) {
    return a.mimo().balanceOf(address(this)).sub(_balanceTracker);
  }

  /**
    Updates the internal state variables after accounting for newly received MIMO tokens.
  */
  function _refresh() internal {
    if (totalStake == 0) {
      return;
    }
    uint256 currentBalance = a.mimo().balanceOf(address(this));
    uint256 reward = currentBalance.sub(_balanceTracker);
    _balanceTracker = currentBalance;

    _accAmountPerShare = _accAmountPerShare.add(reward.rayDiv(totalStake));
  }
}

// 


// 
contract DemandMiner is IDemandMiner, GenericMiner {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  IERC20 public override token;

  constructor(IGovernanceAddressProvider _addresses, IERC20 _token) public GenericMiner(_addresses) {
    require(address(_token) != address(0));
    require(address(_token) != address(_addresses.mimo()));
    token = _token;
  }

  /**
    Deposit an ERC20 pool token for staking
    @dev this function uses `transferFrom()` and requires pre-approval via `approve()` on the ERC20.
    @param amount the amount of tokens to be deposited. Unit is in WEI.
  **/
  function deposit(uint256 amount) public override {
    token.safeTransferFrom(msg.sender, address(this), amount);
    _increaseStake(msg.sender, amount);
  }

  /**
    Withdraw staked ERC20 pool tokens. Will fail if user does not have enough tokens staked.
    @param amount the amount of tokens to be withdrawn. Unit is in WEI.
  **/
  function withdraw(uint256 amount) public override {
    token.safeTransfer(msg.sender, amount);
    _decreaseStake(msg.sender, amount);
  }
}