pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;
    mapping (address => bool) private flags;    // mutex flags on a per-address basis

    function withdraw(uint256 amt) public {
        require(!flags[msg.sender]);
        // missing flags[msg.sender] = true

        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[msg.sender] -= amt;    // side effect BEFORE external call is safe even with broken mutex
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");

        flags[msg.sender] = false;
    }

    function deposit() public payable {
        require(!flags[msg.sender]);
        balances[msg.sender] += msg.value;       
    }
}