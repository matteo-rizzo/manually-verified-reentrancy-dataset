import { runMethodInvocationContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCastRee(connection: NetworkConnection) {
    console.log("\nTesting CastRee Contracts");
    const contractNames = ["Cast_ree1"];
    await runMethodInvocationContracts(connection, contractNames);
}