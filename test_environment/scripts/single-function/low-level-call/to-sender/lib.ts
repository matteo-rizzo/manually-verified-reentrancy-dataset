import { NetworkConnection } from "hardhat/types/network";
import { printBalance, runContractWithBuilder } from "../../../lib.js";
import { lowLevelToSenderModuleBuilder, twoStepsAttackerModuleBuilder } from "../../../../ignition/modules/single-function/low-level-call.js";

export async function runSingleFunctionToSenderContracts(connection: NetworkConnection, contractNames: string[]) {
    for (const name of contractNames) {
        await runContractWithBuilder(connection, name, lowLevelToSenderModuleBuilder);
    }
}
export async function runSingleFunctionToSenderBlockReeContract(connection: NetworkConnection, contractName: string) {
    await runContractWithBuilder(connection, contractName, twoStepsAttackerModuleBuilder);

}
