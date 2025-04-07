/**
 *Submitted for verification at Etherscan.io on 2021-03-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;




/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SignedSafeMath` is no longer needed starting with Solidity 0.8. The compiler
 * now has built in overflow checking.
 */



contract GoldGramConvertorPriceConsumer {
    using SignedSafeMath for int;
    AggregatorV3Interface internal priceFeed;
    
    int gramPerTroyOunceForDivision = 311034768;
    
    /**
     * Network: Mainnet
     * Aggregator: XAU/USD
     * Address: 0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x214eD9Da11D2fbe465a6fc601a91E62EbEc1a0D6);
    }

    /**
     * Returns the latest price
     */
    function getLatestPrice() public view returns (int) {
        (, int price,,,) = priceFeed.latestRoundData();
         
        int priceConvertedForDivision = price.mul(10000000);
        
        return (priceConvertedForDivision.div(gramPerTroyOunceForDivision));
    }
}