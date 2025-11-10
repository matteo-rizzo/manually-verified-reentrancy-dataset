// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract CrossMutex_safe2 {
    bool private flag = false;
    mapping(address => uint256) public balances;

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
        balances[msg.sender] = 0; // side effect is before and function is protected, so it's super safe
        (bool success, ) = msg.sender.call{value: amt}("");
        require(success, "Call failed");
        flag = false;
    }

    function deposit() public payable {
        require(!flag, "Locked");
        balances[msg.sender] += msg.value;
    }
}
