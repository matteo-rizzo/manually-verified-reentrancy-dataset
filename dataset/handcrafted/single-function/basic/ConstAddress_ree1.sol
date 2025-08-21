pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    address private target = 0xD591678684E7c2f033b5eFF822553161bdaAd781;    // coin_base

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = target.call{value:amt}("");      // calls to a constant target address is potentially malicious
        require(success, "Call failed");
        balances[msg.sender] -= amt;    // side effect AFTER the call makes
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}