import hre from "hardhat";
import { runSingleFunctionTests } from "./single-function/main.js";
import { runCrossFunctionTests } from "./cross-function/main.js";
import { runCrossContractTests } from "./cross-contract/main.js";

async function main() {
    const connection = await hre.network.connect();
    console.log("Running tests...");
    console.log("\nSingle-function tests:");
    console.log("----------------------");
    console.log("⚠️ Single function tests disabled. Enable them manually if needed. ⚠️");
    // await runSingleFunctionTests(connection);

    console.log("\nCross-function tests:");
    console.log("---------------------");
    console.log("⚠️ Cross function tests disabled. Enable them manually if needed. ⚠️");
    // await runCrossFunctionTests(connection);

    console.log("\nCross-contract tests:");
    console.log("---------------------");
    await runCrossContractTests(connection);
}

main().catch(console.error);