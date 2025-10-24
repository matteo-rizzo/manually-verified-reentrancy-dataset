import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function lowLevelToSenderModuleBuilder(victimContract: string) {
    return moduleBuilder(victimContract, "LowLevelCallToSenderAttacker");
}

export function lowLevelToTargetModuleBuilder(victimContract: string) {
    return moduleBuilder(victimContract, "LowLevelCallToTargetAttacker");
}

export function moduleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const lowLevelCallree = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(lowLevelCallree, "deposit", [], { value: oneEther, from: victim, id: "victimDeposit" });

        const victim2 = m.getAccount(2);
        m.call(lowLevelCallree, "deposit", [], { value: oneEther, from: victim2, id: "victim2Deposit" });

        const attacker = m.getAccount(3);
        const lowLevelCallAttacker = m.contract(attackerContract, [lowLevelCallree], { from: attacker });
        m.call(lowLevelCallAttacker, "attack", [], { value: oneEther, from: attacker });
        m.call(lowLevelCallAttacker, "collectEther", [], { from: attacker });

        return { lowLevelCallree, lowLevelCallAttacker };
    });
}

export function twoStepsAttackerModuleBuilder(victimContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const lowLevelCallree = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(lowLevelCallree, "deposit", [], { value: oneEther, from: victim, id: "victimDeposit" });

        const victim2 = m.getAccount(2);
        m.call(lowLevelCallree, "deposit", [], { value: oneEther, from: victim2, id: "victim2Deposit" });

        const attacker = m.getAccount(3);
        const lowLevelCallAttacker = m.contract("LowLevelCallToSenderAttackerTwoSteps", [lowLevelCallree], { from: attacker });
        m.call(lowLevelCallAttacker, "attackStep1", [], { value: oneEther, from: attacker });
        m.call(lowLevelCallAttacker, "attackStep2", [], { from: attacker });
        m.call(lowLevelCallAttacker, "collectEther", [], { from: attacker });

        return { lowLevelCallree, lowLevelCallAttacker };
    });
}