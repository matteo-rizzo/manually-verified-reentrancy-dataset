// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.22;

contract ToTarget_safe1 {
    mapping (address => uint256) public balances;

    function pay(address target) public {
        require(target != msg.sender);
        uint256 amt = balances[msg.sender];
        balances[msg.sender] = 0;    // side effect BEFORE the call makes this contract safe
        bool success = target.call.value(amt)("");    
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
