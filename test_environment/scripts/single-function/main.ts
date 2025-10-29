import { NetworkConnection } from "hardhat/types/network";
import { runLowLevelSingleFunctionTests } from "./low-level-call/main.js";
import { runMethodInvocationTests } from "./method-invocation/main.js";

export async function runSingleFunctionTests(connection: NetworkConnection) {
    await runLowLevelSingleFunctionTests(connection).catch(console.error);
    await runMethodInvocationTests(connection).catch(console.error);
}