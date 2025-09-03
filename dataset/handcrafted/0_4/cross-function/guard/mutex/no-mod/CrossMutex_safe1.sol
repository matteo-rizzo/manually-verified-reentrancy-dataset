pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0
contract C {
    bool private flag = false;
    mapping (address => uint256) public balances;

    // all functions are protected by the mutex so an attacker can not reenter anywhere and the contract is safe

    function transfer(address to, uint256 amt) public {
        require(!flag, "Locked");
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    function withdraw() public {
        require(!flag, "Locked");
        flag = true;
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");
        balances[msg.sender] = 0;   // side effect is after call, though the mutex makes this safe
        flag = false;
    }

    function deposit() public  {
        require(!flag, "Locked");
        balances[msg.sender] += msg.value;       
    }

}

