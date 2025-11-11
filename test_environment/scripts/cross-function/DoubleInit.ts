import { runDoubleInitContracts } from "./lib.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runDoubleInit(connection: NetworkConnection) {
    const contractNames = ["CrossDoubleInit_ree1", "CrossDoubleInitOpenZeppelin_ree1"];
    await runDoubleInitContracts(connection, contractNames);
}