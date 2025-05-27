pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;


    function withdrawAll() public {
        (bool success, ) = msg.sender.call{value: balances[msg.sender]}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}