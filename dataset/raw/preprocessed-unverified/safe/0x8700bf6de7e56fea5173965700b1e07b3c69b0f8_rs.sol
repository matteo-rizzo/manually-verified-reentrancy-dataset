/**
 *Submitted for verification at Etherscan.io on 2020-11-09
*/

/*

    Copyright 2020 DODO ZOO.
    SPDX-License-Identifier: Apache-2.0

*/

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;



// for AAVE-USDC(decimals=6) price convert


/**
 * @title SafeMath
 * @author DODO Breeder
 *
 * @notice Math operations with safety checks that revert on error
 */



contract ChainlinkAAVEUSDCPriceOracleProxy {
    using SafeMath for uint256;

    address public aaveEth = 0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012;
    address public EthUsd = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    function getPrice() external view returns (uint256) {
        uint256 yfiEthPrice = IChainlink(aaveEth).latestAnswer();
        uint256 EthUsdPrice = IChainlink(EthUsd).latestAnswer();
        return yfiEthPrice.mul(EthUsdPrice).div(10**20);
    }
}