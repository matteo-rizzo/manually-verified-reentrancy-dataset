import hre from "hardhat";
import { runSingleFunctionTests } from "./single-function/main.js";
import { runCrossFunctionTests } from "./cross-function/main.js";

async function main() {
    const connection = await hre.network.connect();
    console.log("Running tests...");
    console.log("\nSingle-function tests:");
    console.log("----------------------");
    console.log("⚠️ Single tests disabled. Enable them manually if needed. ⚠️");
    // await runSingleFunctionTests(connection);

    console.log("\nCross-function tests:");
    console.log("---------------------");
    await runCrossFunctionTests(connection);
}

main().catch(console.error);