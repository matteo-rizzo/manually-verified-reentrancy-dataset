import { runRee } from "./CallRee.js";
import { runFolded } from "./CallFoldedRee.js";
import { runGasRee } from "./CallGasRee.js";
import { runBlockRee } from "./BlockRee.js";
import { runMutexes } from "./Mutexes.js";
import { NetworkConnection } from "hardhat/types/network";

export async function runSingleFunctionToSenderTests(connection: NetworkConnection) {
    await runRee(connection).catch(console.error);
    await runFolded(connection).catch(console.error);
    await runGasRee(connection).catch(console.error);
    await runBlockRee(connection).catch(console.error);
    await runMutexes(connection).catch(console.error);
}