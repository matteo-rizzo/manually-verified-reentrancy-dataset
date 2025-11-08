// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract CrossMutex_ree2 {
    bool private flag = false;
    mapping (address => uint256) public balances;

    function transfer(address to, uint256 amt) public {
        require(!flag, "Locked");
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    function withdraw() public {
        require(!flag, "Locked");
        flag = true;
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = msg.sender.call.value(amt)();
        require(success, "Call failed");
        balances[msg.sender] = 0; // this is a side effect after an external call
        flag = false;
    }

    
    // this function is not protected by the mutex
    // so an attacker could potentially reenter after the external call and deposit some money, which is eventually LOST because the balance is zeroed after returning from the reentrancy
    // this means that calling deposit() for reentering produces a data corruption that does NOT produce a money theft, but rather a money LOSS
    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}

