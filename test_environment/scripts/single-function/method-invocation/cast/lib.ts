import { methodInvocationModuleBuilder } from "../../../../ignition/helpers/method-invocation.js";
import { NetworkConnection } from "hardhat/types/network";
import { printBalance } from "../../../lib.js";

export async function runMethodInvocationContracts(connection: NetworkConnection, contractNames: string[]) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    for (const name of contractNames) {
        const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

        await deployMethodInvocationContract(connection, name);

        const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

        printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
        printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
        printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
    }
}

export async function deployMethodInvocationContract(connection: NetworkConnection, name: string) {
    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(methodInvocationModuleBuilder(name));
}