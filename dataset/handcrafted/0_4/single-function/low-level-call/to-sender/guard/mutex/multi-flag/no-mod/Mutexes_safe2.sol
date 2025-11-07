// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.22;

contract Mutexes_safe2 {
    mapping (address => uint256) private balances;
    mapping (address => bool) private flags;    // mutex flags on a per-address basis

    function withdraw() public {
        require(!flags[msg.sender]);
        flags[msg.sender] = true;

        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect BEFORE external call respecting CEI is safe anyway
        bool success = msg.sender.call.value(amt)("");
        require(success, "Call failed");

        flags[msg.sender] = false;
    }

    function deposit() public payable {
        require(!flags[msg.sender]);
        balances[msg.sender] += msg.value;       
    }
}