pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function transfer(uint256 amt) external returns (bool);
}

contract C {
    mapping (address => uint256) public balances;

    function withdraw(address addr) public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = I(addr).transfer(amt);   // the implementation is unknown and could be malicious
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect is after external call
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}



