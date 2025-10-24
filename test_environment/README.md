## Test environment (Hardhat v3)

This folder is a Hardhat v3 project used to automatically test the reentrant contracts contained in the dataset.

Requirements

- This project requires Node.js and npm to install dependencies and run the scripts. Use a recent Node.js LTS (Node 24 or later) and the matching npm version. You can check your installed versions with `node -v` and `npm -v`.

Summary

This Hardhat project contains a curated subset of the dataset's Solidity contracts (sourced from `dataset/handcrafted/0_8`) placed under `contracts/` and prepared for automated testing:

- Only reentrant contracts were kept; safe contracts were removed so the test suite focuses on reentrancy only.
- Contracts were renamed to produce unique dentifiers so the framework can properly distinguish each of them.
- Sources were adapted where necessary to implement the local interfaces in `contracts/interfaces`.
- Attacker contracts used to reproduce reentrancy attack scenarios were added under `contracts/attackers`.

Test and helper scripts live in `scripts/` and mirror the dataset layout (single-function, cross-function, cross-contract). The main orchestrator is `scripts/main.ts`, which runs the full suite.

Purpose

- This project exists purely to compile, deploy and automatically run tests against the reentrancy examples (both vulnerable and safe variants) so results can be collected and validated programmatically.

How the tests are structured

- Each subfolder in `scripts/` follows the dataset layout. For each contract under `contracts/` there is a corresponding script that deploys the contract(s), deploys the attacker, and executes the scenario.
- Artifacts and build output are placed under the `artifacts/` and `cache/` folders as usual for Hardhat projects.

Quick start

1. Install dependencies (from this folder):

```bash
npm install
```

2. Run the test orchestrator (this will execute `scripts/main.ts` using Hardhat):

```bash
npx hardhat run scripts/main.ts
```

Notes

- By default `npx hardhat run` uses the built-in Hardhat network. If you need to run on a specific network, append `--network <name>` to the command.
- The project is intentionally minimal and exists only to automate the dataset tests. Do not treat it as a full development scaffold — its scripts and contracts are tuned for automated verification of reentrancy behaviors.

Troubleshooting

- Ensure you have a recent Node.js and npm installed. If you see dependency resolution errors, try clearing `node_modules` and `package-lock.json` and re-running `npm install`.

Where to look next

- Contracts: `contracts/`
- Attacker contracts: `contracts/attackers/`
- Scripts: `scripts/` (entrypoint: `scripts/main.ts`)
- Build artifacts: `artifacts/` and `cache/`

If you want me to add examples of running only a single script or to add a short note about Node/Hardhat versions, tell me which versions you prefer and I will append them.
