import hre from "hardhat";
import { runSingleFunctionTests } from "./single-function/low-level-call/main.js";
import { runMethodInvocationTests } from "./single-function/method-invocation/main.js";

async function main() {
    const connection = await hre.network.connect();

    await runSingleFunctionTests(connection).catch(console.error);
    await runMethodInvocationTests(connection).catch(console.error);
}

main().catch(console.error);