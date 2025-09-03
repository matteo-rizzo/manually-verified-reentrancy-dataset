pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0
contract C {
    bool private flag = false;
    mapping (address => uint256) public balances;


    modifier nonReentrant() {
        require(!flag, "Locked");
        // missing flag = true;
        _;
        flag = false;
    }
   
    function transfer(address to, uint256 amt) nonReentrant public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    // this function is protected by a broken modifier, although the side effect is BEFORE the call and the contract is safe anyway
    function withdraw() nonReentrant public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;       // side effect before call makes this safe anyway
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");
    }

    function deposit() nonReentrant public  {
        balances[msg.sender] += msg.value;       
    }

}

