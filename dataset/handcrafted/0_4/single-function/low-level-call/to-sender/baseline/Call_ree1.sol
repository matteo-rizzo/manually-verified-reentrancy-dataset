// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.22;

contract Call_ree1 {
    mapping (address => uint256) public balances;


    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = msg.sender.call.value(amt)("");
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect AFTER call makes this vulnerable to reentrancy
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }
}

