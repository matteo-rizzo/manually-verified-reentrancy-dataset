import { NetworkConnection } from "hardhat/types/network";
import { runContractWithBuilder } from "../lib.js";
import { crossContractModuleBuilder } from "../../ignition/helpers/cross-contract/cross-contract-call.js";
import { crossContractAccessControlToggle1ModuleBuilder, crossContractAccessControlToggle2ModuleBuilder } from "../../ignition/helpers/cross-contract/access-control-toggle.js";
import { crossContractAccessControlHuman2ModuleBuilder } from "../../ignition/helpers/cross-contract/access-control-human.js";
import { crossContractCreateModuleBuilder, crossContractCreateModuleBuilder2, crossContractCreate2ModuleBuilder } from "../../ignition/helpers/cross-contract/create.js";
import { crossContractToTargetModuleBuilder } from "../../ignition/helpers/cross-contract/to-target.js";

export async function runCrossContractContracts(connection: NetworkConnection, contractNames: string[]) {
    for (const name of contractNames) {
        await runContractWithBuilder(connection, name, crossContractModuleBuilder);
    }
}

export async function runCrossContractAccessControlToggle1Contract(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractAccessControlToggle1ModuleBuilder);
}

export async function runCrossContractAccessControlToggle2Contract(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractAccessControlToggle2ModuleBuilder);
}

export async function runCrossContractAccessControlHuman2Contract(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractAccessControlHuman2ModuleBuilder);
}

export async function runCrossContractCreateContract(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractCreateModuleBuilder);
}

export async function runCrossContractCreateContract2(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractCreateModuleBuilder2);
}

export async function runCrossContractCreate2Contract(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractCreate2ModuleBuilder);
}

export async function runCrossContractToTargetContract(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractToTargetModuleBuilder);
}