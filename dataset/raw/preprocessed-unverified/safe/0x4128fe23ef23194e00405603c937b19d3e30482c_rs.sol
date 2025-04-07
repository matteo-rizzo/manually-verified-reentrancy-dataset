/**
 *Submitted for verification at Etherscan.io on 2020-10-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;



contract PercentQuadraticVoteProxy {
    // PCT
    IERC20 public constant pct = IERC20(
        0xbc16da9df0A22f01A16BC0620a27e7D6d6488550
    );

    // Using 9 decimals as we're square rooting the votes
    function decimals() external pure returns (uint8) {
        return uint8(9);
    }

    function name() external pure returns (string memory) {
        return "Percent Quadratic Vote";
    }

    function symbol() external pure returns (string memory) {
        return "PCT QV";
    }

    function totalSupply() external view returns (uint256) {
        return sqrt(pct.totalSupply());
    }

    function balanceOf(address _voter) external view returns (uint256) {
        return sqrt(pct.balanceOf(_voter));
    }

    function sqrt(uint256 x) public pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    constructor() public {}
}