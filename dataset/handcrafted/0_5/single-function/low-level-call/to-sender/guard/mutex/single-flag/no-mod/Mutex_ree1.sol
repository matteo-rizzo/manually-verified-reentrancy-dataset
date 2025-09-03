pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) private balances;

    bool private flag = false;

    function withdraw() public {
        require(!flag);

        // missing flag = true

        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect after call

        // missing flag = false
    }

    function deposit() public payable {
        require(!flag);
        balances[msg.sender] += msg.value;       
    }

}