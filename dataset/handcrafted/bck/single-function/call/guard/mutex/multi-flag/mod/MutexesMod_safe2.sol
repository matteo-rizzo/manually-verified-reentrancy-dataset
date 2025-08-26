pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;
    mapping (address => bool) private flags;    // mutex flags on a per-address basis

    modifier nonReentrant() {   // mutex implemented via modifier
        require(!flags[msg.sender]);
        flags[msg.sender] = true;
        _;
        flags[msg.sender] = false;
    }

    function withdraw(uint256 amt) public nonReentrant() {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[msg.sender] -= amt;    // side effect BEFORE external call respecting CEI is safe anyway
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");

    }

    function deposit() public payable nonReentrant() {
        balances[msg.sender] += msg.value;       
    }

}