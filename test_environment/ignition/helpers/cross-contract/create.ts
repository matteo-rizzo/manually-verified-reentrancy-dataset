import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function crossContractCreateModuleBuilder(victimContract: string) {
    return createModuleBuilder1(victimContract, "Create_ree1_Attacker");
}

export function crossContractCreateModuleBuilder2(victimContract: string) {
    return createModuleBuilder2(victimContract, "Create_ree2_Attacker");
}

export function crossContractCreate2ModuleBuilder(victimContract: string) {
    return create2ModuleBuilder(victimContract, "Create2_ree1_Attacker");
}

function createModuleBuilder1(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const crossContractree = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(crossContractree, "deposit", [], { value: oneEther, from: victim, id: "victimDeposit" });

        const victim2 = m.getAccount(2);
        m.call(crossContractree, "deposit", [], { value: oneEther, from: victim2, id: "victim2Deposit" });

        const attacker = m.getAccount(3);
        const crossContractAttacker = m.contract(attackerContract, [crossContractree], { from: attacker });
        m.call(crossContractAttacker, "attack", [], { value: oneEther, from: attacker });
        m.call(crossContractAttacker, "collectEther", [], { from: attacker });

        return { crossContractree, crossContractAttacker };
    });
}

function createModuleBuilder2(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");
        const elevenEther = ethers.parseEther("11.0");

        const deployer = m.getAccount(0);
        const crossContractree = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(crossContractree, "deploy_and_win", ["0x00", victim], { value: oneEther, from: victim, id: "victimDeploy" });

        const victim2 = m.getAccount(2);
        m.call(crossContractree, "deploy_and_win", ["0x00", victim2], { value: oneEther, from: victim2, id: "victim2Deploy" });

        const attacker = m.getAccount(3);
        const crossContractAttacker = m.contract(attackerContract, [crossContractree], { from: attacker });
        m.call(crossContractAttacker, "attack", [], { value: elevenEther, from: attacker });
        m.call(crossContractAttacker, "collectEther", [], { from: attacker });

        return { crossContractree, crossContractAttacker };
    });
}

function create2ModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");
        const elevenEther = ethers.parseEther("11.0");

        const deployer = m.getAccount(0);
        const crossContractree = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(crossContractree, "deploy_and_win", ["0x00", victim, 8848], { value: oneEther, from: victim, id: "victimDeploy" });

        const victim2 = m.getAccount(2);
        m.call(crossContractree, "deploy_and_win", ["0x00", victim2, 8611], { value: oneEther, from: victim2, id: "victim2Deploy" });

        const attacker = m.getAccount(3);
        const crossContractAttacker = m.contract(attackerContract, [crossContractree], { from: attacker });
        m.call(crossContractAttacker, "attack", [], { value: elevenEther, from: attacker });
        m.call(crossContractAttacker, "collectEther", [], { from: attacker });

        return { crossContractree, crossContractAttacker };
    });
}