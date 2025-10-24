import { runSingleFunctionToSenderContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runMutexes(connection: NetworkConnection) {
    console.log("\nTesting Mutexes Multi-flag Mod Reentrant Contracts");
    const contractNames = ["MutexesMultiModRee1", "MutexesMultiModRee2", "MutexesMultiModRee3", "MutexesMultiModRee4", "MutexesMultiModRee5"];
    await runSingleFunctionToSenderContracts(connection, contractNames);

    console.log("\nTesting Mutexes Multi-flag NoMod Reentrant Contracts");
    const noModContractNames = ["MutexesMultiNoModRee1", "MutexesMultiNoModRee2", "MutexesMultiNoModRee3", "MutexesMultiNoModRee4", "MutexesMultiNoModRee5"];
    await runSingleFunctionToSenderContracts(connection, noModContractNames);

    console.log("\nTesting Mutexes Single-flag Mod Reentrant Contracts");
    const singleFlagModContractNames = ["MutexesSingleModRee1", "MutexesSingleModRee2", "MutexesSingleModRee3", "MutexesSingleModRee4", "MutexesSingleModRee5"];
    await runSingleFunctionToSenderContracts(connection, singleFlagModContractNames);

    console.log("\nTesting Mutexes Single-flag NoMod Reentrant Contracts");
    const singleFlagNoModContractNames = ["MutexesSingleNoModRee1", "MutexesSingleNoModRee2", "MutexesSingleNoModRee3", "MutexesSingleNoModRee4", "MutexesSingleNoModRee5"];
    await runSingleFunctionToSenderContracts(connection, singleFlagNoModContractNames);
}