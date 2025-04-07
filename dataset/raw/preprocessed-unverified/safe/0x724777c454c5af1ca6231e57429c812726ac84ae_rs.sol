/**
 *Submitted for verification at Etherscan.io on 2021-05-15
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;





contract PriceOracle is Ownable {

  mapping(address => ILinkOracle) public linkOracles;
  mapping(address => uint) private tokenPrices;

  function addLinkOracle(address _token, ILinkOracle _linkOracle) public onlyOwner {
    require(_linkOracle.decimals() == 8, "PriceOracle: non-usd pairs not allowed");
    linkOracles[_token] = _linkOracle;
  }

  function setTokenPrice(address _token, uint _value) public onlyOwner {
    tokenPrices[_token] = _value;
  }

  // _token price in USD with 18 decimals
  function tokenPrice(address _token) public view returns(uint) {

    if (address(linkOracles[_token]) != address(0)) {
      return linkOracles[_token].latestAnswer() * 1e10;

    } else if (tokenPrices[_token] != 0) {
      return tokenPrices[_token];

    } else {
      revert("PriceOracle: token not supported");
    }
  }

  function tokenSupported(address _token) public view returns(bool) {
    return (
      address(linkOracles[_token]) != address(0) ||
      tokenPrices[_token] != 0
    );
  }
}