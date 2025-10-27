import { NetworkConnection } from "hardhat/types/network";
import { runSingleFunctionToSenderTests } from "./to-sender/main.js";
import { runSingleFunctionToTargetTests } from "./to-target/main.js";

export async function runLowLevelSingleFunctionTests(connection: NetworkConnection) {
    await runSingleFunctionToSenderTests(connection).catch(console.error);
    await runSingleFunctionToTargetTests(connection).catch(console.error);
}