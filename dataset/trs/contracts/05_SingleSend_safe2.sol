pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;


    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        bool success = payable(msg.sender).send(amt);
        if(!success) revert();
        balances[msg.sender] -= amt;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}