import { runTrustSwapContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runTrustSwap(connection: NetworkConnection) {
    const contractNames = ["CrossDoubleInitMutexRee1", "CrossDoubleInitOpenZeppelinRee1"];
    await runTrustSwapContracts(connection, contractNames);
}