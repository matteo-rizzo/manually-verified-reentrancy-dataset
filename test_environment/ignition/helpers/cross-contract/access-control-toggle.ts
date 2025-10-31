import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function crossContractAccessControlToggle1ModuleBuilder(victimContract: string) {
    return Toggle1ModuleBuilder(victimContract, "ToggleRee1Attacker");
}

export function crossContractAccessControlToggle2ModuleBuilder(victimContract: string) {
    return Toggle2ModuleBuilder(victimContract, "ToggleRee2Attacker");
}

export function Toggle1ModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const vaultContract = m.contract("Vault", [], { from: deployer });
        const crossContractree = m.contract(victimContract, [vaultContract], { from: deployer });
        m.call(vaultContract, "setAdmin", [crossContractree], { from: deployer });

        const victim = m.getAccount(1);
        m.send("victimDeposit", crossContractree, oneEther, undefined, { from: victim });

        const victim2 = m.getAccount(2);
        m.send("victim2Deposit", crossContractree, oneEther, undefined, { from: victim2 });

        const attacker = m.getAccount(3);
        const crossContractAttacker = m.contract(attackerContract, [vaultContract, crossContractree], { from: attacker });
        m.call(crossContractAttacker, "attack", [], { value: oneEther, from: attacker });
        m.call(crossContractAttacker, "collectEther", [], { from: attacker });

        return { crossContractree, crossContractAttacker };
    });
}

export function Toggle2ModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const vaultContract = m.contract("Vault2", [], { from: deployer });
        const crossContractree = m.contract(victimContract, [vaultContract], { from: deployer });
        m.call(vaultContract, "setAdmin", [crossContractree], { from: deployer });

        const victim = m.getAccount(1);
        m.send("victimDeposit", crossContractree, oneEther, undefined, { from: victim });

        const victim2 = m.getAccount(2);
        m.send("victim2Deposit", crossContractree, oneEther, undefined, { from: victim2 });

        const attacker = m.getAccount(3);
        const crossContractAttacker = m.contract(attackerContract, [vaultContract, crossContractree], { from: attacker });
        m.call(crossContractAttacker, "attack", [], { value: oneEther, from: attacker });
        m.call(crossContractAttacker, "collectEther", [], { from: attacker });

        return { crossContractree, crossContractAttacker };
    });
}