import { runSingleFunctionToSenderContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runRee(connection: NetworkConnection) {
    const contractNames = ["Call_ree1"];
    await runSingleFunctionToSenderContracts(connection, contractNames);
}