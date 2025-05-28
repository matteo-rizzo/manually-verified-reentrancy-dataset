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
This initial phase involves creating a large pool of unique, compilable Solidity contracts from the three source studies (`cgt`, `hg`, `rs`). The provided scripts in the `scripts/` directory (at the project root) automate these preprocessing steps:

  * **Merge study data (`scripts/merge_studies.py`):** Combines contracts from the source study directories (assumed to be placed in `cgt/`, `hg/`, `rs/` locally within a staging area like `source_datasets/`). Files are renamed (`{contract_address}_{study_ID}.sol`).
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

  * **Aggregated Benchmark (436 contracts):** Located in `/final_benchmarks/aggregated_benchmark/`
  * **Taxonomy Reentrancy Scenarios (TRS - 150 contracts):** Located in `/final_benchmarks/trs/`

Each directory typically contains subfolders for `reentrant` and `safe` contracts. The scripts in the `/scripts` directory (at the project root) are available for users interested in reproducing the preprocessing steps for the initial, larger contract pool from the original sources. The scripts for running experiments on the final datasets are located within the `src/` directory.

-----

## Scripts Overview (Root Level Preprocessing)

The `scripts/` directory at the root of the project contains tools for initial dataset aggregation and filtering:

1.  **`merge_studies.py`**: Merges data from `cgt`, `hg`, `rs` folders. Renames contracts to `{contract_address}_{study_ID}.sol`.
2.  **`deduplicate.py`**: Identifies and removes duplicate Solidity contracts based on file hashes.
3.  **`filter_by_length.py`**: (Optional) Filters out contracts below a specified size threshold.
4.  **`filter_compilable_contracts.sh`**: Compiles contracts with `solc` and discards failures. Requires `solc` (ideally multiple versions via `solc-select`).
5.  **`prune.py`**: Removes known libraries or other non-custom code.
6.  **`source2ast.sh`**: (Utility) Generates Abstract Syntax Trees (ASTs) using `solc --ast`.
7.  **`source2cfg.py`**: (Utility) Generates Control Flow Graphs (CFGs) using Slither. Requires `slither-analyzer`.

*(Refer to the `src/` directory for scripts related to running ML, DL, and LLM experiments as detailed in the "Reproducing Experiments" section below).*

-----

## Reproducing Experiments

This section guides you through reproducing the experiments presented in our paper, including final dataset preparation for models, and running traditional Machine Learning (ML), Deep Learning (DL), and Large Language Model (LLM) evaluations.

### 1\. Prerequisites and Setup

1.  **Clone Repository:**

    ```bash
    git clone https://github.com/your-username/your-repo-name.git # Replace with actual URL
    cd your-repo-name
    ```

2.  **Environment & Dependencies:**

      * Python 3.10 or higher is recommended. Create and activate a virtual environment:
        ```bash
        python3 -m venv venv
        source venv/bin/activate
        ```
      * Install ML/DL dependencies:
        ```bash
        pip install -r src/ml_dl/requirements.txt
        ```
      * Install dependencies for LLM scripts (review imports in `src/llms/` scripts, e.g., for `openai`, `google-generativeai`).

3.  **LLM API Keys:**

      * The LLM experiments (`src/llms/`) require API keys for OpenAI and/or Google AI Studio.
      * Create a `.env` file, typically in the `src/llms/` directory (consult `src/llms/classes/EnvLoader.py` for expected path and variable names).
      * Add your API keys to the `.env` file, for example:
        ```env
        OPENAI_API_KEY="your_openai_api_key"
        GOOGLE_API_KEY="your_google_api_key"
        ```

### 2\. Dataset Preparation for Model Experiments

While the root-level `scripts/` prepare a large initial pool, for running the ML/DL/LLM experiments as described in the paper, you will primarily use the final, manually verified datasets located in `/final_benchmarks/`.

  * The script `src/ml_dl/scripts/create_dataset_manually_verified.py` is responsible for taking these final benchmark contracts and structuring them into the specific train/validation/test splits (e.g., using 3-fold cross-validation) required by the ML/DL models. Consult this script for its exact inputs and outputs.
  * LLM experiments will run on test splits derived from these final benchmarks.

### 3\. Running Model Evaluations

Experiment scripts are primarily located within `src/ml_dl/scripts/` and `src/llms/scripts/`. Configuration for ML/DL models can be found in `src/ml_dl/settings.py`, and for LLMs in `src/llms/prompts.py`.

**A. Traditional ML and DL Models:**

  * Navigate to `src/ml_dl/scripts/`.
  * The paper evaluates models such as:
      * **Traditional ML Classifiers:** Run via `ml_classifiers.py`.
      * **Feed Forward Neural Network (FFNN):** Run via `ffnn.py`.
      * **LSTM Network:** Run via `lstm.py`.
      * **CodeBERT:** Run via `codebert.py`.
  * A `run_all.sh` script within this directory orchestrate these experiments.
  * Scripts like `single_split_dl_classifiers.py` and `single_split_ml_classifiers.py` are used for specific test runs.
  * These scripts perform 3-fold cross-validation and output performance metrics.

**B. LLM-Based Classification and Explanation:**

  * Navigate to `src/llms/scripts/`.
  * The `explainability.sh` script orchestrates `explainability.py` for LLM classification and explanation generation.
    ```bash
    bash explainability.sh # May require arguments for model, dataset, etc.
    ```
  * This setup interacts with LLM APIs, processes contracts from the benchmark datasets (Aggregated Benchmark or TRS), performs zero-shot classification, and generates explanations.
  * Specify target LLMs as per paper methodology (e.g., via script arguments or configurations loaded by `src/llms/classes/LLMHandler.py`).
  * Results (JSON outputs, metrics) are saved to a designated output directory.
  * The `src/llms/explanations.zip` contains pre-generated explanations for analysis or use in the LLM-based evaluation of explanations.

**C. Static Analysis Tools Evaluation:**

  * The provided `src` tree does not contain scripts for executing the static analysis tools (e.g., Slither, Mythril).
  * Reproducing this part involves:
    1.  Setting up the [SmartBugs framework](https://github.com/smartbugs/smartbugs).
    2.  Running the selected static tools via SmartBugs on the **Aggregated Benchmark** and **Taxonomy Reentrancy Scenarios (TRS)**.
    3.  Parsing tool outputs to classify contracts according to the paper's methodology.

### 4\. Expected Outputs

  * **ML/DL Models:** Performance metrics (Accuracy, Precision, Recall, F1-score) for each model on both datasets, typically in CSV/text files or printed.
  * **LLMs:**
      * JSON files with classification labels and explanations per contract.
      * Aggregated classification performance metrics.
      * Explanation quality scores (Correctness, Informativeness, Pertinence) from human and LLM-based evaluations.
  * Refer to the paper for detailed results and output formats.

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