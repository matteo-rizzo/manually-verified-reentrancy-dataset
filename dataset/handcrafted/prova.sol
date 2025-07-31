pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract A {
	 function m() external {
		uint64 a = 2 + 3;
	 }
}

contract C {
	function f(address a) public {
		new A().m();
		//(bool res, ) = a.call(abi.encodeWithSignature("m()"));
	}

	// function main() public {
	// 	f(msg.sender);
	// }

}