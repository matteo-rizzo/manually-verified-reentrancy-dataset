/**
 *Submitted for verification at Etherscan.io on 2021-03-01
*/

// SPDX-License-Identifier: MIT

pragma experimental ABIEncoderV2;
pragma solidity 0.6.12;


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
/******************
@title WadRayMath library
@author Aave
@dev Provides mul and div function for wads (decimal numbers with 18 digits precision) and rays (decimals with 27 digits)
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
contract VaultsCoreState is IVaultsCoreState {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using WadRayMath for uint256;

  uint256 internal constant _MAX_INT = 2**256 - 1;

  bool public override synced = false;
  IAddressProvider public override a;

  mapping(address => uint256) public override cumulativeRates;
  mapping(address => uint256) public override lastRefresh;

  modifier onlyConfig() {
    require(msg.sender == address(a.config()));
    _;
  }

  modifier onlyManager() {
    require(a.controller().hasRole(a.controller().MANAGER_ROLE(), msg.sender));
    _;
  }

  modifier notSynced() {
    require(!synced);
    _;
  }

  constructor(IAddressProvider _addresses) public {
    require(address(_addresses) != address(0));
    a = _addresses;
  }

  /**
    Calculate the available income
    @return available income that has not been minted yet.
  **/
  function availableIncome() public view override returns (uint256) {
    return a.vaultsData().debt().sub(a.stablex().totalSupply());
  }

  /**
    Refresh the cumulative rates and debts of all vaults and all collateral types.
    @dev anyone can call this.
  **/
  function refresh() public override {
    for (uint256 i = 1; i <= a.config().numCollateralConfigs(); i++) {
      address collateralType = a.config().collateralConfigs(i).collateralType;
      refreshCollateral(collateralType);
    }
  }

  /**
    Sync state with another instance. This is used during version upgrade to keep V2 in sync with V2.
    @dev This call will read the state via
      `cumulativeRates(address collateralType)` and `lastRefresh(address collateralType)`.
    @param _stateAddress address from which the state is to be copied.
  **/
  function syncState(IVaultsCoreState _stateAddress) public override onlyManager notSynced {
    for (uint256 i = 1; i <= a.config().numCollateralConfigs(); i++) {
      address collateralType = a.config().collateralConfigs(i).collateralType;
      cumulativeRates[collateralType] = _stateAddress.cumulativeRates(collateralType);
      lastRefresh[collateralType] = _stateAddress.lastRefresh(collateralType);
    }
    synced = true;
  }

  /**
    Sync state with v1 core. This is used during version upgrade to keep V2 in sync with V1.
    @dev This call will read the state via
      `cumulativeRates(address collateralType)` and `lastRefresh(address collateralType)`.
    @param _core address of core v1 from which the state is to be copied.
  **/
  function syncStateFromV1(IVaultsCoreV1 _core) public override onlyManager notSynced {
    for (uint256 i = 1; i <= a.config().numCollateralConfigs(); i++) {
      address collateralType = a.config().collateralConfigs(i).collateralType;
      cumulativeRates[collateralType] = _core.cumulativeRates(collateralType);
      lastRefresh[collateralType] = _core.lastRefresh(collateralType);
    }
    synced = true;
  }

  /**
    Initialize the cumulative rates to 1 for a new collateral type.
    @param _collateralType the address of the new collateral type to be initialized
  **/
  function initializeRates(address _collateralType) public override onlyConfig {
    require(_collateralType != address(0));
    lastRefresh[_collateralType] = block.timestamp;
    cumulativeRates[_collateralType] = WadRayMath.ray();
  }

  /**
    Refresh the cumulative rate of a collateraltype.
    @dev this updates the debt for all vaults with the specified collateral type.
    @param _collateralType the address of the collateral type to be refreshed.
  **/
  function refreshCollateral(address _collateralType) public override {
    require(_collateralType != address(0));
    require(a.config().collateralIds(_collateralType) != 0);
    uint256 timestamp = block.timestamp;
    uint256 timeElapsed = timestamp.sub(lastRefresh[_collateralType]);
    _refreshCumulativeRate(_collateralType, timeElapsed);
    lastRefresh[_collateralType] = timestamp;
  }

  /**
    Internal function to increase the cumulative rate over a specified time period
    @dev this updates the debt for all vaults with the specified collateral type.
    @param _collateralType the address of the collateral type to be updated
    @param _timeElapsed the amount of time in seconds to add to the cumulative rate
  **/
  function _refreshCumulativeRate(address _collateralType, uint256 _timeElapsed) internal {
    uint256 borrowRate = a.config().collateralBorrowRate(_collateralType);
    uint256 oldCumulativeRate = cumulativeRates[_collateralType];
    cumulativeRates[_collateralType] = a.ratesManager().calculateCumulativeRate(
      borrowRate,
      oldCumulativeRate,
      _timeElapsed
    );
    emit CumulativeRateUpdated(_collateralType, _timeElapsed, cumulativeRates[_collateralType]);
  }
}