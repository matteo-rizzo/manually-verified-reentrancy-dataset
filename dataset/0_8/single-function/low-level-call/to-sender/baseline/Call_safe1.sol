// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Call_safe1 {
    mapping(address => uint256) public balances;

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0; // side effect BEFORE external call makes this safe
        (bool success, ) = msg.sender.call{value: amt}("");
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}
