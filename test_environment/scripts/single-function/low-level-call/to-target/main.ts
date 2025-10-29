import { NetworkConnection } from "hardhat/types/network";
import { runConstant } from "./ConstantRee.js";
import { runConstructorRee } from "./ConstructorRee.js";
import { runParameterRee } from "./ParameterRee.js";


export async function runSingleFunctionToTargetTests(connection: NetworkConnection) {
    await runConstant(connection).catch(console.error);
    await runConstructorRee(connection).catch(console.error);
    await runParameterRee(connection).catch(console.error);
}