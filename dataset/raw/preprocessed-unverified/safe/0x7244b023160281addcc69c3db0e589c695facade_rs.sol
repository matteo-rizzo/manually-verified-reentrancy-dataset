/**
 *Submitted for verification at Etherscan.io on 2021-07-18
*/

/**
 *Submitted for verification at Etherscan.io on 2021-07-16
*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;



contract CxipAssetProxy {

	fallback () payable external {
		address _target = IRegistry (0x3d0Ac6CDcd6252684Fa459E7A03Dd1ceaCc01Ade).getAssetSource ();
		assembly {
			calldatacopy (0, 0, calldatasize ())
			let result := delegatecall (gas (), _target, 0, calldatasize (), 0, 0)
			returndatacopy (0, 0, returndatasize ())
			switch result
				case 0 {
					revert (0, returndatasize ())
				}
				default {
					return (0, returndatasize ())
				}
		}
	}

}