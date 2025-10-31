import { crossContractModuleBuilder } from "../../ignition/helpers/cross-contract/cross-contract-call.js";
import { crossContractAccessControlToggle1ModuleBuilder, crossContractAccessControlToggle2ModuleBuilder } from "../../ignition/helpers/cross-contract/access-control-toggle.js";
import { NetworkConnection } from "hardhat/types/network";
import { printBalance } from "../lib.js";
import { crossContractAccessControlHuman2ModuleBuilder } from "../../ignition/helpers/cross-contract/access-control-human.js";
import { crossContractCreateModuleBuilder } from "../../ignition/helpers/cross-contract/create.js";

export async function runCrossContractContracts(connection: NetworkConnection, contractNames: string[]) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    for (const name of contractNames) {
        const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

        await deployCrossContractContract(connection, name);

        const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
        const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
        const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

        printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
        printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
        printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
    }
}

export async function runCrossContractAccessControlToggle1Contract(connection: NetworkConnection, name: string) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();


    const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(crossContractAccessControlToggle1ModuleBuilder(name));

    const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

    printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
    printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
    printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);

}

export async function runCrossContractAccessControlToggle2Contract(connection: NetworkConnection, name: string) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(crossContractAccessControlToggle2ModuleBuilder(name));

    const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

    printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
    printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
    printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
}

export async function runCrossContractAccessControlHuman2Contract(connection: NetworkConnection, name: string) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(crossContractAccessControlHuman2ModuleBuilder(name));

    const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

    printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
    printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
    printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
}

export async function runCrossContractCreateContract(connection: NetworkConnection, name: string) {
    const [deployer, victim, victim2, attacker] = await connection.ethers.getSigners();

    const victimBalanceBefore = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceBefore = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceBefore = await connection.ethers.provider.getBalance(attacker.address);

    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(crossContractCreateModuleBuilder(name));

    const victimBalanceAfter = await connection.ethers.provider.getBalance(victim.address);
    const victim2BalanceAfter = await connection.ethers.provider.getBalance(victim2.address);
    const attackerBalanceAfter = await connection.ethers.provider.getBalance(attacker.address);

    printBalance("Victim", victimBalanceBefore, victimBalanceAfter);
    printBalance("Victim2", victim2BalanceBefore, victim2BalanceAfter);
    printBalance("Attacker", attackerBalanceBefore, attackerBalanceAfter);
}



export async function deployCrossContractContract(connection: NetworkConnection, name: string) {
    console.log(`Deploying and running: ${name}`);
    await connection.ignition.deploy(crossContractModuleBuilder(name));
}