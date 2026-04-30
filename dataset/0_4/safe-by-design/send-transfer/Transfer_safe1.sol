// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract Transfer_safe1 {
    mapping (address => uint256) public balances;

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (msg.sender).transfer(amt);
        balances[msg.sender] = 0;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}