pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;
    event Withdrawn(uint amt);

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        payable(msg.sender).transfer(amt);

        (bool success, ) = msg.sender.call{value:0}("");
        require(success, "Call failed");
        balances[msg.sender] -= amt;

        emit Withdrawn(amt);
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}