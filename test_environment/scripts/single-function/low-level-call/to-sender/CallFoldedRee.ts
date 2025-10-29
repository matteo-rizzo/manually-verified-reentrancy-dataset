import { runSingleFunctionToSenderContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runFolded(connection: NetworkConnection) {
    console.log("\nTesting Folded Reentrancy Contracts");
    const contractNames = ["CallFoldedRee1", "CallFoldedRee2", "CallFoldedRee3"];
    await runSingleFunctionToSenderContracts(connection, contractNames);
}