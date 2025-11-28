// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract CrossMutex_ree3 {
    bool private flag = false;
    mapping (address => uint256) public balances;

    // this function features a broken mutex, rendering the whole contract unsafe even if all other functions are protected by a proper mutex
    function transfer(address to, uint256 amt) public {
        // missing require(!flag, "Locked");
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    function withdraw() public {
        require(!flag, "Locked");
        flag = true;
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = msg.sender.call.value(amt)("");
        require(success, "Call failed");
        balances[msg.sender] = 0;   // side effect is after call making this unsafe because an attacker can reenter into transfer()
        flag = false;
    }

    function deposit() public payable {
        require(!flag, "Locked");
        balances[msg.sender] += msg.value;       
    }

}

