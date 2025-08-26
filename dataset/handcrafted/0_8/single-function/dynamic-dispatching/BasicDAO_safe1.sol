pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function transfer(uint256 amt) external returns (bool);
}

contract C {
    mapping (address => uint256) public balances;

    function withdraw(address addr, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[msg.sender] -= amt;        // side effect
        bool success = I(addr).transfer(amt);   // the implementation is unknown and could be malicious, though the side effect is before, so it's safe
        require(success, "Call failed");
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}