import { runSingleFunctionToTargetContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runParameterRee(connection: NetworkConnection) {
    const contractNames = ["ParameterRee1"];
    await runSingleFunctionToTargetContracts(connection, contractNames, "LowLevelCallToTargetAttacker2");

}