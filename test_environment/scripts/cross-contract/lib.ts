import { NetworkConnection } from "hardhat/types/network";
import { runContractWithBuilder } from "../lib.js";
import { crossContractAccessTemporalVault1ModuleBuilder, crossContractAccessTemporalVault2ModuleBuilder, crossContractAccessTemporalLocker1ModuleBuilder } from "../../ignition/modules/cross-contract/access-control-temporal.js";
import { crossContractAccessControlHuman1ModuleBuilder } from "../../ignition/modules/cross-contract/access-control-human.js";
import { crossContractCreateModuleBuilder, crossContractCreateModuleBuilder2, crossContractCreate2ModuleBuilder } from "../../ignition/modules/cross-contract/create.js";
import { crossContractToTargetModuleBuilder } from "../../ignition/modules/cross-contract/to-target.js";

export async function runCrossContractTemporalVault1Contract(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractAccessTemporalVault1ModuleBuilder);
}

export async function runCrossContractTemporalVault2Contract(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractAccessTemporalVault2ModuleBuilder);
}

export async function runCrossContractTemporalLocker1Contract(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractAccessTemporalLocker1ModuleBuilder);
}

export async function runCrossContractAccessControlHuman1Contract(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, crossContractAccessControlHuman1ModuleBuilder);
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