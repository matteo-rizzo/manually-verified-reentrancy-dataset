import { runCrossContractAccessControlHuman1Contract } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossContractHumanContracts(connection: NetworkConnection) {
    await runCrossContractAccessControlHuman1Contract(connection, "Human_ree1");
}
