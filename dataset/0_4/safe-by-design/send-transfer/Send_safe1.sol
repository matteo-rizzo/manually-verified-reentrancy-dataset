// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract Send_safe1 {
    mapping (address => uint256) public balances;


    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = (msg.sender).send(amt);
        require(success, "Call failed");
        balances[msg.sender] = 0;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}