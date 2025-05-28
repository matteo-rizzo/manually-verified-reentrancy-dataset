// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface SomeInterface {
    function someFunction() external returns (uint);
}

contract C {
    mapping(address => uint256) public balances;
    bool private flag;

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    function withdraw(address a, uint256 amt) nonReentrant public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        balances[msg.sender] -= SomeInterface(a).someFunction();     // sidefx inline
    }

}