import { runCrossFunctionContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossCallMutexNoModRee(connection: NetworkConnection) {
    const contractNames = ["CrossMutexRee1", "CrossMutexRee3"];
    await runCrossFunctionContracts(connection, contractNames);
}