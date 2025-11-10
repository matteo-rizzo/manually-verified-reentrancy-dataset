// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Mutex_safe2 {
    mapping(address => uint256) private balances;

    bool private flag = false;

    function withdraw() public {
        require(!flag);
        flag = true;

        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0; // side effect BEFORE external call respecting CEI
        (bool success, ) = msg.sender.call{value: amt}("");
        require(success, "Call failed");

        flag = false;
    }

    function deposit() public payable {
        require(!flag);
        balances[msg.sender] += msg.value;
    }
}
