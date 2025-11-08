// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Mutex_safe3 {
    mapping (address => uint256) private balances;

    bool private flag = false;

    function withdraw() public {
        require(!flag);
        // missing flag = true breaks mutex

        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect BEFORE external call is safe anyway, even with broken mutex
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");

        flag = false;
    }

    function deposit() public payable {
        require(!flag);
        balances[msg.sender] += msg.value;       
    }
}