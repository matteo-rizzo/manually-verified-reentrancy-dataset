pragma solidity ^0.8.20;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function getSomething() external returns (uint256);
}

contract C {
    uint256 private someValue;

    constructor(address to) {
        someValue = I(to).getSomething();   // this external call is always safe, as reentrancy into constructor is not possibile
    }
}