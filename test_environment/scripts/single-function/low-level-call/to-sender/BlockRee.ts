import { runSingleFunctionToSenderBlockReeContract } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runBlockRee(connection: NetworkConnection) {
    console.log("\nTesting Block Reentrancy Contracts");
    const contractName = "BlockRee1";
    await runSingleFunctionToSenderBlockReeContract(connection, contractName);
}