// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract CrossCall_ree1 {
    mapping (address => uint256) public balances;

    // an attacker can reenter here, producing a classic single-function reentrancy scenario
    function withdraw() public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = msg.sender.call.value(amt)();  
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect AFTER call makes this subject to reentrancy
    }

    // or can reenter here, producing a cross-function scenario
    function transfer(address to, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}