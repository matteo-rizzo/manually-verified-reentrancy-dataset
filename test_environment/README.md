## Test environment (Hardhat v3)

This folder is a Hardhat v3 project used to automatically test the reentrant contracts contained in the dataset.

Requirements

- This project requires Node.js and npm to install dependencies and run the scripts. Use a recent Node.js LTS (Node 24 or later) and the matching npm version. You can check your installed versions with `node -v` and `npm -v`.

Summary

- The contracts used here were copied from the dataset's `dataset/handcrafted/0_8` folder into this project's `contracts/` folder.
- When cloning the dataset contracts they were:
  - Renamed so every contract has a unique, identifiable name.
  - Adapted to be compliant with the local interfaces in `contracts/interfaces` where required.
  - Supplemented with attacker contracts placed under `contracts/attackers` (see `contracts/attackers/`).
- Test and helper scripts are located in the `scripts/` folder. The scripts mirror the major categories of the `dataset/handcrafted/0_8` folder structure so they can run the same checks across `single-function`, `cross-function`, and `cross-contract` groups. The main orchestrator script is `scripts/main.ts` which runs the whole suite.

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
