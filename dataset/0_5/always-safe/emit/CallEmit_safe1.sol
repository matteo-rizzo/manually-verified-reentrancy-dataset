// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.5.0;

contract CallEmit_safe1 {
    mapping (address => uint256) public balances;

    event Called(uint256 amt);

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        balances[msg.sender] = 0;   // the only effect is this one and occurs before the external call
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");
        emit Called(amt);    // this is not treated as an effect, thus the contract is safe
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}