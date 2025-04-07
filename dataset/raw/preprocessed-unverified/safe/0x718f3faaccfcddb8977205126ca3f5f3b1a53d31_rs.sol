// SPDX-License-Identifier: MIT

/*
MIT License

Copyright (c) 2020 Rebased

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

pragma solidity 0.5.17;













// computes square roots using the babylonian method
// https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method


// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))




// library with helper methods for oracles that are concerned with computing average prices



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */



/**
 * @title REB price Oracle
 *      This Oracle calculates the average USD price of REB based on the ETH/REB und USDC/ETH Uniswap pools.
 */
contract RebasedOracle is IOracle, Ownable {
    using FixedPoint for *;

    uint private reb2EthPrice0CumulativeLast;
    uint private reb2EthPrice1CumulativeLast;
    uint32 private reb2EthBlockTimestampLast;
    
    uint private usdcEthPrice0CumulativeLast;
    uint private usdcEthPrice1CumulativeLast;
    uint32 private usdcEthBlockTimestampLast;
    
    address private constant _weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant _usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    IUniswapV2Pair private _reb2_eth;
    IUniswapV2Pair private _usdc_eth;
    
    address controller;
    
    modifier onlyControllerOrOwner {
        require(msg.sender == controller || msg.sender == owner());
        _;
    }

    // RebasedController: 0x41630a33d4d6e3767e26aaf50277ab2a235edea3
    // SushiSwap REB2/ETH: 0xc4dE5Cc1232f6493Cc7BF7bcb12F905eb9742Bd7
    // SushiSwap USDC/ETH: 0x397ff1542f962076d0bfe58ea045ffa2d347aca0

    constructor(
        address _controller,
        address __reb2_eth,   // Address of the ETH/REB Uniswap pair
        address __usdc_reb   // Address of the USDC/ETH Uniswap pair
        ) public {
        
        controller = _controller;

        _reb2_eth = IUniswapV2Pair(__reb2_eth);
        _usdc_eth = IUniswapV2Pair(__usdc_reb);
        
        uint112 _dummy1;
        uint112 _dummy2;
        
        reb2EthPrice0CumulativeLast = _reb2_eth.price0CumulativeLast();
        reb2EthPrice1CumulativeLast = _reb2_eth.price1CumulativeLast();
        
        (_dummy1, _dummy2, reb2EthBlockTimestampLast) = _reb2_eth.getReserves();
        
        usdcEthPrice0CumulativeLast = _usdc_eth.price0CumulativeLast();
        usdcEthPrice1CumulativeLast = _usdc_eth.price1CumulativeLast();
        
        (_dummy1, _dummy2, usdcEthBlockTimestampLast) = _usdc_eth.getReserves();
    }

    // Get the average price of 1 REB in Wei
    function getRebEthRate() public view returns (uint256, uint256, uint32, uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 _blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(_reb2_eth));
            
        FixedPoint.uq112x112 memory rebEthAverage = FixedPoint.uq112x112(uint224(1e9 * (price0Cumulative - reb2EthPrice0CumulativeLast) / (_blockTimestamp - reb2EthBlockTimestampLast)));
        
        return (price0Cumulative, price1Cumulative, _blockTimestamp, rebEthAverage.mul(1).decode144());
    }
    
    // Get the average price of 1 USD in Wei
    function getUsdcEthRate() public view returns (uint256, uint256, uint32, uint256) {
        (uint price0Cumulative, uint price1Cumulative, uint32 _blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(address(_usdc_eth));
            
        FixedPoint.uq112x112 memory usdcEthAverage = FixedPoint.uq112x112(uint224(1e6 * (price0Cumulative - usdcEthPrice0CumulativeLast) / (_blockTimestamp - usdcEthBlockTimestampLast)));
            
        return (price0Cumulative, price1Cumulative, _blockTimestamp, usdcEthAverage.mul(1).decode144());
    }

    // Update "last" state variables to current values
    // This is *only* called by the controller during rebase which enforces a minimum interim period of 12h.
   function update() external onlyControllerOrOwner {
        
        uint rebEthAverage;
        uint usdcEthAverage;
        
        (reb2EthPrice0CumulativeLast, reb2EthPrice1CumulativeLast, reb2EthBlockTimestampLast, rebEthAverage) = getRebEthRate();
        (usdcEthPrice0CumulativeLast, usdcEthPrice1CumulativeLast, usdcEthBlockTimestampLast, usdcEthAverage) = getUsdcEthRate();
    }

    // Return the average price since last update
    function getData() external view returns (uint256) {
        
        uint _price0CumulativeLast;
        uint _price1CumulativeLast;
        uint32 _blockTimestampLast;
        
        uint rebEthAverage;

        (_price0CumulativeLast, _price1CumulativeLast, _blockTimestampLast, rebEthAverage) = getRebEthRate();
        
        uint usdcEthAverage;
        
         (_price0CumulativeLast, _price1CumulativeLast, _blockTimestampLast, usdcEthAverage) = getUsdcEthRate();
         
        uint answer = (rebEthAverage * 1e18) / usdcEthAverage;
        
        return (answer);
    }
}