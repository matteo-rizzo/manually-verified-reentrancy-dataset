import { lowLevelToSenderModuleBuilder, twoStepsAttackerModuleBuilder } from "../../../../ignition/helpers/single-function/low-level-call.js";
import { ethers } from "ethers";
import { NetworkConnection } from "hardhat/types/network";
import { printBalance } from "../../../lib.js";

export async function runSingleFunctionToSenderContracts(connection: NetworkConnection, contractNames: string[]) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    for (const name of contractNames) {
        const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

        await deployLowLevelToSenderContract(connection, name);

        const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

        printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
        printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
        printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
    }
}

export async function deployLowLevelToSenderContract(connection: NetworkConnection, name: string) {
    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(lowLevelToSenderModuleBuilder(name));
}

export async function runSingleFunctionToSenderBlockReeContract(connection: NetworkConnection, contractName: string) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();


    const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

    console.log(`Deploying and running: ${contractName}`);
    await connection.ignition.deploy(twoStepsAttackerModuleBuilder(contractName));

    const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

    printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
    printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
    printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);

}
