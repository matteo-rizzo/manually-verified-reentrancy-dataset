import { runCrossContractCreateContract, runCrossContractCreateContract2, runCrossContractCreate2Contract } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossContractCreateContracts(connection: NetworkConnection) {
    await runCrossContractCreateContract(connection, "CreateRee1");
    await runCrossContractCreateContract2(connection, "CreateRee2");
    await runCrossContractCreate2Contract(connection, "Create2Ree");
}