import { runCrossContractToTargetContract } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossContractToTargetContracts(connection: NetworkConnection) {
    await runCrossContractToTargetContract(connection, "ToTargetRee1");
}