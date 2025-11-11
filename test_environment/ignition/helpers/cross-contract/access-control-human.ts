import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function crossContractAccessControlHuman1ModuleBuilder(victimContract: string) {
    return Human1ModuleBuilder(victimContract, "Human_ree1_Attacker");
}

export function crossContractAccessControlHuman2ModuleBuilder(victimContract: string) {
    return Human2ModuleBuilder(victimContract, "Human_ree2_Attacker");
}

export function Human1ModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const crossContractree = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(crossContractree, "buyKey", [victim], { value: oneEther, from: victim, id: "victimBuy" });

        const victim2 = m.getAccount(2);
        m.call(crossContractree, "buyKey", [victim2], { value: oneEther, from: victim2, id: "victim2Buy" });

        const attacker = m.getAccount(3);
        const crossContractAttacker = m.contract(attackerContract, [crossContractree], { from: attacker });
        m.call(crossContractAttacker, "attack", [], { value: oneEther, from: attacker });
        m.call(crossContractAttacker, "collectEther", [], { from: attacker });

        return { crossContractree, crossContractAttacker };
    });
}

export function Human2ModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1");

        const deployer = m.getAccount(0);
        const crossContractree = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        m.call(crossContractree, "bid", [], { value: oneEther, from: victim, id: "victimBid" });

        const victim2 = m.getAccount(2);
        m.call(crossContractree, "bid", [], { value: oneEther, from: victim2, id: "victim2Bid" });

        const attacker = m.getAccount(3);
        const crossContractAttacker = m.contract(attackerContract, [], { from: attacker });
        m.call(crossContractAttacker, "attack", [crossContractree], { value: oneEther, from: attacker });
        m.call(crossContractAttacker, "collectEther", [], { from: attacker });

        return { crossContractree, crossContractAttacker };
    });
}