pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0
contract C {
    bool private done = false;

    constructor(address  to)  public  {
        uint256 amt = msg.value;
        require(amt > 0, "Insufficient funds");
        (bool success, ) = to.call.value(amt)("");
        require(success, "Call failed");
        done = true;
    }

}