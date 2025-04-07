/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;







// for LEND-USDC(decimals=6) price convert

contract ChainlinkLENDUSDCPriceOracleProxy {
    using SafeMath for uint256;

    address public lendEth = 0xc9dDB0E869d931D031B24723132730Ecf3B4F74d;
    address public EthUsd = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    function getPrice() external view returns (uint256) {
        uint256 lendEthPrice = IChainlink(lendEth).latestAnswer();
        uint256 EthUsdPrice = IChainlink(EthUsd).latestAnswer();
        return lendEthPrice.mul(EthUsdPrice).div(10**20);
    }
}