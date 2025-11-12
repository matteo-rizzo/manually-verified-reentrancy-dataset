import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function crossContractToTargetModuleBuilder(victimContract: string) {
    return toTargetModuleBuilder(victimContract, "ToTarget_ree1_Attacker");
}

function toTargetModuleBuilder(victimContract: string, attackerContract: string) {
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