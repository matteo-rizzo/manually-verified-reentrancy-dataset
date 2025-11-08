// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract CallGas_safe2 {
    mapping (address => uint256) public balances;

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value:amt, gas:2300}("");
        require(success, "Call failed");
        balances[msg.sender] = 0;    // side effect AFTER external call is still safe because the attacker has not enough gas to re-enter
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}