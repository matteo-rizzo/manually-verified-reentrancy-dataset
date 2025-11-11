import { runCrossContractCreateContract, runCrossContractCreateContract2, runCrossContractCreate2Contract } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossContractCreateContracts(connection: NetworkConnection) {
    await runCrossContractCreateContract(connection, "Create_ree1");
    await runCrossContractCreateContract2(connection, "Create_ree2");
    await runCrossContractCreate2Contract(connection, "Create2_ree1");
}