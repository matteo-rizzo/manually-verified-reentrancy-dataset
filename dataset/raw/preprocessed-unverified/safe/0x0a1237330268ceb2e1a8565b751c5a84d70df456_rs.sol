/**
 *Submitted for verification at Etherscan.io on 2021-03-01
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
contract LiquidationManager is ILiquidationManager, ReentrancyGuard {
  using SafeMath for uint256;
  using WadRayMath for uint256;

  IAddressProvider public override a;

  uint256 public constant HEALTH_FACTOR_LIQUIDATION_THRESHOLD = 1e18; // 1

  constructor(IAddressProvider _addresses) public {
    require(address(_addresses) != address(0));
    a = _addresses;
  }

  /**
    Check if the health factor is above or equal to 1.
    @param _collateralValue value of the collateral in PAR
    @param _vaultDebt outstanding debt to which the collateral balance shall be compared
    @param _minRatio min ratio to calculate health factor
    @return boolean if the health factor is >= 1.
  */
  function isHealthy(
    uint256 _collateralValue,
    uint256 _vaultDebt,
    uint256 _minRatio
  ) public view override returns (bool) {
    uint256 healthFactor = calculateHealthFactor(_collateralValue, _vaultDebt, _minRatio);
    return healthFactor >= HEALTH_FACTOR_LIQUIDATION_THRESHOLD;
  }

  /**
    Calculate the healthfactor of a debt balance
    @param _collateralValue value of the collateral in PAR currency
    @param _vaultDebt outstanding debt to which the collateral balance shall be compared
    @param _minRatio min ratio to calculate health factor
    @return healthFactor
  */
  function calculateHealthFactor(
    uint256 _collateralValue,
    uint256 _vaultDebt,
    uint256 _minRatio
  ) public view override returns (uint256 healthFactor) {
    if (_vaultDebt == 0) return WadRayMath.wad();

    // CurrentCollateralizationRatio = value(deposited ETH) / debt
    uint256 collateralizationRatio = _collateralValue.wadDiv(_vaultDebt);

    // Healthfactor = CurrentCollateralizationRatio / MinimumCollateralizationRatio
    if (_minRatio > 0) {
      return collateralizationRatio.wadDiv(_minRatio);
    }

    return 1e18; // 1
  }

  /**
    Calculate the liquidation bonus for a specified amount
    @param _collateralType address of the collateral type
    @param _amount amount for which the liquidation bonus shall be calculated
    @return bonus the liquidation bonus to pay out
  */
  function liquidationBonus(address _collateralType, uint256 _amount) public view override returns (uint256 bonus) {
    return _amount.wadMul(a.config().collateralLiquidationBonus(_collateralType));
  }

  /**
    Apply the liquidation bonus to a balance as a discount.
    @param _collateralType address of the collateral type
    @param _amount the balance on which to apply to liquidation bonus as a discount.
    @return discountedAmount
  */
  function applyLiquidationDiscount(address _collateralType, uint256 _amount)
    public
    view
    override
    returns (uint256 discountedAmount)
  {
    return _amount.wadDiv(a.config().collateralLiquidationBonus(_collateralType).add(WadRayMath.wad()));
  }
}