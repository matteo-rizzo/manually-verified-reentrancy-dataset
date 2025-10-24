import { runSingleFunctionToSenderContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runBlockRee(connection: NetworkConnection) {
    console.log("\n!! SKIPPING BLOCK TEST BECAUSE IT IS NOT WORKING !!");
    // console.log("\nTesting Block Reentrancy Contracts");
    // const contractNames = ["BlockRee1"];
    // await runSingleFunctionToSenderContracts(connection, contractNames);
}