/**
 *Submitted for verification at Etherscan.io on 2020-01-14
*/

pragma solidity 0.5.12;








contract CUSDCExchangeRateView {
  using SafeMath for uint256;    
    
  uint256 internal constant _SCALING_FACTOR = 1e18;

  CTokenInterface internal constant _CUSDC = CTokenInterface(
    0x39AA39c021dfbaE8faC545936693aC917d5E7563 // mainnet
  );   
    
  /**
   * @notice Internal view function to get the current cUSDC exchange rate.
   * @return The current cUSDC exchange rate, or amount of USDC that is redeemable
   * for each cUSDC (with 18 decimal places added to the returned exchange rate).
   */
  function getCurrentExchangeRate() external view returns (uint256 exchangeRate) {
    uint256 storedExchangeRate = _CUSDC.exchangeRateStored();
    uint256 blockDelta = block.number.sub(_CUSDC.accrualBlockNumber());

    if (blockDelta == 0) return storedExchangeRate;

    exchangeRate = blockDelta == 0 ? storedExchangeRate : storedExchangeRate.add(
      storedExchangeRate.mul(
        _CUSDC.supplyRatePerBlock().mul(blockDelta)
      ) / _SCALING_FACTOR
    );
  }
}