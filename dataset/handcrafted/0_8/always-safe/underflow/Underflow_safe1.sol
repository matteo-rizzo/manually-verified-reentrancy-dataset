pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    // an attacker can reenter here, attempting a single-function attack that fails due to the underflow check
    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] -= amt;        // Solidity 0.8+ checks underflows and reverts the whole transaction, that's why it is safe even though the side effect is after the external call 
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}