/**
 *Submitted for verification at Etherscan.io on 2021-03-02
*/

/*

    Copyright 2019 The Hydro Protocol Foundation

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/

pragma solidity ^0.6.7;




// asset WBTC

contract PriceOracleProxy {
    address asset;
    AggregatorV3Interface internal priceFeed;

    constructor() public {
        priceFeed = AggregatorV3Interface(0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);
        asset = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    }

    function getPrice(
        address _asset
    )
        external
        view
        returns (uint256)
    {
        require(asset == _asset, "ASSET_NOT_MATCH");
        (,int lastPrice,,,) = priceFeed.latestRoundData();
        require(lastPrice >= 0, "INVALID_NEGATIVE_PRICE");
        uint256 price = uint256(lastPrice);
        uint256 hydroPrice = price * 10 ** 20;
        require(hydroPrice / price == 10 ** 20, "MUL_ERROR");
        return hydroPrice;
    }
}