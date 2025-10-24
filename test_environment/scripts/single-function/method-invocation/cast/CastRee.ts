import { runMethodInvocationContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCastRee(connection: NetworkConnection) {
    console.log("\nTesting CastRee Contracts");
    const contractNames = ["CastRee"];
    await runMethodInvocationContracts(connection, contractNames);
}