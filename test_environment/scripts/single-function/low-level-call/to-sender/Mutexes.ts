import { runSingleFunctionToSenderContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runMutexes(connection: NetworkConnection) {
    console.log("\nTesting Mutexes Multi-flag Mod Reentrant Contracts");
    const contractNames = ["MutexesMod_ree1", "MutexesMod_ree2", "MutexesMod_ree3", "MutexesMod_ree4", "MutexesMod_ree5"];
    await runSingleFunctionToSenderContracts(connection, contractNames);

    console.log("\nTesting Mutexes Multi-flag NoMod Reentrant Contracts");
    const noModContractNames = ["Mutexes_ree1", "Mutexes_ree2", "Mutexes_ree3", "Mutexes_ree4", "Mutexes_ree5"];
    await runSingleFunctionToSenderContracts(connection, noModContractNames);

    console.log("\nTesting Mutexes Single-flag Mod Reentrant Contracts");
    const singleFlagModContractNames = ["MutexMod_ree1", "MutexMod_ree2", "MutexMod_ree3", "MutexMod_ree4", "MutexMod_ree5"];
    await runSingleFunctionToSenderContracts(connection, singleFlagModContractNames);

    console.log("\nTesting Mutexes Single-flag NoMod Reentrant Contracts");
    const singleFlagNoModContractNames = ["Mutex_ree1", "Mutex_ree2", "Mutex_ree3", "Mutex_ree4", "Mutex_ree5"];
    await runSingleFunctionToSenderContracts(connection, singleFlagNoModContractNames);
}