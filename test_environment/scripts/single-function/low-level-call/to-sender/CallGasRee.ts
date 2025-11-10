import { runSingleFunctionToSenderContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runGasRee(connection: NetworkConnection) {
    console.log("\nTesting Gas Reentrancy Contracts");
    const contractNames = ["CallGas_ree1"];
    await runSingleFunctionToSenderContracts(connection, contractNames);
}