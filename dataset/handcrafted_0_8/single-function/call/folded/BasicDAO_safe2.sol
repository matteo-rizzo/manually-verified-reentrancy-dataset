pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;

    function pay(uint256 amt) internal {
        (bool success, ) = msg.sender.call{value:amt}("");
        require(success, "Call failed");
    }

    function withdraw() public {
        uint256 amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        update();
        pay(amt);
    }

    function update() internal {
        balances[msg.sender] = 0;    // side effect is folded and BEFORE the folded call, making this safe
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;       
    }

}