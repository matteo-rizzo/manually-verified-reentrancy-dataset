// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.24;

contract Constant_safe1 {
    mapping (address => uint256) public balances;

    address private target = 0xD591678684E7c2f033b5eFF822553161bdaAd781; 

    function pay() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;    // side effect BEFORE the call makes this contract safe
        bool success = target.call.value(amt)("");    
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}
