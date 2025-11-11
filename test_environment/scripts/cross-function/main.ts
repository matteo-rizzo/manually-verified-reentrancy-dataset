import { NetworkConnection } from "hardhat/types/network";
import { runCrossCallRee } from "./CrossCallRee.js";
import { runCrossCallMutexModRee } from "./CrossMutexMod.js";
import { runCrossCallMutexNoModRee } from "./CrossMutexNoMod.js";
import { runDoubleInit } from "./DoubleInit.js";

export async function runCrossFunctionTests(connection: NetworkConnection) {
    await runCrossCallRee(connection);
    await runCrossCallMutexModRee(connection);
    await runCrossCallMutexNoModRee(connection);
    await runDoubleInit(connection);
}