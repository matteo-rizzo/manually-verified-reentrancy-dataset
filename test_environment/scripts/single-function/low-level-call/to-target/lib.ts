import { lowLevelToTargetModuleBuilder, moduleBuilder } from "../../../../ignition/helpers/single-function/low-level-call.js";
import { lowLevelToTargetConstructorModuleBuilder } from "../../../../ignition/modules/LowLevelToTargetContructor.js";
import { NetworkConnection } from "hardhat/types/network";
import { printBalance, runContractWithBuilder } from "../../../lib.js";

export async function runSingleFunctionToTargetContracts(connection: NetworkConnection, contractNames: string[], attackerContract?: string) {
    for (const name of contractNames) {
        if (attackerContract) {
            const builderWithAttacker = (victimContract: string, _attacker?: string) => moduleBuilder(victimContract, attackerContract);
            await runContractWithBuilder(connection, name, builderWithAttacker, attackerContract);
        } else {
            await runContractWithBuilder(connection, name, lowLevelToTargetModuleBuilder);
        }
    }
}

export async function deployLowLevelToTargetContractConstructor(connection: NetworkConnection, name: string) {
    await runContractWithBuilder(connection, name, lowLevelToTargetConstructorModuleBuilder);
}

