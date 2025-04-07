/**
 *Submitted for verification at Etherscan.io on 2020-10-09
*/

pragma solidity >=0.5.0;




// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))


// library with helper methods for oracles that are concerned with computing average prices


contract UniswapV20OracleContract {
    function currentCumulativePrices(
        address pair
    ) external view returns (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) {
        return UniswapV2OracleLibrary.currentCumulativePrices(pair);
    }
    
    function debug1(
        address pair
    ) external view returns (
        uint price0Cumulative,
        uint price1Cumulative,
        uint32 blockTimestamp,
        uint reserve0,
        uint reserve1,
        uint32 blockTimestampLast
    ) {
        (price0Cumulative, price1Cumulative, blockTimestamp) = UniswapV2OracleLibrary.currentCumulativePrices(pair);
        (reserve0, reserve1, blockTimestampLast) = IUniswapV2Pair(pair).getReserves();
    }
}