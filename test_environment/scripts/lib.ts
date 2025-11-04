import { IgnitionModule, IgnitionModuleResult } from "@nomicfoundation/ignition-core";
import { ethers } from "ethers";
import { NetworkConnection } from "hardhat/types/network";

export async function runContractWithBuilder(connection: NetworkConnection, name: string, builder: (arg0: string, arg1?: string) => IgnitionModule<string, string, IgnitionModuleResult<string>>, attackerContract?: string) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

    await deployContract(connection, name, builder, attackerContract);

    const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

    printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
    printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
    printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
}

async function deployContract(connection: NetworkConnection, name: string, builder: (arg0: string, arg1?: string) => IgnitionModule<string, string, IgnitionModuleResult<string>>, attackerContract?: string) {
    console.log(`Deploying and running: ${name}`);
    if (attackerContract) {
        await connection.ignition.deploy(builder(name, attackerContract));
    } else {
        await connection.ignition.deploy(builder(name));
    }
}

export function printBalance(name: string, balanceBefore: bigint, balanceAfter: bigint) {
    console.log(`${name} balance: ${parseEther(balanceBefore)} ETH -> ${parseEther(balanceAfter)} ETH`);
}

export function parseEther(amount: bigint): number {
    return parseFloat(parseFloat(ethers.formatEther(amount)).toFixed(2));
}