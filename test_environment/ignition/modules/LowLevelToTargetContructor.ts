import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function lowLevelToTargetConstructorModuleBuilder(victimContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const attacker = m.getAccount(3);
        const lowLevelCallAttacker = m.contract("LowLevelCallToTargetAttacker3", [], { from: attacker });

        const deployer = m.getAccount(0);
        const lowLevelCallree = m.contract(victimContract, [lowLevelCallAttacker], { from: deployer });

        const victim = m.getAccount(1);
        m.call(lowLevelCallree, "deposit", [], { value: oneEther, from: victim, id: "victimDeposit" });

        const victim2 = m.getAccount(2);
        m.call(lowLevelCallree, "deposit", [], { value: oneEther, from: victim2, id: "victim2Deposit" });

        m.call(lowLevelCallAttacker, "setVictim", [lowLevelCallree], { from: attacker });
        m.call(lowLevelCallAttacker, "attack", [], { value: oneEther, from: attacker });
        m.call(lowLevelCallAttacker, "collectEther", [], { from: attacker });

        return { lowLevelCallree, lowLevelCallAttacker };
    });
}