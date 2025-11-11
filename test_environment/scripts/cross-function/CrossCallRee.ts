import { runCrossFunctionContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossCallRee(connection: NetworkConnection) {
    const contractNames = ["CrossCall_ree1"];
    await runCrossFunctionContracts(connection, contractNames);
}