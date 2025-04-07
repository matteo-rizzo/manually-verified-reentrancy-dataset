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
/******************
@title WadRayMath library
@author Aave
@dev Provides mul and div function for wads (decimal numbers with 18 digits precision) and rays (decimals with 27 digits)
 */


// 


// 


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


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


// 
/*
  	Distribution Formula:
  	55.5m MIMO in first week
  	-5.55% redution per week

  	total(timestamp) = _SECONDS_PER_WEEK * ( (1-_WEEKLY_R^(timestamp/_SECONDS_PER_WEEK)) / (1-_WEEKLY_R) )
  		+ timestamp % _SECONDS_PER_WEEK * (1-_WEEKLY_R^(timestamp/_SECONDS_PER_WEEK)
  */
contract MIMODistributor is IMIMODistributor {
  using SafeMath for uint256;
  using WadRayMath for uint256;

  event PayeeAdded(address account, uint256 shares);
  event TokensReleased(uint256 newTokens, uint256 releasedAt);

  uint256 private constant _SECONDS_PER_YEAR = 365 days;
  uint256 private constant _SECONDS_PER_WEEK = 7 days;
  uint256 private constant _WEEKLY_R = 9445e23; //-5.55%
  uint256 private constant _FIRST_WEEK_TOKENS = 55500000 ether; //55.5m

  uint256 public override totalShares;
  mapping(address => uint256) public override shares;
  address[] public payees;

  uint256 public override startTime;

  IGovernanceAddressProvider public override a;

  modifier onlyManager() {
    require(a.controller().hasRole(a.controller().MANAGER_ROLE(), msg.sender), "Caller is not Manager");
    _;
  }

  constructor(IGovernanceAddressProvider _a, uint256 _startTime) public {
    require(address(_a) != address(0));

    a = _a;
    startTime = _startTime;
  }

  /**
    Public function to release the accumulated new MIMO tokens to the payees.
    @dev anyone can call this.
  */
  function release() public override {
    uint256 newTokens = mintableTokens();
    require(newTokens > 0, "newTokens is 0");
    require(payees.length > 0, "Payees not configured yet");
    // Mint MIMO to all receivers
    for (uint256 i = 0; i < payees.length; i++) {
      address payee = payees[i];
      _release(newTokens, payee);
    }
    emit TokensReleased(newTokens, now);
  }

  /**
    Updates the payee configuration to a new one.
    @dev will release existing fees before the update.
    @param _payees Array of payees
    @param _shares Array of shares for each payee
  */
  function changePayees(address[] memory _payees, uint256[] memory _shares) public override onlyManager {
    require(_payees.length == _shares.length, "Payees and shares mismatched");
    require(_payees.length > 0, "No payees");

    if (payees.length > 0 && mintableTokens() > 0) {
      release();
    }

    for (uint256 i = 0; i < payees.length; i++) {
      delete shares[payees[i]];
    }
    delete payees;
    totalShares = 0;

    for (uint256 i = 0; i < _payees.length; i++) {
      _addPayee(_payees[i], _shares[i]);
    }
  }

  /**
    Get current configured payees.
    @return array of current payees.
  */
  function getPayees() public view override returns (address[] memory) {
    return payees;
  }

  /**
    Get current monthly issuance of new MIMO tokens.
    @return number of monthly issued tokens currently`.
  */
  function currentIssuance() public view override returns (uint256) {
    return weeklyIssuanceAt(now);
  }

  /**
    Get monthly issuance of new MIMO tokens at `timestamp`.
    @dev invalid for timestamps before deployment
    @param timestamp for which to calculate the monthly issuance
    @return number of monthly issued tokens at `timestamp`.
  */
  function weeklyIssuanceAt(uint256 timestamp) public view override returns (uint256) {
    uint256 elapsedSeconds = timestamp.sub(startTime);
    uint256 elapsedWeeks = elapsedSeconds.div(_SECONDS_PER_WEEK);
    return _WEEKLY_R.rayPow(elapsedWeeks).rayMul(_FIRST_WEEK_TOKENS);
  }

  /**
    Calculates how many MIMO tokens can be minted since the last time tokens were minted
    @return number of mintable tokens available right now.
  */
  function mintableTokens() public view override returns (uint256) {
    return totalSupplyAt(now).sub(a.mimo().totalSupply());
  }

  /**
    Calculates the totalSupply for any point after `startTime`
    @param timestamp for which to calculate the totalSupply
    @return totalSupply at timestamp.
  */
  function totalSupplyAt(uint256 timestamp) public view override returns (uint256) {
    uint256 elapsedSeconds = timestamp.sub(startTime);
    uint256 elapsedWeeks = elapsedSeconds.div(_SECONDS_PER_WEEK);
    uint256 lastWeekSeconds = elapsedSeconds % _SECONDS_PER_WEEK;
    uint256 one = WadRayMath.ray();
    uint256 fullWeeks = one.sub(_WEEKLY_R.rayPow(elapsedWeeks)).rayMul(_FIRST_WEEK_TOKENS).rayDiv(one.sub(_WEEKLY_R));
    uint256 currentWeekIssuance = weeklyIssuanceAt(timestamp);
    uint256 partialWeek = currentWeekIssuance.mul(lastWeekSeconds).div(_SECONDS_PER_WEEK);
    return fullWeeks.add(partialWeek);
  }

  /**
    Internal function to release a percentage of newTokens to a specific payee
    @dev uses totalShares to calculate correct share
    @param _totalnewTokensReceived Total newTokens for all payees, will be split according to shares
    @param _payee The address of the payee to whom to distribute the fees.
  */
  function _release(uint256 _totalnewTokensReceived, address _payee) internal {
    uint256 payment = _totalnewTokensReceived.mul(shares[_payee]).div(totalShares);
    a.mimo().mint(_payee, payment);
  }

  /**
    Internal function to add a new payee.
    @dev will update totalShares and therefore reduce the relative share of all other payees.
    @param _payee The address of the payee to add.
    @param _shares The number of shares owned by the payee.
  */
  function _addPayee(address _payee, uint256 _shares) internal {
    require(_payee != address(0), "payee is the zero address");
    require(_shares > 0, "shares are 0");
    require(shares[_payee] == 0, "payee already has shares");

    payees.push(_payee);
    shares[_payee] = _shares;
    totalShares = totalShares.add(_shares);
    emit PayeeAdded(_payee, _shares);
  }
}