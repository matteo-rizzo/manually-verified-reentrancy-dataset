import { runCrossContractTemporalVault1Contract, runCrossContractTemporalVault2Contract, runCrossContractTemporalLocker1Contract } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossContractTemporalContracts(connection: NetworkConnection) {
    await runCrossContractTemporalVault1Contract(connection, "TemporalVault_ree1");
    await runCrossContractTemporalVault2Contract(connection, "TemporalVault_ree2");
    await runCrossContractTemporalLocker1Contract(connection, "TemporalLocker_ree1");
}