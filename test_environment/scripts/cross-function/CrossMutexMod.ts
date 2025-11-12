import { runCrossFunctionContracts, runCrossFunctionMutexOrderContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossCallMutexModRee(connection: NetworkConnection) {
    const contractNames = ["CrossMutexMod_ree1", "CrossMutexMod_ree3"];
    await runCrossFunctionContracts(connection, contractNames);

    await runCrossFunctionMutexOrderContracts(connection, "CrossMutexModOrder_ree1");

}