import { runCrossFunctionContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossCallMutexModRee(connection: NetworkConnection) {
    const contractNames = ["CrossMutexModRee1", "CrossMutexModRee3"];
    await runCrossFunctionContracts(connection, contractNames);
}