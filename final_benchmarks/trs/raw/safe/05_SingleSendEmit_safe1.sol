pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    event Sent(uint256 amt);

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        bool success1 = payable(msg.sender).send(amt);
        require(success1, "Send failed");
        balances[msg.sender] -= amt;
        emit Sent(amt);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}