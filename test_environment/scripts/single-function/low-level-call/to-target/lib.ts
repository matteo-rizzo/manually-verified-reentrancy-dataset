import { lowLevelToTargetModuleBuilder, moduleBuilder } from "../../../../ignition/helpers/low-level-call.js";
import { lowLevelToTargetConstructorModuleBuilder } from "../../../../ignition/modules/LowLevelToTargetContructor.js";
import { NetworkConnection } from "hardhat/types/network";
import { printBalance } from "../../../lib.js";

export async function runSingleFunctionToTargetContracts(connection: NetworkConnection, contractNames: string[], attackerContract?: string) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    for (const name of contractNames) {
        const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

        if (attackerContract) {
            await deployLowLevelToTargetContractWithAttacker(connection, name, attackerContract);
        } else {
            await deployLowLevelToTargetContract(connection, name);
        }

        const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

        printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
        printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
        printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
    }
}

export async function deployLowLevelToTargetContract(connection: NetworkConnection, name: string) {
    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(lowLevelToTargetModuleBuilder(name));
}

export async function deployLowLevelToTargetContractWithAttacker(connection: NetworkConnection, name: string, attackerContract: string) {
    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(moduleBuilder(name, attackerContract));
}

export async function deployLowLevelToTargetContractConstructor(connection: NetworkConnection, name: string) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(lowLevelToTargetConstructorModuleBuilder(name));

    const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

    printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
    printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
    printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
}

