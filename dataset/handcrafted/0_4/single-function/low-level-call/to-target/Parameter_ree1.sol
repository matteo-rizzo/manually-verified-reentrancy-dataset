pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    function pay(address target) public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = target.call.value(amt)("");    
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect AFTER the call makes this contract vulnerable to reentrancy
    }

    function deposit() public  {
        balances[msg.sender] += msg.value;       
    }

}
