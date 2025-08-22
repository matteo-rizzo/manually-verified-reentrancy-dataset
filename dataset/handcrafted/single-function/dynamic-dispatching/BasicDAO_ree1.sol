pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function transfer(uint256 amt) external returns (bool);
}

contract C {
    mapping (address => uint256) public balances;

    function withdraw(address addr, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        bool success = I(addr).transfer(amt);   // the implementation is unknown and could be malicious
        require(success, "Call failed");
        balances[msg.sender] -= amt;    // side effect is after external call
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}