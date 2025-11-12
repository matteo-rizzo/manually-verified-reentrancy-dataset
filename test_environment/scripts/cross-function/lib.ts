import { crossFunctionModuleBuilder, crossFunctionDoubleInitModuleBuilder, crossFunctionMutexOrderModuleBuilder } from "../../ignition/modules/cross-function/cross-function-call.js";
import { NetworkConnection } from "hardhat/types/network";
import { printBalance, runContractWithBuilder } from "../lib.js";

export async function runCrossFunctionContracts(connection: NetworkConnection, contractNames: string[]) {
    for (const name of contractNames) {
        await runContractWithBuilder(connection, name, crossFunctionModuleBuilder);
    }
}

export async function runDoubleInitContracts(connection: NetworkConnection, contractNames: string[]) {
    for (const name of contractNames) {
        await runContractWithBuilder(connection, name, crossFunctionDoubleInitModuleBuilder);
    }
}

export async function runCrossFunctionMutexOrderContracts(connection: NetworkConnection, contractName: string) {
    await runContractWithBuilder(connection, contractName, crossFunctionMutexOrderModuleBuilder);
}