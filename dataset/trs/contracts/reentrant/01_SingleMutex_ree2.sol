pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    bool flag = false;
    mapping (address => uint256) public balances;


    function withdraw(uint256 amt) public {
        flag = true;


        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[msg.sender] -= amt;
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");


        flag = false;
    }

}