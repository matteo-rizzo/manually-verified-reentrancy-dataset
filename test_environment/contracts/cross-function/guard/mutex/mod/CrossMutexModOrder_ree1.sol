// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract CrossMutexModOrder_ree1 {
    bool private flag = false;
    mapping(address => uint256) public balances;

    modifier nonReentrant() {
        require(!flag, "Locked");
        flag = true;
        _;
        flag = false;
    }

    modifier sendMoney() {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");
        (bool success, ) = msg.sender.call{value: amt}("");
        require(success, "Call failed");
        _;
    }

    function withdraw() public sendMoney nonReentrant {
        balances[msg.sender] = 0;
    }

    function deposit() public payable nonReentrant {
        balances[msg.sender] += msg.value;
    }
}
