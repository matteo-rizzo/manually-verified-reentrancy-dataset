/**
 *Submitted for verification at Etherscan.io on 2020-11-03
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity ^0.6.8;
pragma experimental ABIEncoderV2;




















contract PoolDataProvider is IPoolDataProvider {
  constructor() public {}

  address public constant MOCK_USD_ADDRESS = 0x10F7Fc1F91Ba351f9C629c5947AD69bD03C05b96;

  function getReservesData(ILendingPoolAddressesProvider provider)
    external
    override
    view
    returns (ReserveData[] memory, uint256)
  {
    ILendingPoolCore core = ILendingPoolCore(provider.getLendingPoolCore());
    IChainlinkProxyPriceProvider oracle = IChainlinkProxyPriceProvider(provider.getPriceOracle());

    address[] memory reserves = core.getReserves();
    ReserveData[] memory reservesData = new ReserveData[](reserves.length);

    address reserve;
    for (uint256 i = 0; i < reserves.length; i++) {
      reserve = reserves[i];
      ReserveData memory reserveData = reservesData[i];

      // base asset info
      reserveData.aTokenAddress = core.getReserveATokenAddress(reserve);
      IAToken assetDetails = IAToken(reserveData.aTokenAddress);
      reserveData.decimals = assetDetails.decimals();
      // we're getting this info from the aToken, because some of assets can be not compliant with ETC20Detailed
      reserveData.symbol = assetDetails.symbol();
      reserveData.name = '';

      // reserve configuration
      reserveData.underlyingAsset = reserve;
      reserveData.isActive = core.getReserveIsActive(reserve);
      reserveData.isFreezed = core.getReserveIsFreezed(reserve);
      (
        ,
        reserveData.baseLTVasCollateral,
        reserveData.reserveLiquidationThreshold,
        reserveData.usageAsCollateralEnabled
      ) = core.getReserveConfiguration(reserve);
      reserveData.stableBorrowRateEnabled = core.getReserveIsStableBorrowRateEnabled(reserve);
      reserveData.borrowingEnabled = core.isReserveBorrowingEnabled(reserve);
      reserveData.reserveLiquidationBonus = core.getReserveLiquidationBonus(reserve);
      reserveData.priceInEth = oracle.getAssetPrice(reserve);

      // reserve current state
      reserveData.totalLiquidity = core.getReserveTotalLiquidity(reserve);
      reserveData.availableLiquidity = core.getReserveAvailableLiquidity(reserve);
      reserveData.totalBorrowsStable = core.getReserveTotalBorrowsStable(reserve);
      reserveData.totalBorrowsVariable = core.getReserveTotalBorrowsVariable(reserve);
      reserveData.liquidityRate = core.getReserveCurrentLiquidityRate(reserve);
      reserveData.variableBorrowRate = core.getReserveCurrentVariableBorrowRate(reserve);
      reserveData.stableBorrowRate = core.getReserveCurrentStableBorrowRate(reserve);
      reserveData.averageStableBorrowRate = core.getReserveCurrentAverageStableBorrowRate(reserve);
      reserveData.utilizationRate = core.getReserveUtilizationRate(reserve);
      reserveData.liquidityIndex = core.getReserveLiquidityCumulativeIndex(reserve);
      reserveData.variableBorrowIndex = core.getReserveVariableBorrowsCumulativeIndex(reserve);
      reserveData.lastUpdateTimestamp = core.getReserveLastUpdate(reserve);
    }
    return (reservesData, oracle.getAssetPrice(MOCK_USD_ADDRESS));
  }

  function getUserReservesData(ILendingPoolAddressesProvider provider, address user)
    external
    override
    view
    returns (UserReserveData[] memory)
  {
    ILendingPoolCore core = ILendingPoolCore(provider.getLendingPoolCore());

    address[] memory reserves = core.getReserves();
    UserReserveData[] memory userReservesData = new UserReserveData[](reserves.length);

    address reserve;
    for (uint256 i = 0; i < reserves.length; i++) {
      reserve = reserves[i];
      IAToken aToken = IAToken(core.getReserveATokenAddress(reserve));
      UserReserveData memory userReserveData = userReservesData[i];

      userReserveData.underlyingAsset = reserve;
      userReserveData.principalATokenBalance = aToken.principalBalanceOf(user);
      (userReserveData.principalBorrows, , ) = core.getUserBorrowBalances(reserve, user);
      userReserveData.borrowRateMode = core.getUserCurrentBorrowRateMode(reserve, user);
      if (userReserveData.borrowRateMode == CoreLibrary.InterestRateMode.STABLE) {
        userReserveData.borrowRate = core.getUserCurrentStableBorrowRate(reserve, user);
      }
      userReserveData.originationFee = core.getUserOriginationFee(reserve, user);
      userReserveData.variableBorrowIndex = core.getUserVariableBorrowCumulativeIndex(
        reserve,
        user
      );
      userReserveData.userBalanceIndex = aToken.getUserIndex(user);
      userReserveData.redirectedBalance = aToken.getRedirectedBalance(user);
      userReserveData.interestRedirectionAddress = aToken.getInterestRedirectionAddress(user);
      userReserveData.lastUpdateTimestamp = core.getUserLastUpdate(reserve, user);
      userReserveData.usageAsCollateralEnabledOnUser = core.isUserUseReserveAsCollateralEnabled(
        reserve,
        user
      );
    }
    return userReservesData;
  }

  /**
    Gets the total supply of all aTokens for a specific market
    @param provider The LendingPoolAddressProvider contract, different for each market.
   */
  function getAllATokenSupply(ILendingPoolAddressesProvider provider)
    external
    override
    view
    returns (ATokenSupplyData[] memory)
  {
    ILendingPoolCore core = ILendingPoolCore(provider.getLendingPoolCore());
    address[] memory allReserves = core.getReserves();
    address[] memory allATokens = new address[](allReserves.length);

    for (uint256 i = 0; i < allReserves.length; i++) {
      allATokens[i] = core.getReserveATokenAddress(allReserves[i]);
    }
    return getATokenSupply(allATokens);
  }

  /**
    Gets the total supply of associated reserve aTokens
    @param aTokens An array of aTokens addresses
   */
  function getATokenSupply(address[] memory aTokens)
    public
    override
    view
    returns (ATokenSupplyData[] memory)
  {
    ATokenSupplyData[] memory totalSuppliesData = new ATokenSupplyData[](aTokens.length);

    address aTokenAddress;
    for (uint256 i = 0; i < aTokens.length; i++) {
      aTokenAddress = aTokens[i];
      IAToken aToken = IAToken(aTokenAddress);

      totalSuppliesData[i] = ATokenSupplyData({
        name: aToken.name(),
        symbol: aToken.symbol(),
        decimals: aToken.decimals(),
        totalSupply: aToken.totalSupply(),
        aTokenAddress: aTokenAddress
      });
    }
    return totalSuppliesData;
  }
}