import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function methodInvocationModuleBuilder(victimContract: string) {
    return moduleBuilder(victimContract, "MethodInvocationAttacker");
}

// export function lowLevelToTargetModuleBuilder(victimContract: string) {
//     return moduleBuilder(victimContract, "LowLevelCallToTargetAttacker");
// }

export function moduleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const methodInvocationRee = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(methodInvocationRee, "deposit", [], { value: oneEther, from: victim, id: "victimDeposit" });

        const victim2 = m.getAccount(2);
        m.call(methodInvocationRee, "deposit", [], { value: oneEther, from: victim2, id: "victim2Deposit" });

        const attacker = m.getAccount(3);
        const lowLevelCallAttacker = m.contract(attackerContract, [methodInvocationRee], { from: attacker });
        m.call(lowLevelCallAttacker, "attack", [], { value: oneEther, from: attacker });
        m.call(lowLevelCallAttacker, "collectEther", [], { from: attacker });

        return { methodInvocationRee, lowLevelCallAttacker };
    });
}