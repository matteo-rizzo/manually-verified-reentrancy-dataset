/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;







// for SNX-USDC(decimals=6) price convert

contract ChainlinkSNXUSDCPriceOracleProxy {
    using SafeMath for uint256;

    address public snxEth = 0x79291A9d692Df95334B1a0B3B4AE6bC606782f8c;
    address public EthUsd = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    function getPrice() external view returns (uint256) {
        uint256 snxEthPrice = IChainlink(snxEth).latestAnswer();
        uint256 EthUsdPrice = IChainlink(EthUsd).latestAnswer();
        return snxEthPrice.mul(EthUsdPrice).div(10**20);
    }
}