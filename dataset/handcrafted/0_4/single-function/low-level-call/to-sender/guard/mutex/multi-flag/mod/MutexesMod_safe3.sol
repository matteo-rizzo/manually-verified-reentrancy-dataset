pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;
    mapping (address => bool) private flags;    // mutex flags on a per-address basis

    modifier nonReentrant() {   // mutex implemented via modifier
        require(!flags[msg.sender]);
        // missing flags[msg.sender] = true;
        _;
        flags[msg.sender] = false;
    }

    function withdraw() public nonReentrant() {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect BEFORE external call is safe even with broken modifier
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");

    }

    function deposit() public  nonReentrant() {
        balances[msg.sender] += msg.value;       
    }

}