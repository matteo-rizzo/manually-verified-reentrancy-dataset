pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    // an attacker can reenter here, attempting a single-function attack that fails due to the underflow check
    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = msg.sender.call.value(amt)("");  
        require(success, "Call failed");
        balances[msg.sender] -= amt;  // side effect after external call. In this version of Solidity underflows are not automatically checked
    }

    // or can reenter here, attempting a cross-function attack that fails due to the underflow check
    function transfer(address to, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}