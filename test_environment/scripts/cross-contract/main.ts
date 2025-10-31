import { NetworkConnection } from "hardhat/types/network";
import { runCrossContractToggleContracts } from "./AccessControlToggle.js";
import { runCrossContractCreateContracts } from "./Create.js";

export async function runCrossContractTests(connection: NetworkConnection) {
    await runCrossContractToggleContracts(connection);
    await runCrossContractCreateContracts(connection);
}