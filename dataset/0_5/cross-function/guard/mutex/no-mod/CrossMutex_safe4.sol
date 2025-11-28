// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

contract CrossMutex_safe4 {
    bool private flag = false;
    mapping (address => uint256) public balances;
   
    function transfer(address to, uint256 amt) public {
        require(!flag, "Locked");
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[to] += amt;
        balances[msg.sender] -= amt;
    }

    // this function is protected by a broken mutex, although the side effect is BEFORE the call and the contract is safe anyway
    function withdraw() public {
        require(!flag, "Locked");
        // missing flag = true;
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;       // side effect before call makes this safe anyway
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");
        flag = false;
    }

    function deposit() public payable {
        require(!flag, "Locked");
        balances[msg.sender] += msg.value;       
    }

}

