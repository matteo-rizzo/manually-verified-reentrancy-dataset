// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract C {
    mapping (address => uint256) public balances;

    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        unchecked {
            balances[msg.sender] -= amt;    // disabling Solidity 0.8+ underflow check makes this vulnerable as in previous language versions
        }
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}