pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function method() external returns (bool, uint256);
}

contract C {
    mapping (address => uint256) public balances;


    function withdraw(address addr, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        (bool success, ) = I(addr).method();
        require(success, "Call failed");
        balances[msg.sender] -= amt;
    }

}