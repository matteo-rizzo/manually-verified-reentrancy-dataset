pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;
        (msg.sender).transfer(amt);
    }

    function deposit() public  {
        balances[msg.sender] += msg.value;       
    }

}