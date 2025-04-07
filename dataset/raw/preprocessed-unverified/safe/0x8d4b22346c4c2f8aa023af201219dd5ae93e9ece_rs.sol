/**
 *Submitted for verification at Etherscan.io on 2020-12-04
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


// 
/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */


// 
interface ISTABLEX is IERC20 {
  function a() external view returns (IAddressProvider);

  function mint(address account, uint256 amount) external;

  function burn(address account, uint256 amount) external;
}

// 


// 


// 


// 


// 


// 


// 


// 
contract RatesManager is IRatesManager {
  using SafeMath for uint256;
  using WadRayMath for uint256;

  uint256 private constant SECONDS_PER_YEAR = 365 days;

  IAddressProvider public override a;

  constructor(IAddressProvider _addresses) public {
    require(address(_addresses) != address(0));
    a = _addresses;
  }

  /**
    Calculate the annualized borrow rate from the specified borrowing rate.
    @param _borrowRate rate for a 1 second interval specified in RAY accuracy.
    @return annualized rate
  */
  function annualizedBorrowRate(uint256 _borrowRate) public override pure returns (uint256) {
    return _borrowRate.rayPow(SECONDS_PER_YEAR);
  }

  /**
    Calculate the total debt from a specified base debt and cumulative rate.
    @param _baseDebt the base debt to be used. Can be a vault base debt or an aggregate base debt
    @param _cumulativeRate the cumulative rate in RAY accuracy.
    @return debt after applying the cumulative rate 
  */
  function calculateDebt(uint256 _baseDebt, uint256 _cumulativeRate) public override pure returns (uint256 debt) {
    return _baseDebt.rayMul(_cumulativeRate);
  }

  /**
    Calculate the base debt from a specified total debt and cumulative rate.
    @param _debt the total debt to be used. 
    @param _cumulativeRate the cumulative rate in RAY accuracy.
    @return baseDebt the new base debt 
  */
  function calculateBaseDebt(uint256 _debt, uint256 _cumulativeRate) public override pure returns (uint256 baseDebt) {
    return _debt.rayDiv(_cumulativeRate);
  }

  /**
    Bring an existing cumulative rate forward in time
    @param _borrowRate rate for a 1 second interval specified in RAY accuracy to be applied
    @param _timeElapsed the time over whicht the borrow rate shall be applied
    @param _cumulativeRate the initial cumulative rate from which to apply the borrow rate
    @return new cumulative rate 
  */
  function calculateCumulativeRate(
    uint256 _borrowRate,
    uint256 _cumulativeRate,
    uint256 _timeElapsed
  ) public override view returns (uint256) {
    if (_timeElapsed == 0) return _cumulativeRate;
    uint256 cumulativeElapsed = _borrowRate.rayPow(_timeElapsed);
    return _cumulativeRate.rayMul(cumulativeElapsed);
  }
}