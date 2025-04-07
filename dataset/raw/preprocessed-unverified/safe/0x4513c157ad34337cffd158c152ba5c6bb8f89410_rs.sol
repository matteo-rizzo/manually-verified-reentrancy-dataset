/**
 *Submitted for verification at Etherscan.io on 2020-11-06
*/

// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.6.12;



contract WethPriceFeed is IChainlinkAggregator {

  function latestAnswer() external view override returns (int256) {
      return 1 ether;
  }  
}