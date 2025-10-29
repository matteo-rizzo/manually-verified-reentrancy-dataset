import { runSingleFunctionToTargetContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runConstant(connection: NetworkConnection) {
    console.log("!!⚠️ SKIPPING CONSTANT TEST BECAUSE IT CANNOT BE IMPLEMENTED !!⚠️");
    // const contractNames = ["ConstantRee"];
    // await runSingleFunctionToTargetContracts(connection, contractNames);
}