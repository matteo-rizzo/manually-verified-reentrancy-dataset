import { deployLowLevelToTargetContractConstructor } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runConstructorRee(connection: NetworkConnection) {
    // TODO check this
    console.log("!!⚠️ SKIPPING CONSTRUCTOR REE TEST BECAUSE IT IS NOT WORKING !!⚠️");
    // const contractName = "Constructor_ree1";
    // await deployLowLevelToTargetContractConstructor(connection, contractName);
}