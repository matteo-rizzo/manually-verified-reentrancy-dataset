# Manually Verified Reentrancy Datasets for Smart Contracts

This repository provides two meticulously curated and **manually verified** benchmark datasets for reentrancy vulnerability research in Solidity smart contracts. Our goal is to offer high-quality resources that address the limitations of noisy, automatically-labeled datasets commonly used in prior work. All contracts in the final benchmarks are labeled according to a **clearly defined reentrancy taxonomy** detailed in our accompanying paper.

The two primary datasets contributed are:

1.  **Aggregated Benchmark (High-Confidence Set):** A collection of **436 unique contracts (122 reentrant, 314 safe)**. This benchmark was derived from the aggregation of three public academic sources, followed by a rigorous manual verification and relabeling process based on our taxonomy:
      * [Consolidated Ground Truth (CGT)](https://github.com/gsalzer/cgt) (`cgt`)
      * [HuangGai (HG)](https://github.com/xf97/HuangGai) (`hg`)
      * [Reentrancy Study (RS)](https://github.com/InPlusLab/ReentrancyStudy-Data) (`rs`)
2.  **Taxonomy Reentrancy Scenarios (TRS):** A novel, handcrafted set of **150 unique contracts**. This dataset is specifically constructed to represent a defined **taxonomy of reentrancy scenarios**, including those that are subtle, involve modern Solidity features, or exhibit complex control flows, making them challenging for existing detectors. Each contract in the TRS has also been manually verified and labeled according to our taxonomy.

This repository includes the original source data (where permissible by original licenses), scripts for preprocessing the initial aggregated pool, and, most importantly, the final benchmark datasets themselves.

-----

## Dataset Construction Overview

The final benchmark datasets are the result of a multi-stage process detailed in our paper:

**1. Initial Pool Aggregation & Preprocessing (Scripts Provided):**
This initial phase involves creating a large pool of unique, compilable Solidity contracts from the three source studies (`cgt`, `hg`, `rs`). The provided scripts in the `scripts/` directory automate these preprocessing steps:

  * **Merge study data (`scripts/merge_studies.py`):** Combines contracts from the source study directories (assumed to be placed in `cgt/`, `hg/`, `rs/` locally). Files are renamed (`{contract_address}_{study_ID}.sol`).
  * **Deduplicate contracts (`scripts/deduplicate.py`):** Removes exact duplicates based on file hashes.
  * **Filter compilable contracts (`scripts/filter_compilable_contracts.sh`):** Retains only contracts that compile successfully using standard `solc` compilers (versions 0.4.\* to 0.8.\*, matching contract pragmas).
  * **Remove non-custom/library code (`scripts/prune.py`):** Filters out common OpenZeppelin libraries or other non-custom code not central to the contract's unique logic.

**Notes on Original Source Preprocessing:**

  * **`hg` Dataset:** The original `hg` dump included `.txt` files with line numbers for detected issues. These are omitted here to focus on source code. The `hg/dumpt2contracts.py` script was used for initial filtering of relevant files from the original `hg` source.
  * **`rs` Dataset:** Contracts from the original `rs` study were initially categorized using its `reentrancy_information.csv`. The `rs/dumpt2contracts.py` script was used for this initial split.

**2. Manual Verification & Final Benchmark Creation (Core Contribution):**

Following the initial preprocessing, a rigorous manual verification phase was undertaken based on our defined reentrancy taxonomy:

  * **Aggregated Benchmark (High-Confidence Set):**

      * From the preprocessed pool (containing 145 potentially reentrant and 73,434 potentially safe contracts based on original labels), all 145 "potentially reentrant" contracts were manually inspected and relabeled.
      * From the "potentially safe" pool, a diverse sample of 291 contracts (those confidently marked safe by prior human analysis and multiple tools) was manually inspected and relabeled.
      * This meticulous process yielded the final **Aggregated Benchmark of 436 high-confidence contracts (122 reentrant, 314 safe)**. This set is recommended as the gold standard for evaluating general reentrancy detection.

  * **Taxonomy Reentrancy Scenarios (TRS):**

      * This is a separate, novel collection of **150 handcrafted or carefully selected contracts.**
      * It is constructed to cover a **defined taxonomy of reentrancy scenarios**, focusing on patterns that are subtle, involve modern Solidity features, or exhibit complex control flows, thus challenging existing detectors.
      * All 150 TRS contracts were **manually created and/or verified** according to our taxonomy, with their labels (reentrant/safe within the context of the specific scenario) confirmed.

-----

## Accessing the Final Datasets

The final, manually verified benchmark datasets are the primary contributions intended for direct use in research:

  * **Aggregated Benchmark (436 contracts):** Located in `/dataset/aggregated_benchmark/`
  * **Taxonomy Reentrancy Scenarios (TRS - 150 contracts):** Located in `/dataset/trs/`

Each directory typically contains subfolders for `reentrant` and `safe` contracts. The scripts in the `/scripts` directory are available for users interested in reproducing the preprocessing steps for the initial, larger contract pool from the original sources.

-----

## Scripts Overview

The `scripts/` directory contains:

1.  **`merge_studies.py`**: Merges data from `cgt`, `hg`, `rs` folders. Renames contracts to `{contract_address}_{study_ID}.sol`.
2.  **`deduplicate.py`**: Identifies and removes duplicate Solidity contracts based on file hashes.
3.  **`filter_by_length.py`**: (Optional) Filters out contracts below a specified size threshold.
4.  **`filter_compilable_contracts.sh`**: Compiles contracts with `solc` and discards failures. Requires `solc` to be installed and ideally multiple versions accessible (e.g., via `solc-select`) to handle different `pragma` directives.
5.  **`prune.py`**: Removes known libraries or other non-custom code.
6.  **`source2ast.sh`**: (Utility) Generates Abstract Syntax Trees (ASTs) using `solc --ast`.
7.  **`source2cfg.py`**: (Utility) Generates Control Flow Graphs (CFGs) using Slither. Requires `slither-analyzer`.

-----

## Usage Guide

1.  **Clone this repository**:

    ```bash
    git clone https://github.com/your-username/manually-verified-reentrancy-dataset.git
    cd manually-verified-reentrancy-dataset
    ```

2.  **Access Final Datasets**: For most research purposes, navigate to the `/dataset/` directory and use the `aggregated_benchmark` and `trs` datasets directly.

3.  **Reproduce Preprocessing (Optional)**:

      * Place the original, unaltered `cgt`, `hg`, and `rs` datasets into their respective subdirectories (e.g., `source_datasets/cgt/`, `source_datasets/hg/`, `source_datasets/rs/`) at the root of this repository or adjust paths in scripts.
      * Ensure Python 3.x and a Bash shell with `solc` (preferably managed by `solc-select` for version flexibility) are installed.
      * Install any Python packages listed in the import statements of the `*.py` scripts (e.g., `pip install slither-analyzer`).
      * Execute the preprocessing scripts in order from the `scripts/` directory:
        ```bash
        python merge_studies.py # Ensure script points to correct source_datasets paths
        python deduplicate.py
        bash filter_compilable_contracts.sh
        python prune.py
        ```
      * Adjust paths within scripts if your source data layout differs.

-----

## Contributing

1.  Fork this repository.
2.  Create a new branch: `git checkout -b feature/your-feature`.
3.  Commit your changes: `git commit -m 'Add some feature'`.
4.  Push to your branch: `git push origin feature/your-feature`.
5.  Create a new Pull Request.

-----

## License

The dataset and scripts in this repository are distributed for research and educational purposes. Please review the LICENSE file for more information.

-----

## Disclaimer

This repository aims to provide **manually verified** datasets to assist with reentrancy analysis and research on Solidity smart contracts. However, any **usage of the dataset is entirely at your own risk**. Smart contracts are inherently risky, and security issues may remain undetected. Always conduct your own independent audits before deploying or interacting with any contract.