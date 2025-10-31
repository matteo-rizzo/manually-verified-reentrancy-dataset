import { runCrossContractAccessControlToggle1Contract, runCrossContractAccessControlToggle2Contract } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runCrossContractToggleContracts(connection: NetworkConnection) {
    await runCrossContractAccessControlToggle1Contract(connection, "ToggleRee1");
    await runCrossContractAccessControlToggle2Contract(connection, "ToggleRee2");
}