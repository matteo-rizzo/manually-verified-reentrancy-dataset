pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;

    bool private flag = false;

    modifier nonReentrant() {   // mutex implemented via modifier
        require(!flag);
        // missing flag = true
        _;
        flag = false;
    }

    function withdraw(uint256 amt) nonReentrant() public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[msg.sender] -= amt;    // side effect BEFORE external call is safe even with broken mutex
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
    }

    function deposit() public payable nonReentrant() {
        balances[msg.sender] += msg.value;       
    }
}