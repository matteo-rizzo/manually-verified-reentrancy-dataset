pragma solidity ^0.4.24;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    function pay(uint256 amt) internal {
        (bool success, ) = msg.sender.call.value(amt)("");
        require(success, "Call failed");
    }

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        pay(amt);
        update();
    }

    function update() internal {
        balances[msg.sender] = 0;    // side effect is folded and AFTER the folded call, making this vulnerable
    }

    function deposit() public  {
        balances[msg.sender] += msg.value;       
    }

}