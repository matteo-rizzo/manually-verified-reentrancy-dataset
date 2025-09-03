pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;

    bool private flag = false;

    function withdraw() public {
        require(!flag);
        flag = true;

        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect BEFORE external call respecting CEI
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");

        flag = false;
    }

    function deposit() public  {
        require(!flag);
        balances[msg.sender] += msg.value;       
    }
}