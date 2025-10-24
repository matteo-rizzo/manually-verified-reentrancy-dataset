pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt, gas:23000}("");    // the only way to make this vulnerable 
        require(success, "Call failed");
        balances[msg.sender] = 0;   // side effect AFTER external call makes this unsafe because the attacker has enough gas to re-enter
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}