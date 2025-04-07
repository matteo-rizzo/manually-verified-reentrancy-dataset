/**
 *Submitted for verification at Etherscan.io on 2020-01-14
*/

pragma solidity 0.5.12;








contract CDaiExchangeRateView {
  using SafeMath for uint256;    
    
  uint256 internal constant _SCALING_FACTOR = 1e18;

  CTokenInterface internal constant _CDAI = CTokenInterface(
    0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643 // mainnet
  );   
    
  /**
   * @notice Internal view function to get the current cDai exchange rate.
   * @return The current cDai exchange rate, or amount of Dai that is redeemable
   * for each cDai (with 18 decimal places added to the returned exchange rate).
   */
  function getCurrentExchangeRate() external view returns (uint256 exchangeRate) {
    uint256 storedExchangeRate = _CDAI.exchangeRateStored();
    uint256 blockDelta = block.number.sub(_CDAI.accrualBlockNumber());

    if (blockDelta == 0) return storedExchangeRate;

    exchangeRate = blockDelta == 0 ? storedExchangeRate : storedExchangeRate.add(
      storedExchangeRate.mul(
        _CDAI.supplyRatePerBlock().mul(blockDelta)
      ) / _SCALING_FACTOR
    );
  }
}