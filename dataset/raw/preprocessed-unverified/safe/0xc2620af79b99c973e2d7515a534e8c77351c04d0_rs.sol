/*

    Copyright 2020 The Hydro Protocol Foundation

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

pragma solidity 0.5.8;





contract MakerDaoOracleProxy is Ownable {

    address public asset;
    address public makerDaoOracle;
    uint256 public decimals;
    uint256 public sparePrice;
    uint256 public sparePriceBlockNumber;

    event PriceFeed(
        uint256 price,
        uint256 blockNumber
    );

    constructor (address _asset, address _makerDaoOracle, uint256 _decimals)
        public
    {
        asset = _asset;
        makerDaoOracle = _makerDaoOracle;
        decimals = _decimals;
    }

    function getPrice(
        address _asset
    )
        external
        view
        returns (uint256)
    {
        require(_asset == asset, "ASSET_NOT_MATCH");

        (bytes32 value, bool has) = IMakerDaoOracle(makerDaoOracle).peek();

        if (has) {
            return uint256(value) * (10 ** (18 - decimals));
        } else {
            require(block.number - sparePriceBlockNumber <= 3600, "ORACLE_OFFLINE");
            return sparePrice;
        }
    }

    function feed(
        uint256 newSparePrice,
        uint256 blockNumber
    )
        external
        onlyOwner
    {
        require(newSparePrice > 0, "PRICE_MUST_GREATER_THAN_0");
        require(blockNumber <= block.number && blockNumber >= sparePriceBlockNumber, "BLOCKNUMBER_WRONG");

        sparePrice = newSparePrice;
        sparePriceBlockNumber = blockNumber;

        emit PriceFeed(newSparePrice, blockNumber);
    }
}