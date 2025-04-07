/**
 *Submitted for verification at Etherscan.io on 2020-11-15
*/

pragma solidity =0.6.6;



// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method










contract UniswapOracle {

  using FixedPoint for *;
  using SafeMath for uint;

  struct PriceData {
    address token0;
    address token1;

    uint    token0Decimals;
    uint    token1Decimals;

    uint    price0CumulativeLast;
    uint    price1CumulativeLast;
    uint    blockTimestampLast;

    FixedPoint.uq112x112 price0Average;
    FixedPoint.uq112x112 price1Average;
  }

  mapping (address => PriceData) private pairs;

  uint public constant PERIOD = 10 minutes;

  function addPair(address _pair) public {
    PriceData storage priceData = pairs[_pair];
    require(priceData.token0 == address(0) && priceData.token1 == address(0), "UniswapOracle: pair already added");

    IUniswapV2Pair uniswapPair = IUniswapV2Pair(_pair);

    priceData.token0 = uniswapPair.token0();
    priceData.token1 = uniswapPair.token1();
    priceData.token0Decimals = IERC20(priceData.token0).decimals();
    priceData.token1Decimals = IERC20(priceData.token1).decimals();

    update(_pair);
  }

  function update(address _pair) public {
    PriceData storage priceData = pairs[_pair];
    require(priceData.token0 != address(0), "UniswapOracle: pair not supported");

    uint timeElapsed = block.timestamp.sub(priceData.blockTimestampLast);
    require(timeElapsed > PERIOD, "UniswapOracle: too early");

    IUniswapV2Pair uniswapPair = IUniswapV2Pair(_pair);

    priceData.price0CumulativeLast = uniswapPair.price0CumulativeLast();
    priceData.price1CumulativeLast = uniswapPair.price1CumulativeLast();

    uint112 reserve0;
    uint112 reserve1;
    (reserve0, reserve1, priceData.blockTimestampLast) = uniswapPair.getReserves();

    // Keep the last price if there are no reserves in the pair.
    if (reserve0 != 0 && reserve1 != 0) {

      (uint price0Cumulative, uint price1Cumulative, uint32 _) = UniswapV2OracleLibrary.currentCumulativePrices(address(uniswapPair));
      uint timeElapsed = block.timestamp.sub(priceData.blockTimestampLast);

      // overflow is desired, casting never truncates
      // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
      priceData.price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - priceData.price0CumulativeLast) / timeElapsed));
      priceData.price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - priceData.price1CumulativeLast) / timeElapsed));

      priceData.price0CumulativeLast = price0Cumulative;
      priceData.price1CumulativeLast = price1Cumulative;
      priceData.blockTimestampLast = block.timestamp;
    }
  }

  function consult(address _pair) external view returns (uint amountOut) {
    return uint(pairs[_pair].price1Average.mul(1e18).decode144());
  }

  function lastUpdateAt(address _pair) external view returns(uint) {
    return pairs[_pair].blockTimestampLast;
  }
}