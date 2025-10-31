import { runCrossContractCreateContract } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossContractCreateContracts(connection: NetworkConnection) {
    await runCrossContractCreateContract(connection, "CreateRee1");
}