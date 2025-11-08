// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;


interface I {
    function trasfer(uint256 amt) external view returns (bool);
}

contract Cast_safe2 {
    mapping (address => uint256) public balances;

    function withdraw(address addr) public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = I(addr).trasfer(amt);   // calls to view methods emit STATICCALL, which can reenter only through other STATICCALLs to view methods, therefore this is not vulnerable
        require(success, "Call failed");
        balances[msg.sender] = 0;    // not vulnerable even if side effect is after external call
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}