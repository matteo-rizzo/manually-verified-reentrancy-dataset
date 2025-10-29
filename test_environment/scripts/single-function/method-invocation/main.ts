import { NetworkConnection } from "hardhat/types/network";
import { runCastRee } from "./cast/CastRee.js";
import { runCastFoldedRee } from "./cast/CastFolded.js";

export async function runMethodInvocationTests(connection: NetworkConnection) {
    await runCastRee(connection).catch(console.error);
    await runCastFoldedRee(connection).catch(console.error);
}