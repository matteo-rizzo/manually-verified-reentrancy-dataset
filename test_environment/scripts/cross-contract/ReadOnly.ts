import { runCrossContractReadOnly3Contract, runCrossContractReadOnlyContract } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossContractReadOnlyContracts(connection: NetworkConnection) {
    await runCrossContractReadOnlyContract(connection, "ReadOnly_ree1");
    await runCrossContractReadOnlyContract(connection, "ReadOnly_ree2");
    await runCrossContractReadOnly3Contract(connection, "ReadOnly_ree3");
}