import { NetworkConnection } from "hardhat/types/network";
import { runCrossContractToggleContracts } from "./AccessControlToggle.js";
import { runCrossContractHumanContracts } from "./AccessControlHuman.js";
import { runCrossContractCreateContracts } from "./Create.js";

export async function runCrossContractTests(connection: NetworkConnection) {
    await runCrossContractToggleContracts(connection);
    await runCrossContractHumanContracts(connection);
    await runCrossContractCreateContracts(connection);
}