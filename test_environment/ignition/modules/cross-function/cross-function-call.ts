import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function crossFunctionModuleBuilder(victimContract: string) {
    return crossFunctionModuleBuilder1(victimContract, "CrossFunction_Attacker");
}

export function crossFunctionMutexOrderModuleBuilder(victimContract: string) {
    return crossFunctionModuleBuilder2(victimContract, "CrossMutexOrder_Attacker");
}

export function crossFunctionDoubleInitModuleBuilder(victimContract: string) {
    return crossFunctionModuleBuilder2(victimContract, "CrossDoubleInit_Attacker");
}

export function crossFunctionModuleBuilder2(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const crossFunctionRee = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(crossFunctionRee, "deposit", [], { value: oneEther, from: victim, id: "victimDeposit" });

        const victim2 = m.getAccount(2);
        m.call(crossFunctionRee, "deposit", [], { value: oneEther, from: victim2, id: "victim2Deposit" });

        const attacker = m.getAccount(3);
        const crossFunctionAttacker = m.contract(attackerContract, [crossFunctionRee], { from: attacker });
        m.call(crossFunctionAttacker, "attack", [], { value: oneEther, from: attacker });
        m.call(crossFunctionAttacker, "collectEther", [], { from: attacker });

        return { crossFunctionRee, crossFunctionAttacker };
    });
}

export function crossFunctionModuleBuilder1(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const crossFunctionRee = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(crossFunctionRee, "deposit", [], { value: oneEther, from: victim, id: "victimDeposit" });

        const victim2 = m.getAccount(2);
        m.call(crossFunctionRee, "deposit", [], { value: oneEther, from: victim2, id: "victim2Deposit" });

        const attacker = m.getAccount(3);
        const crossFunctionAttacker = m.contract(attackerContract, [crossFunctionRee], { from: attacker });
        m.call(crossFunctionAttacker, "attackStep1", [], { value: oneEther, from: attacker });
        m.call(crossFunctionAttacker, "attackStep2", [], { from: attacker });
        m.call(crossFunctionAttacker, "attackStep3", [], { from: attacker });
        m.call(crossFunctionAttacker, "collectEther", [], { from: attacker });

        return { crossFunctionRee, crossFunctionAttacker };
    });
}