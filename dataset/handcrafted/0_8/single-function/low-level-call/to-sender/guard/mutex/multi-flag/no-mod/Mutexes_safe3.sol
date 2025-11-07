// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract C {
    mapping (address => uint256) private balances;
    mapping (address => bool) private flags;    // mutex flags on a per-address basis

    function withdraw() public {
        require(!flags[msg.sender]);
        // missing flags[msg.sender] = true

        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect BEFORE external call is safe even with broken mutex
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");

        flags[msg.sender] = false;
    }

    function deposit() public payable {
        require(!flags[msg.sender]);
        balances[msg.sender] += msg.value;       
    }
}