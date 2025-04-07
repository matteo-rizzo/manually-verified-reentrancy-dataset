// SPDX-License-Identifier: MIT

/*
MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

pragma solidity ^0.6.0;












// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method


// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))




// library with helper methods for oracles that are concerned with computing average prices



/**
 * @title Rebased price Oracle
 * @dev Rebased is based on the uFragments Ideal Money protocol.
 *      The Oracle calculates the average USD price of REB based on the average price since the previous query 
 *      or an earlier query if 6 hours haven't yet passed. Usually the Oracle is queried once every 12 hours
 *      by the MonetaryPolicy smart contract.
 */
contract RebasedPriceOracle is IOracle {
    using FixedPoint for *;

    uint public ethRebPrice0CumulativeLast;
    uint public ethRebPrice1CumulativeLast;
    uint32 public ethRebBlockTimestampLast;
    
    uint public usdcEthPrice0CumulativeLast;
    uint public usdcEthPrice1CumulativeLast;    
    uint32 public usdcEthBlockTimestampLast;
    
    uint public lastUpdate;
    
    uint public constant PERIOD = 6 hours; // Minimum period between updates
    
    address constant _weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address _reb = 0xE6279E1c65DD41b30bA3760DCaC3CD8bbb4420D6;
    address _usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    IUniswapV2Pair constant _eth_reb = IUniswapV2Pair(0xa89004aA11CF28B34E125c63FBc56213fb663F70);
    IUniswapV2Pair constant _usdc_eth = IUniswapV2Pair(0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc);

    constructor() public {
        
        uint112 _dummy1;
        uint112 _dummy2;
        
        ethRebPrice0CumulativeLast = _eth_reb.price0CumulativeLast();
        ethRebPrice1CumulativeLast = _eth_reb.price1CumulativeLast();
        
        (_dummy1, _dummy2, ethRebBlockTimestampLast) = _eth_reb.getReserves();
        
        usdcEthPrice0CumulativeLast = _usdc_eth.price0CumulativeLast();
        usdcEthPrice1CumulativeLast = _usdc_eth.price1CumulativeLast();
        
        (_dummy1, _dummy2, usdcEthBlockTimestampLast) = _usdc_eth.getReserves();
    }


    // Get the average price of 1 REB in Wei
    function getRebEthRate() public view returns (uint256, uint256, uint32, uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 _blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(_eth_reb));
            
        FixedPoint.uq112x112 memory rebEthAverage = FixedPoint.uq112x112(uint224(1e9 * (price1Cumulative - ethRebPrice1CumulativeLast) / (_blockTimestamp - ethRebBlockTimestampLast)));
        
        return (price0Cumulative, price1Cumulative, _blockTimestamp, rebEthAverage.mul(1).decode144());
    } 
    
    
    // Get the average price of 1 USD in Wei
    function getUsdcEthRate() public view returns  (uint256, uint256, uint32, uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 _blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(_usdc_eth));
            
        FixedPoint.uq112x112 memory usdcEthAverage = FixedPoint.uq112x112(uint224(1e6 * (price0Cumulative - usdcEthPrice0CumulativeLast) / (_blockTimestamp - usdcEthBlockTimestampLast)));
            
        return (price0Cumulative, price1Cumulative, _blockTimestamp, usdcEthAverage.mul(1).decode144());
    }

    // Update "last" state variables to current values
   function update() external {
       
        uint timeStamp = block.timestamp;
        uint timeElapsed = lastUpdate - timeStamp;
        
        // Also update state variables if at least PERIOD has elapsed.
        // Otherwise only get the average price since last update.
        
        require(timeElapsed > PERIOD,"Minimum update period has not yet elapsed");
        
        lastUpdate = timeStamp;
          
        uint _pepe;
        
        (ethRebPrice0CumulativeLast, ethRebPrice1CumulativeLast, ethRebBlockTimestampLast, _pepe) = getRebEthRate();
        (usdcEthPrice0CumulativeLast, usdcEthPrice1CumulativeLast, usdcEthBlockTimestampLast, _pepe) = getUsdcEthRate();
        
    }

    // Return the average price since last update
    function getData() external view override returns (uint256, bool) {
        
        uint _price0CumulativeLast;
        uint _price1CumulativeLast;
        uint32 _blockTimestampLast;
        
        uint rebEthAverage;

        (_price0CumulativeLast, _price1CumulativeLast, _blockTimestampLast, rebEthAverage) = getRebEthRate();
        
        uint usdcEthAverage;
        
         (_price0CumulativeLast, _price1CumulativeLast, _blockTimestampLast, usdcEthAverage) = getUsdcEthRate();
        
        uint answer = (rebEthAverage * 1e18) / usdcEthAverage;
        
        return (answer, true);
    }
}