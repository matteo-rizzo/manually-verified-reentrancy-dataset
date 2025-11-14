import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { ethers } from "ethers";

export function crossContractReadOnlyModuleBuilder(victimContract: string) {
    return readOnlyModuleBuilder(victimContract, "ReadOnly_ree1_Attacker");
}

export function crossContractReadOnly3ModuleBuilder(victimContract: string) {
    return readOnly3ModuleBuilder(victimContract, "ReadOnly_ree3_Attacker");
}

function readOnlyModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");

        const deployer = m.getAccount(0);
        const crossContractreePNRG = m.contract("ReadOnly_ree1_DummyPRNG", [], { from: deployer });
        const crossContractreeOracle = m.contract("ReadOnly_ree1_Oracle", [], { from: deployer });
        const crossContractree = m.contract(victimContract, [crossContractreeOracle], { from: deployer });

        const victim = m.getAccount(1);
        m.call(crossContractree, "deposit", [crossContractreePNRG], { value: oneEther, from: victim, id: "victimDeposit" });

        const victim2 = m.getAccount(2);
        m.call(crossContractree, "deposit", [crossContractreePNRG], { value: oneEther, from: victim2, id: "victim2Deposit" });

        const attacker = m.getAccount(3);
        const crossContractAttacker = m.contract(attackerContract, [crossContractree, crossContractreeOracle], { from: attacker });
        m.call(crossContractAttacker, "attack", [], { value: oneEther, from: attacker });
        m.call(crossContractAttacker, "collectEther", [], { from: attacker });

        return { crossContractree, crossContractAttacker };
    });
}

function readOnly3ModuleBuilder(victimContract: string, attackerContract: string) {
    return buildModule(victimContract, (m) => {
        const oneEther = ethers.parseEther("1.0");
        const fourHundredEther = ethers.parseEther("400.0");

        const deployer = m.getAccount(0);
        const crossContractreeAdjuster = m.contract("ReadOnly_ree3_DummyAdjuster", [], { from: deployer });
        const crossContractreeOracle = m.contract("ReadOnly_ree3_Oracle", [], { from: deployer });
        const crossContractree = m.contract(victimContract, [crossContractreeOracle], { from: deployer });

        const victim = m.getAccount(1);
        const victimDeposit = m.send("victimDeposit", crossContractree, oneEther, undefined, { from: victim });
        m.call(crossContractreeOracle, "register", [crossContractreeAdjuster], { from: victim, id: "victimRegister" });
        m.call(crossContractreeOracle, "updateUserShare", [victim, oneEther], { from: deployer, id: "victimUpdate" });

        const victim2 = m.getAccount(2);
        const victim2Deposit = m.send("victim2Deposit", crossContractree, oneEther, undefined, { from: victim2, after: [victimDeposit] });
        m.call(crossContractreeOracle, "register", [crossContractreeAdjuster], { from: victim2, id: "victim2Register" });
        m.call(crossContractreeOracle, "updateUserShare", [victim2, oneEther], { from: deployer, id: "victim2Update" });

        const attacker = m.getAccount(3);
        const crossContractAttacker = m.contract(attackerContract, [crossContractree, crossContractreeOracle], { from: attacker, after: [victim2Deposit] });
        const attack = m.call(crossContractAttacker, "attack", [], { value: fourHundredEther, from: attacker });
        const updateUserShare = m.call(crossContractreeOracle, "updateUserShare", [crossContractAttacker, fourHundredEther], { from: deployer, id: "attackerUpdate", after: [attack] });
        m.call(crossContractAttacker, "collectEther", [], { from: attacker, after: [updateUserShare] });

        return { crossContractree, crossContractAttacker };
    });
}