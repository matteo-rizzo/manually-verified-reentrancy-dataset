pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0
contract C {
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
        balances[msg.sender] = 0;    // side effect BEFORE external call respecting CEI
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");
    }

    function deposit() public  nonReentrant() {
        balances[msg.sender] += msg.value;       
    }
}