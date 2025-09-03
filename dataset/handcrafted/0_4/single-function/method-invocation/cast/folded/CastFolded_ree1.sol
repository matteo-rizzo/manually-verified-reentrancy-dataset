pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function transfer(uint256 amt) external returns (bool);
}

contract C {
    mapping (address => uint256) public balances;

    function pay(address addr, uint256 amt) internal {
        bool success = I(addr).transfer(amt);   // the implementation is unknown and could be malicious
        require(success, "Call failed");
    }

    function withdraw(address addr) public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        pay(addr, amt);
        balances[msg.sender] = 0;    // side effect AFTER the folded call makes this vulnerable
    }

    function deposit() public  {
        balances[msg.sender] += msg.value;       
    }

}