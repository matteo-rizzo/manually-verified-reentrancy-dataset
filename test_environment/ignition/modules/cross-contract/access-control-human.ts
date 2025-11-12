import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function crossContractAccessControlHuman1ModuleBuilder(victimContract: string) {
    return Human1ModuleBuilder(victimContract, "Human_ree1_Attacker");
}

export function Human1ModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1");
        const onePoint = ethers.parseEther("1.00001");
        const twoEther = ethers.parseEther("2");

        const deployer = m.getAccount(0);
        const crossContractree = m.contract(victimContract, [], { from: deployer });

        const victim = m.getAccount(1);
        const victimBid = m.call(crossContractree, "bid", [], { value: oneEther, from: victim, id: "victimBid" });

        const victim2 = m.getAccount(2);
        const victim2Bid = m.call(crossContractree, "bid", [], { value: onePoint, from: victim2, id: "victim2Bid", after: [victimBid] });

        const attacker = m.getAccount(3);
        const attackerBid = m.call(crossContractree, "bid", [], { value: twoEther, from: attacker, id: "attackerBid", after: [victim2Bid] });
        const crossContractAttacker = m.contract(attackerContract, [crossContractree], { from: attacker, id: "deployAttacker", after: [attackerBid] });
        const address = m.staticCall(crossContractAttacker, "getAddress", []);
        const setAllowance = m.call(crossContractree, "setAllowance", [address], { from: attacker, id: "setAllowance", after: [crossContractAttacker] });
        m.call(crossContractree, "transfer", [crossContractAttacker], { from: attacker, id: "attackerTransfer", after: [setAllowance] });

        return { crossContractree, crossContractAttacker };
    });
}