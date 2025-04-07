/**
 *Submitted for verification at Etherscan.io on 2020-12-04
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


// 
contract VaultsCore is IVaultsCore, ReentrancyGuard {
  using SafeERC20 for IERC20;
  using SafeMath for uint256;
  using WadRayMath for uint256;

  uint256 MAX_INT = 2**256 - 1;
  
  mapping(address => uint256) public override cumulativeRates;
  mapping(address => uint256) public override lastRefresh;

  IAddressProvider public override a;

  modifier onlyManager() {
    require(a.controller().hasRole(a.controller().MANAGER_ROLE(), msg.sender));
    _;
  }

  modifier onlyVaultOwner(uint256 _vaultId) {
    require(a.vaultsData().vaultOwner(_vaultId) == msg.sender);
    _;
  }

  modifier onlyConfig() {
    require(msg.sender == address(a.config()));
    _;
  }

  constructor(IAddressProvider _addresses) public {
    require(address(_addresses) != address(0));
    a = _addresses;
  }

  /*
    Allow smooth upgrading of the vaultscore.
    @dev this function approves token transfers to the new vaultscore of 
    both stablex and all configured collateral types
    @param _newVaultsCore address of the new vaultscore
  */
  function upgrade(address _newVaultsCore) public override onlyManager{
    require(address(_newVaultsCore) != address(0));
    require(a.stablex().approve(_newVaultsCore, MAX_INT));

    for (uint256 i = 1; i <= a.config().numCollateralConfigs(); i++) {
      address collateralType = a.config().collateralConfigs(i).collateralType;
      IERC20 asset = IERC20(collateralType);
      asset.safeApprove(_newVaultsCore, MAX_INT);
    }
  }
  /**
    Calculate the available income
    @return available income that has not been minted yet.
  **/
  function availableIncome() public override view returns (uint256) {
    return a.vaultsData().debt().sub(a.stablex().totalSupply());
  }

  /** 
    Refresh the cumulative rates and debts of all vaults and all collateral types.
  **/
  function refresh() public override {
    for (uint256 i = 1; i <= a.config().numCollateralConfigs(); i++) {
      address collateralType = a.config().collateralConfigs(i).collateralType;
      refreshCollateral(collateralType);
    }
  }

  /** 
    Initialize the cumulative rates to 1 for a new collateral type.
    @param _collateralType the address of the new collateral type to be initialized
  **/
  function initializeRates(address _collateralType) public override onlyConfig {
    require(_collateralType != address(0));
    lastRefresh[_collateralType] = now;
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
    uint256 timestamp = now;
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

  /** 
    Deposit an ERC20 token into the vault of the msg.sender as collateral
    @dev A new vault is created if no vault exists for the `msg.sender` with the specified collateral type.
    this function used `transferFrom()` and requires pre-approval via `approve()` on the ERC20.
    @param _collateralType the address of the collateral type to be deposited
    @param _amount the amount of tokens to be deposited in WEI.
  **/
  function deposit(address _collateralType, uint256 _amount) public override {
    require(a.config().collateralIds(_collateralType) != 0);
    uint256 vaultId = a.vaultsData().vaultId(_collateralType, msg.sender);
    if (vaultId == 0) {
      vaultId = a.vaultsData().createVault(_collateralType, msg.sender);
    }
    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(vaultId);
    a.vaultsData().setCollateralBalance(vaultId, v.collateralBalance.add(_amount));

    IERC20 asset = IERC20(v.collateralType);
    asset.safeTransferFrom(msg.sender, address(this), _amount);

    emit Deposited(vaultId, _amount, msg.sender);
  }

  /** 
    Withdraws ERC20 tokens from a vault. 
    @dev Only te owner of a vault can withdraw collateral from it.
    `withdraw()` will fail if it would bring the vault below the liquidation treshold.
    @param _vaultId the ID of the vault from which to withdraw the collateral.
    @param _amount the amount of ERC20 tokens to be withdrawn in WEI.
  **/
  function withdraw(uint256 _vaultId, uint256 _amount) public override onlyVaultOwner(_vaultId) nonReentrant {
    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);
    require(_amount <= v.collateralBalance);
    uint256 newCollateralBalance = v.collateralBalance.sub(_amount);
    a.vaultsData().setCollateralBalance(_vaultId, newCollateralBalance);
    if (v.baseDebt > 0) {
      //save gas cost when withdrawing from 0 debt vault
      refreshCollateral(v.collateralType);
      uint256 newCollateralValue = a.priceFeed().convertFrom(v.collateralType, newCollateralBalance);
      bool _isHealthy = a.liquidationManager().isHealthy(
        v.collateralType,
        newCollateralValue,
        a.vaultsData().vaultDebt(_vaultId)
      );
      require(_isHealthy);
    }

    IERC20 asset = IERC20(v.collateralType);
    asset.safeTransfer(msg.sender, _amount);
    emit Withdrawn(_vaultId, _amount, msg.sender);
  }

  /** 
    Convenience function to withdraw all collateral of a vault
    @dev Only te owner of a vault can withdraw collateral from it.
    `withdrawAll()` will fail if the vault has any outstanding debt attached to it. 
    @param _vaultId the ID of the vault from which to withdraw the collateral.
  **/
  function withdrawAll(uint256 _vaultId) public override onlyVaultOwner(_vaultId) {
    uint256 collateralBalance = a.vaultsData().vaultCollateralBalance(_vaultId);
    withdraw(_vaultId, collateralBalance);
  }

  /** 
    Borrow new StableX (Eg: PAR) tokens from a vault. 
    @dev Only te owner of a vault can borrow from it.
    `borrow()` will update the outstanding vault debt to the current time before attempting the withdrawal.
     and will fail if it would bring the vault below the liquidation treshold.
    @param _vaultId the ID of the vault from which to borrow.
    @param _amount the amount of borrowed StableX tokens in WEI.
  **/
  function borrow(uint256 _vaultId, uint256 _amount) public override onlyVaultOwner(_vaultId) nonReentrant {
    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);

    //make sure current rate is up to date
    refreshCollateral(v.collateralType);

    uint256 originationFeePercentage = a.config().collateralOriginationFee(v.collateralType);
    uint256 newDebt = _amount;
    if (originationFeePercentage > 0) {
      newDebt = newDebt.add(_amount.wadMul(originationFeePercentage));
    }

    // Increment vault borrow balance
    uint256 newBaseDebt = a.ratesManager().calculateBaseDebt(newDebt, cumulativeRates[v.collateralType]);

    a.vaultsData().setBaseDebt(_vaultId, v.baseDebt.add(newBaseDebt));

    uint256 collateralValue = a.priceFeed().convertFrom(v.collateralType, v.collateralBalance);
    uint256 newVaultDebt = a.vaultsData().vaultDebt(_vaultId);

    require(a.vaultsData().collateralDebt(v.collateralType) <= a.config().collateralDebtLimit(v.collateralType));

    bool isHealthy = a.liquidationManager().isHealthy(v.collateralType, collateralValue, newVaultDebt);
    require(isHealthy);

    a.stablex().mint(msg.sender, _amount);
    emit Borrowed(_vaultId, _amount, msg.sender);
  }

  /** 
    Convenience function to repay all debt of a vault
    @dev `repayAll()` will update the outstanding vault debt to the current time.
    @param _vaultId the ID of the vault for which to repay the debt.
  **/
  function repayAll(uint256 _vaultId) public override {
    repay(_vaultId, 2**256 - 1);
  }

  /** 
    Repay an outstanding StableX balance to a vault. 
    @dev `repay()` will update the outstanding vault debt to the current time.
    @param _vaultId the ID of the vault for which to repay the outstanding debt balance.
    @param _amount the amount of StableX tokens in WEI to be repaid.
  **/
  function repay(uint256 _vaultId, uint256 _amount) public override nonReentrant {
    address collateralType = a.vaultsData().vaultCollateralType(_vaultId);

    // Make sure current rate is up to date
    refreshCollateral(collateralType);

    uint256 currentVaultDebt = a.vaultsData().vaultDebt(_vaultId);
    // Decrement vault borrow balance
    if (_amount >= currentVaultDebt) {
      //full repayment
      _amount = currentVaultDebt; //only pay back what's outstanding
    }
    _reduceVaultDebt(_vaultId, _amount);
    a.stablex().burn(msg.sender, _amount);

    emit Repaid(_vaultId, _amount, msg.sender);
  }

  /** 
    Internal helper function to reduce the debt of a vault.
    @dev assumes cumulative rates for the vault's collateral type are up to date.
    please call `refreshCollateral()` before calling this function.
    @param _vaultId the ID of the vault for which to reduce the debt.
    @param _amount the amount of debt to be reduced.
  **/
  function _reduceVaultDebt(uint256 _vaultId, uint256 _amount) internal {
    address collateralType = a.vaultsData().vaultCollateralType(_vaultId);

    uint256 currentVaultDebt = a.vaultsData().vaultDebt(_vaultId);
    uint256 remainder = currentVaultDebt.sub(_amount);
    uint256 cumulativeRate = cumulativeRates[collateralType];

    if (remainder == 0) {
      a.vaultsData().setBaseDebt(_vaultId, 0);
    } else {
      uint256 newBaseDebt = a.ratesManager().calculateBaseDebt(remainder, cumulativeRate);
      a.vaultsData().setBaseDebt(_vaultId, newBaseDebt);
    }
  }

  /** 
    Liquidate a vault that is below the liquidation treshold by repaying it's outstanding debt.
    @dev `liquidate()` will update the outstanding vault debt to the current time and pay a `liquidationBonus`
    to the liquidator. `liquidate()` can be called by anyone.
    @param _vaultId the ID of the vault to be liquidated.
  **/
  function liquidate(uint256 _vaultId) public override nonReentrant {
    IVaultsDataProvider.Vault memory v = a.vaultsData().vaults(_vaultId);

    refreshCollateral(v.collateralType);

    uint256 collateralValue = a.priceFeed().convertFrom(v.collateralType, v.collateralBalance);
    uint256 currentVaultDebt = a.vaultsData().vaultDebt(_vaultId);

    require(!a.liquidationManager().isHealthy(v.collateralType, collateralValue, currentVaultDebt));

    uint256 discountedValue = a.liquidationManager().applyLiquidationDiscount(collateralValue);
    uint256 collateralToReceive;
    uint256 stableXToPay = currentVaultDebt;

    if (discountedValue < currentVaultDebt) {
      //Insurance Case
      uint256 insuranceAmount = currentVaultDebt.sub(discountedValue);
      require(a.stablex().balanceOf(address(this)) >= insuranceAmount);
      a.stablex().burn(address(this), insuranceAmount);
      emit InsurancePaid(_vaultId, insuranceAmount, msg.sender);
      collateralToReceive = v.collateralBalance;
      stableXToPay = currentVaultDebt.sub(insuranceAmount);
    } else {
      collateralToReceive = a.priceFeed().convertTo(v.collateralType, currentVaultDebt);
      collateralToReceive = collateralToReceive.add(a.liquidationManager().liquidationBonus(collateralToReceive));
    }
    // reduce the vault debt to 0
    _reduceVaultDebt(_vaultId, currentVaultDebt);
    a.stablex().burn(msg.sender, stableXToPay);

    // send the collateral to the liquidator
    a.vaultsData().setCollateralBalance(_vaultId, v.collateralBalance.sub(collateralToReceive));
    IERC20 asset = IERC20(v.collateralType);
    asset.safeTransfer(msg.sender, collateralToReceive);

    emit Liquidated(_vaultId, stableXToPay, collateralToReceive, v.owner, msg.sender);
  }
}