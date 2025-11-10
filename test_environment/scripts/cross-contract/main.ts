import { NetworkConnection } from "hardhat/types/network";
import { runCrossContractTemporalContracts } from "./AccessControlTemporal.js";
import { runCrossContractHumanContracts } from "./AccessControlHuman.js";
import { runCrossContractCreateContracts } from "./Create.js";
import { runCrossContractToTargetContracts } from "./ToTarget.js";
import { runCrossContractReadOnlyContracts } from "./ReadOnly.js";

export async function runCrossContractTests(connection: NetworkConnection) {
    await runCrossContractTemporalContracts(connection);
    await runCrossContractHumanContracts(connection);
    await runCrossContractCreateContracts(connection);
    await runCrossContractReadOnlyContracts(connection);
    await runCrossContractToTargetContracts(connection);
}