// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Oracle {
    mapping(address => uint256) public priceE18; // e.g., WBTC price in 1e18 USD
    function setPrice(address asset, uint256 pE18) external { priceE18[asset] = pE18; }
    function getPrice(address asset) external view returns (uint256) { return priceE18[asset]; }
}