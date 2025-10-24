import { lowLevelToTargetModuleBuilder } from "../../../ignition/helpers/low-level-call.js";
import { runSingleFunctionToTargetContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runParameterRee(connection: NetworkConnection) {
    console.log("\nTesting Reentrancy Contracts");
    const contractNames = ["ParameterRee1"];
    await runSingleFunctionToTargetContracts(connection, contractNames, "LowLevelCallToTargetAttacker2");

}