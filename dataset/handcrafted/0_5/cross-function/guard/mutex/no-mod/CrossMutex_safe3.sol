// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

contract C {
    bool private flag = false;
    mapping (address => uint256) public balances;

   
    function transfer(address to, uint256 amt) public {
        require(!flag, "Locked");
        flag = true;
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
        flag = false;
    }

    // this function is NOT protected by the mutex, but the only side effect is before the call, making it safe anyway
    function withdraw() public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;       // side effect before call
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");
    }

    function deposit() public payable {
        require(!flag, "Locked");
        balances[msg.sender] += msg.value;       
    }

}

