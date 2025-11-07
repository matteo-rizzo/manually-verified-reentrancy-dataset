// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.22;

contract Create_safe1 {
    mapping (address => uint256) public balances;


    function deploy_and_transfer(bytes memory initCode) public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");      

        balances[msg.sender] = 0;    // side effect BEFORE constructor call prevents reentrancy

        // the following assembly block is equivalent to the classic external call
        // bool success = msg.sender.call.value(amt)("");
		address addr;
        assembly {
            addr := create(amt, add(initCode, 0x20), mload(initCode))   // this instantiates a new contract using the initCode argument as custom constructor code
            if iszero(addr) {
                revert(0, 0)
            }
        }

    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }
}
