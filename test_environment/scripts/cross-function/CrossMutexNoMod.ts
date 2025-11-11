import { runCrossFunctionContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossCallMutexNoModRee(connection: NetworkConnection) {
    const contractNames = ["CrossMutex_ree1", "CrossMutex_ree3"];
    await runCrossFunctionContracts(connection, contractNames);
}