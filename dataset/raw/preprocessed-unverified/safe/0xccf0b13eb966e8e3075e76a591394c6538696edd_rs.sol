/**
 *Submitted for verification at Etherscan.io on 2020-10-14
*/

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity =0.6.6;








// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method



// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))



// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)







// library with helper methods for oracles that are concerned with computing average prices


// fixed window oracle that recomputes the average price for the entire period once every period
// note that the price average is only guaranteed to be over at least 1 period, but may be over a longer period
contract ExampleOracleSimple {
    using FixedPoint for *;

    uint public constant PERIOD = 5 minutes;
    address public factory;

    constructor(address _factory) public {
        factory = _factory;
    }

    // note this will always return 0 before update has been called successfully for the first time.
    function consult(uint amountIn, address tokenA, address tokenB) external view returns (uint amountOut) {
        
        uint price0CumulativeLast;
        FixedPoint.uq112x112 memory price0Average;

        IUniswapV2Pair _pair = IUniswapV2Pair(UniswapV2Library.pairFor(factory, tokenA, tokenB));
        price0CumulativeLast = _pair.price0CumulativeLast(); // fetch the current accumulated price value (1 / 0)
    
        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(_pair));

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - price0CumulativeLast) / 5 minutes));

        amountOut = price0Average.mul(amountIn).decode144();

    }
}