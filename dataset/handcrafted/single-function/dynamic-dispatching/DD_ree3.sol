pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function pay() external returns (bool, uint256);
}

contract C {
    mapping (address => uint256) public balances;

    I private obj;

    constructor(address addr) {
        obj = I(addr);      // initialized at construction time
    }

    function withdraw(, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = obj.pay();   // pay() implementation is unknown and could be malicious
        require(success, "Call failed");
        balances[msg.sender] -= amt;
    }

}