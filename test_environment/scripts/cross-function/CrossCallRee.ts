import { runCrossFunctionContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossCallRee(connection: NetworkConnection) {
    const contractNames = ["CrossCallRee"];
    await runCrossFunctionContracts(connection, contractNames);
}