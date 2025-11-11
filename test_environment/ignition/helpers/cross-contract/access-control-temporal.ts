import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function crossContractAccessTemporalVault1ModuleBuilder(victimContract: string) {
    return TemporalVault1ModuleBuilder(victimContract, "TemporalVault_ree1_Attacker");
}

export function crossContractAccessTemporalVault2ModuleBuilder(victimContract: string) {
    return TemporalVault2ModuleBuilder(victimContract, "TemporalVault_ree2_Attacker");
}

export function crossContractAccessTemporalLocker1ModuleBuilder(victimContract: string) {
    return TemporalLocker1ModuleBuilder(victimContract, "TemporalLocker_ree1_Attacker");
}

export function TemporalVault1ModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const vaultContract = m.contract("TemporalVault_ree1_Vault", [], { from: deployer });
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

export function TemporalVault2ModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const vaultContract = m.contract("TemporalVault_ree2_Vault", [], { from: deployer });
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

export function TemporalLocker1ModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const deployer = m.getAccount(0);

        // TODO 

        console.warn("TemporalLocker1ModuleBuilder is not yet implemented.");

        const crossContractree = m.contract(victimContract, [deployer], { from: deployer });
        return { crossContractree };
    });
}