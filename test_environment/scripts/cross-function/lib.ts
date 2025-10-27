import { crossFunctionModuleBuilder, crossFunctionTrustSwapModuleBuilder } from "../../ignition/helpers/cross-function/cross-function-call.js";
import { NetworkConnection } from "hardhat/types/network";
import { printBalance } from "../lib.js";

export async function runCrossFunctionContracts(connection: NetworkConnection, contractNames: string[]) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    for (const name of contractNames) {
        const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

        await deployCrossFunctionContract(connection, name);

        const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

        printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
        printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
        printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
    }
}

export async function runTrustSwapContracts(connection: NetworkConnection, contractNames: string[]) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    for (const name of contractNames) {
        const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

        console.log(`Deploying and running: ${name}`);
        await connection.ignition.deploy(crossFunctionTrustSwapModuleBuilder(name));

        const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

        printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
        printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
        printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
    }
}


export async function deployCrossFunctionContract(connection: NetworkConnection, name: string) {
    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(crossFunctionModuleBuilder(name));
}