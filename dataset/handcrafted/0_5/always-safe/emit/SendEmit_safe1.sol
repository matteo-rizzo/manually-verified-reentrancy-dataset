pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    event Sent(uint256 amt);

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = (msg.sender).send(amt);
        require(success, "Send failed");
        emit Sent(amt);           // this is not treated as an effect
        balances[msg.sender] = 0;   // the only effect is this one and occurs after the send(), which makes the contract safe
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}