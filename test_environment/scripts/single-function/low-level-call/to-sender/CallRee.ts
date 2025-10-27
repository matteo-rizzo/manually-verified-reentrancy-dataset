import { runSingleFunctionToSenderContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runRee(connection: NetworkConnection) {
    const contractNames = ["CallRee"];
    await runSingleFunctionToSenderContracts(connection, contractNames);
}