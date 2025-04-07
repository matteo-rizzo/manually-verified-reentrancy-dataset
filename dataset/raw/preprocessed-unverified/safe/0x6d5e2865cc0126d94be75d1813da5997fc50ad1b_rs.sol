/**
 *Submitted for verification at Etherscan.io on 2021-04-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;



/// @notice A library for performing overflow-/underflow-safe math,
/// updated with awesomeness from of DappHub (https://github.com/dapphub/ds-math).




/// @title xSUSHIOracle
/// @author BoringCrypto
/// @notice Oracle used for getting the price of xSUSHI based on Chainlink SUSHI price
/// @dev
contract xSUSHIOracleV1 is IAggregator {
    using BoringMath for uint256;

    IERC20 public immutable sushi;
    IERC20 public immutable bar;
    IAggregator public immutable sushiOracle;

    constructor (IERC20 sushi_, IERC20 bar_, IAggregator sushiOracle_) public {
        sushi = sushi_;
        bar = bar_;
        sushiOracle = sushiOracle_;
    }

    // Calculates the lastest exchange rate
    // Uses sushi rate and xSUSHI conversion and divide for any conversion other than from SUSHI to ETH
    function latestAnswer() external view override returns (int256) {
        return int256(uint256(sushiOracle.latestAnswer()).mul(sushi.balanceOf(address(bar)) / bar.totalSupply()));
    }
}