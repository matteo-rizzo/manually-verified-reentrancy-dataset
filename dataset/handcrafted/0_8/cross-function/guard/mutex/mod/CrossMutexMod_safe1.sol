// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract C {
    bool private flag = false;
    mapping (address => uint256) public balances;


    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    // all functions are protected by the modifier so an attacker can not reenter anywhere and the contract is safe

    function transfer(address to, uint256 amt) nonReentrant public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    function withdraw() nonReentrant public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;   // side effect is after call, though the modifier makes this safe
    }

    function deposit() nonReentrant public payable {
        balances[msg.sender] += msg.value;       
    }

}

