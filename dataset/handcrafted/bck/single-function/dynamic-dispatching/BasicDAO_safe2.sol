pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0

interface I {
    function trasfer(uint256 amt) external view returns (bool);
}

contract C {
    mapping (address => uint256) public balances;

    function withdraw(address addr, uint256 amt) public {
        require(balances[msg.sender] >= amt, "Insufficient funds");
        bool success = I(addr).trasfer(amt);   // calls to view methods emit STATICCALL, which can reenter only through other STATICCALLs to view methods, therefore this is not vulnerable
        require(success, "Call failed");
        balances[msg.sender] -= amt;    // not vulnerable even if side effect is after external call
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}