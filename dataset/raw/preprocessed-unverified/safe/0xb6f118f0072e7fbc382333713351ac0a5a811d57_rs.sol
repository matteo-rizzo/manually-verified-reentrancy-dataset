/**
 *Submitted for verification at Etherscan.io on 2021-06-14
*/

pragma solidity ^0.6.7;



contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;
    AggregatorV3Interface internal priceFeedBnb;

    /**
     * Network: Mainnet
     * Aggregator: ETH/USD
     * Address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
     * Aggregator: BNB/USD
     * Address: 0x14e613AC84a31f709eadbdF89C6CC390fDc9540A
     */
    constructor() public {
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        priceFeedBnb = AggregatorV3Interface(0x14e613AC84a31f709eadbdF89C6CC390fDc9540A);
    }

    /**
     * Returns the latest price ETH
     */
    function getThePriceEth() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
    
    /**
     * Returns the latest price BNB
     */
    function getThePriceBnb() public view returns (int) {
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeedBnb.latestRoundData();
        return price;
    }
}