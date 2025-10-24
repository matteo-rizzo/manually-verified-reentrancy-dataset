import { runMethodInvocationContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCastFoldedRee(connection: NetworkConnection) {
    console.log("\nTesting CastFoldedRee Contracts");
    const contractNames = ["CastFoldedRee1", "CastFoldedRee2", "CastFoldedRee3"];
    await runMethodInvocationContracts(connection, contractNames);
}