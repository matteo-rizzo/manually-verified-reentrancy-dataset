// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

contract MutexMod_safe1 {
    mapping (address => uint256) private balances;

    bool private flag = false;

    modifier nonReentrant() {   // mutex implemented via modifier
        require(!flag);
        flag = true;
        _;
        flag = false;
    }

    function withdraw() nonReentrant() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect can be AFTER external call thanks to the mutex
    }

    function deposit() public payable nonReentrant() {
        balances[msg.sender] += msg.value;       
    }
}