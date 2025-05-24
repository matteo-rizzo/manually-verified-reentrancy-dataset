pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    error InsufficientFunds(address caller, uint256 amt);

    function withdraw(uint256 amt) public {
        if(balances[msg.sender] < amt)
            revert InsufficientFunds(msg.sender, amt);
        balances[msg.sender] -= amt;
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}