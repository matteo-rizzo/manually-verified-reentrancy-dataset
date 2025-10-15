pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;


    function withdraw(uint256 amt, address to) public {
        require(to.balance == 0, "Insufficient funds");
        
        (bool success, ) = msg.sender.call{value: amt}("");
        require(success, "Call failed");

        (bool success2, ) = to.call{value: msg.sender.balance}("doNothing()");
//        balances[msg.sender] = 0;    // side effect AFTER call makes this vulnerable to reentrancy
    }

    function deposit(uint256 amt) public {
        balances[msg.sender] += amt;
    }
}

