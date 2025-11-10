// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract CrossUnderflow_safe1 {
    mapping(address => uint256) public balances;

    // an attacker can reenter here, attempting a single-function attack that fails due to the underflow check
    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = msg.sender.call{value: amt}("");
        require(success, "Call failed");
        balances[msg.sender] -= amt; // Solidity 0.8+ checks underflows and reverts the whole transaction, that's why it is safe even though the side effect is after the external call
    }

    // or can reenter here, attempting a cross-function attack that fails due to the underflow check
    function transfer(address to, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}
