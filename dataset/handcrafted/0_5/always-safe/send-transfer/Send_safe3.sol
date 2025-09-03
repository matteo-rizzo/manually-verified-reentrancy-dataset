pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;


    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;
        bool success = (msg.sender).send(amt);
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}