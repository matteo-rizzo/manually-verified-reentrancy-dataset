# Manually Verified Reentrancy Dataset

A repository of **manually verified** Solidity smart contracts, categorized as either **safe** or **reentrant**. This dataset was constructed by consolidating data from three studies:

- **cgt** ([Consolidated Ground Truth](https://github.com/gsalzer/cgt))
- **hg** ([HuangGai](https://github.com/xf97/HuangGai))
- **rs** ([Reentrancy Study](https://github.com/InPlusLab/ReentrancyStudy-Data))

The `cgt` and `hg` datasets contain **only reentrant** contracts, while `rs` is split between **safe** and **reentrant** contracts based on `reentrancy_information.csv`.

---

## Data Preparation Workflow

The following pipeline is used to generate the final dataset:

1. **Merge study data**: Run `merge_studies.py` to combine contracts from the `cgt`, `hg`, and `rs` directories into a single folder. Files are renamed to the format `{contract address}_{study ID}.sol`.

2. **Deduplicate contracts**: Run `deduplicate.py` to remove duplicate contracts across studies.

3. **Filter compilable contracts**: Run `filter_compilable_contracts.sh` to keep only those contracts that compile successfully.

4. **Remove non-custom code**: Run `prune.py` to remove library contracts and other unwanted code.

### About the `hg` Dataset

The `hg` dump initially contained both `.sol` files and corresponding `.txt` files that pointed out the line numbers where reentrancy issues were detected. This repository omits the `.txt` files to keep the dataset purely focused on contract code. You can use the script `hg/dumpt2contracts.py` for filtering out non relevant files.

### About the `rs` Dataset

Contracts from the `rs` study dump are split into `reentrant` vs `safe` using `reentrancy_information.csv`. You can use the script `rs/dumpt2contracts.py` for that.

---

## Scripts

Below is a brief overview of the scripts included in `scripts/`:

1. **`merge_studies.py`**  
   Merges the data from the `cgt`, `hg`, and `rs` folders into a single directory. Contracts are renamed according to the convention `{contract address}_{study ID}.sol`.

2. **`deduplicate.py`**  
   Identifies and removes duplicate Solidity contracts. Duplicate detection relies on file hashes.

3. **`filter_by_length.py`**  
   (Optional) Filters out contracts below a certain size threshold (e.g., very short or empty files).

4. **`filter_compilable_contracts.sh`**  
   Compiles the contracts (using `solc`) and discards any that fail to compile.

5. **`prune.py`**  
   Removes known libraries or other non-custom code that is not relevant for reentrancy analysis.

6. **`source2ast.sh`**  
   Generates an Abstract Syntax Tree (AST) for each contract using `solc --ast`.

7. **`source2cfg.py`**  
   Generates a control flow graph (CFG) for each contract using Slyther.

---

## Usage

1. **Clone this repository**:
   ```bash
   git clone https://github.com/your-username/manually-verified-reentrancy-dataset.git
   cd manually-verified-reentrancy-dataset
   ```
2. **Install dependencies**:
   - Python 3.x
   - Bash shell with `solc` installed
   - Other Python packages if needed (see imports in `*.py` files).

3. **Run scripts in order**:
   ```bash
   # Merge data
   python scripts/merge_studies.py

   # Deduplicate
   python scripts/filter_duplicates.py

   # Filter compilable
   bash scripts/filter_compilable_contracts.sh

   # Prune libraries
   python scripts/prune.py
   ```
   Adjust or skip steps as needed for your specific use case.

---

## Contributing

1. Fork this repository.
2. Create a new branch for your changes: `git checkout -b feature/your-feature`.
3. Commit your changes: `git commit -m 'Add some feature'`.
4. Push to your branch: `git push origin feature/your-feature`.
5. Create a new Pull Request on GitHub.

---

## License

The dataset and scripts in this repository are distributed for research and educational purposes. Please review the [LICENSE](LICENSE) file for more information.

---

## Disclaimer

This repository aims to provide a **manually verified** dataset to assist with reentrancy analysis and research on Solidity smart contracts. However, any **usage of the dataset is entirely at your own risk**. Smart contracts are inherently risky, and security issues may remain undetected. Always conduct your own independent audits before deploying or interacting with any contract.