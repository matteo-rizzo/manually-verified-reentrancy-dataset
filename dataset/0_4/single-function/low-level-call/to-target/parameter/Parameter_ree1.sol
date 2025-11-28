// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract Parameter_ree1 {
    mapping (address => uint256) public balances;

    function pay(address target) public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = target.call.value(amt)("");    
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect AFTER the call makes this contract vulnerable to reentrancy
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
