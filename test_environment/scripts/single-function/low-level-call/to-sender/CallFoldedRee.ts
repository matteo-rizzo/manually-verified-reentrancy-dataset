import { runSingleFunctionToSenderContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runFolded(connection: NetworkConnection) {
    console.log("\nTesting Folded Reentrancy Contracts");
    const contractNames = ["CallFolded_ree1", "CallFolded_ree2", "CallFolded_ree3"];
    await runSingleFunctionToSenderContracts(connection, contractNames);
}