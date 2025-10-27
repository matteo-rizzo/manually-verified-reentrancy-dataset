import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function crossContractModuleBuilder(victimContract: string) {
    return moduleBuilder(victimContract, "CrossCallAttacker");
}

export function moduleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const crossCallCallree = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(crossCallCallree, "deposit", [], { value: oneEther, from: victim, id: "victimDeposit" });

        const victim2 = m.getAccount(2);
        m.call(crossCallCallree, "deposit", [], { value: oneEther, from: victim2, id: "victim2Deposit" });

        const attacker = m.getAccount(3);
        const crossCallAttacker = m.contract(attackerContract, [crossCallCallree], { from: attacker });
        m.call(crossCallAttacker, "attack", [], { value: oneEther, from: attacker });
        m.call(crossCallAttacker, "collectEther", [], { from: attacker });

        return { crossCallCallree, crossCallAttacker };
    });
}