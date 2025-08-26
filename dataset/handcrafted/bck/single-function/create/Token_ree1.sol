pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0


contract C {
	uint256 private totaldeployed;
	mapping (address => uint) private balances;

	constructor(){
		totaldeployed = 0;
	}

    function deploy(bytes memory initCode) public returns (address) {
		bool prize = false;
		if (totaldeployed == 1000) {
			prize = true;
		}

		address addr;
        assembly {
            addr := create(0, add(initCode, 0x20), mload(initCode))
            if iszero(addr) {
                revert(0, 0)
            }
        }

		if (prize) {
			balances[addr] += 2000;
		}

		totaldeployed += 1; // side effect		
		return addr;
    }

}