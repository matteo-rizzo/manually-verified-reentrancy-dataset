// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

interface I {
    function transfer() external payable returns (bool);
}

contract Cast_ree1 {
    mapping(address => uint256) public balances;

    function withdraw(address addr) public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        bool success = I(addr).transfer{value: amt}(); // the implementation is unknown and could be malicious
        require(success, "Call failed");
        balances[msg.sender] = 0; // side effect is after external call
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}
