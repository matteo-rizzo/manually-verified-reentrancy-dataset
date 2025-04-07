/**
 *Submitted for verification at Etherscan.io on 2021-04-11
*/

pragma solidity =0.6.6;

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)






// taken from https://medium.com/coinmonks/math-in-solidity-part-3-percents-and-proportions-4db014e080b1
// license is CC-BY-4.0



// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method






// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))


// library with helper methods for oracles that are concerned with computing average prices




// fixed window oracle that recomputes the average price for the entire period once every period
// note that the price average is only guaranteed to be over at least 1 period, but may be over a longer period
contract OracleTWAP {
    using SafeMath for uint;
    using FixedPoint for *;

    IUniswapV2Pair immutable pairRamWeth;
    IUniswapV2Pair immutable pairUsdtWeth;
    address public immutable token0;
    address public immutable token1;
    address private immutable token0USDT;
    address private immutable token1USDT;
    address public wethToken;
    address public usdtToken;
    uint256 public tokenPrice;
    uint256 public wethUSDTPrice;
    
    uint    public price0CumulativeLast;
    uint    public price1CumulativeLast;
    uint32  public blockTimestampLast;
    FixedPoint.uq112x112 public price0Average;
    FixedPoint.uq112x112 public price1Average;
    
    uint    public price0CumulativeLastForUSDT;
    uint    public price1CumulativeLastForUSDT;
    uint32  public blockTimestampLastForUSDT;
    FixedPoint.uq112x112 public price0AverageForUSDT;
    FixedPoint.uq112x112 public price1AverageForUSDT;

    constructor(address factory, address mainToken, address _wethToken, address _usdtToken) public {
        IUniswapV2Pair _pairRamWeth = IUniswapV2Pair(UniswapV2Library.pairFor(factory, mainToken, _wethToken));
        IUniswapV2Pair _pairUsdtWeth = IUniswapV2Pair(UniswapV2Library.pairFor(factory, _usdtToken, _wethToken));
        pairRamWeth = _pairRamWeth;
        pairUsdtWeth = _pairUsdtWeth;
        wethToken = _wethToken;
        usdtToken = _usdtToken;
        
        token0 = _pairRamWeth.token0();
        token1 = _pairRamWeth.token1();
        price0CumulativeLast = _pairRamWeth.price0CumulativeLast(); // fetch the current accumulated price value (1 / 0)
        price1CumulativeLast = _pairRamWeth.price1CumulativeLast(); // fetch the current accumulated price value (0 / 1)
        uint112 reserve0;
        uint112 reserve1;
        (reserve0, reserve1, blockTimestampLast) = _pairRamWeth.getReserves();
        require(reserve0 != 0 && reserve1 != 0, 'OraclePrice: NO_RESERVES'); // ensure that there's liquidity in the pair
        
        token0USDT = _pairUsdtWeth.token0();
        token1USDT = _pairUsdtWeth.token1();
        price0CumulativeLastForUSDT = _pairUsdtWeth.price0CumulativeLast(); // fetch the current accumulated price value (1 / 0)
        price1CumulativeLastForUSDT = _pairUsdtWeth.price1CumulativeLast(); // fetch the current accumulated price value (0 / 1)
        uint112 reserve0USDT;
        uint112 reserve1USDT;
        (reserve0USDT, reserve1USDT, blockTimestampLastForUSDT) = _pairUsdtWeth.getReserves();
        require(reserve0USDT != 0 && reserve1USDT != 0, 'OraclePrice: NO_RESERVES USDT'); // ensure that there's liquidity in the pair
    }

    function update() internal {
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(pairRamWeth));
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - price0CumulativeLast) / timeElapsed));
        price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - price1CumulativeLast) / timeElapsed));

        price0CumulativeLast = price0Cumulative;
        price1CumulativeLast = price1Cumulative;
        blockTimestampLast = blockTimestamp;
    }
    
    function updateUsdtWeth() internal {
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(pairUsdtWeth));
        uint32 timeElapsed = blockTimestamp - blockTimestampLastForUSDT; // overflow is desired

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        price0AverageForUSDT = FixedPoint.uq112x112(uint224((price0Cumulative - price0CumulativeLastForUSDT) / timeElapsed));
        price1AverageForUSDT = FixedPoint.uq112x112(uint224((price1Cumulative - price1CumulativeLastForUSDT) / timeElapsed));

        price0CumulativeLastForUSDT = price0Cumulative;
        price1CumulativeLastForUSDT = price1Cumulative;
        blockTimestampLastForUSDT = blockTimestamp;
    }
    
    function getData() external returns (uint256, bool) {
        update();
        updateUsdtWeth();
        
        uint price = 10**18;
        if (token0 != wethToken) {
            price = price1Average.mul(10**18).decode144();
            wethUSDTPrice = price0AverageForUSDT.mul(10**18).decode144();
            wethUSDTPrice = wethUSDTPrice.mul(10**12);
            price = (wethUSDTPrice.mul(10**12)).div(price.mul(10**9)).div(10**12);
        } else {
            require(token1 != wethToken, 'OraclePrice: INVALID_TOKEN');
            price = price0Average.mul(10**18).decode144();
            wethUSDTPrice = price1AverageForUSDT.mul(10**18).decode144();
            wethUSDTPrice = wethUSDTPrice.mul(10**12);
            price = (wethUSDTPrice.mul(10**12)).div(price.mul(10**9)).div(10**12);
        }
        
        tokenPrice = price;
        
        return (price, true);
    }

    // note this will always return 0 before update has been called successfully for the first time.
    function consult(address token, uint amountIn) external view returns (uint amountOut) {
        if (token == token0) {
            amountOut = price0Average.mul(amountIn).decode144();
        } else {
            require(token == token1, 'OraclePrice: INVALID_TOKEN');
            amountOut = price1Average.mul(amountIn).decode144();
        }
    }
}