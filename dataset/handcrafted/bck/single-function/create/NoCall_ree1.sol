pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0


contract C {
	uint256 private totaldeployed;

	constructor(){
		totaldeployed = 0;
	}

    function deploy(bytes memory initCode, bytes32 salt) public returns (address) {
		require(totaldeployed < 100);

		address addr;
        assembly {
            addr := create2(0, add(initCode, 0x20), mload(initCode), salt)
            if iszero(addr) {
                revert(0, 0)
            }
        }

		totaldeployed += 1; // side effect
		return addr;
    }
}