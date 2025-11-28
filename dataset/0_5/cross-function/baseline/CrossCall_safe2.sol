// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

contract CrossCall_safe1 {
    mapping (address => uint256) public balances;

    // an attacker can reenter here, producing a classic single-function reentrancy scenario
    function withdraw() public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect BEFORE call makes this safe
        (bool success, ) = msg.sender.call.value(amt)("");  
        require(success, "Call failed");
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