pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function getSomething() external returns (uint256);
}

contract C {
    uint256 private someValue;

    constructor(address to)  public {
        someValue = I(to).getSomething();   // this external call is always safe, as reentrancy into constructor is not possibile
    }
}