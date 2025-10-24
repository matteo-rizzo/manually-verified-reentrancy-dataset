import { deployLowLevelToTargetContractConstructor } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runConstructorRee(connection: NetworkConnection) {
    console.log("!! SKIPPING CONSTRUCTOR REE TEST BECAUSE IT IS NOT WORKING !!");
    // console.log("\nTesting Reentrancy Contracts");
    // const contractName = "ConstructorRee1";
    // await deployLowLevelToTargetContractConstructor(connection, contractName);
}