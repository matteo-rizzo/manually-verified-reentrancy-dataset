// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.22;


interface I {
    function getSomething() external returns (uint256);
}

contract CastCons_safe1 {
    uint256 private someValue;

    constructor(address to)  public {
        someValue = I(to).getSomething();   // this external call is always safe, as reentrancy into constructor is not possibile
    }
}