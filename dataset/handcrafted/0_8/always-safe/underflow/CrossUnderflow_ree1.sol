// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract CrossUnderflow_ree1 {
    mapping (address => uint256) public balances;

    // an attacker can reenter here, producing a classic single-function reentrancy scenario
    function withdraw(uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");  
        require(success, "Call failed");
        unchecked {
            balances[msg.sender] -= amt;    // disabling Solidity 0.8+ underflow check makes this vulnerable as in previous language versions
        }
    }

    // or can reenter here, producing a cross-function scenario
    function transfer(address to, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}