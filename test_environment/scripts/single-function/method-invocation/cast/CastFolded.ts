import { runMethodInvocationContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCastFoldedRee(connection: NetworkConnection) {
    console.log("\nTesting CastFoldedRee Contracts");
    const contractNames = ["CastFolded_ree1", "CastFolded_ree2", "CastFolded_ree3"];
    await runMethodInvocationContracts(connection, contractNames);
}