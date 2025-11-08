// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract Mutexes_ree5 {
    mapping (address => uint256) private balances;
    mapping (address => bool) private flags;    // mutex flags on a per-address basis

    function withdraw() public {
        // missing require(!flags[msg.sender]) 
        flags[msg.sender] = true;

        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = msg.sender.call.value(amt)();
        require(success, "Call failed");
        balances[msg.sender] = 0;     // side effect after call

        flags[msg.sender] = false;
    }

    function deposit() public payable {
        require(!flags[msg.sender]);
        balances[msg.sender] += msg.value;       
    }

}