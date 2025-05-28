import glob
import json
import os
import re
from typing import Dict, Any, List, Tuple, Optional

from tqdm import tqdm

from src.classes.utils.DebugLogger import DebugLogger


class ContractFileProcessor:
    """
    A class for processing and grouping JSON files representing AST and CFG structures of smart contracts.
    """

    def __init__(self, ast_dir: str = None, cfg_dir: str = None):
        """
        Initialize the ContractFileProcessor.

        :param ast_dir: Directory containing AST JSON files.
        :param cfg_dir: Directory containing CFG JSON files.
        """
        self.logger = DebugLogger()
        self.ast_dir = ast_dir
        self.cfg_dir = cfg_dir
        self.grouped: Dict[str, Dict[str, Any]] = {}

    def extract_json(self, contract_id: str, label: str, directory: str, data_type: str) -> Optional[dict]:
        """
        Extracts JSON data (AST or CFG) for a given contract from a directory.

        :param contract_id: Contract identifier.
        :param label: Contract label.
        :param directory: Directory containing the JSON files.
        :param data_type: Type of data ("AST" or "CFG") for logging.
        :return: Parsed JSON data if available, else None.
        """
        if not directory:
            return None

        file_path = os.path.join(directory, label, f"{contract_id}.json")
        try:
            with open(file_path, "r") as f:
                return json.load(f)
        except FileNotFoundError:
            self.logger.warning(f"{data_type} file for contract {contract_id} not found.")
            return None
        except Exception as e:
            self.logger.error(f"Error loading {data_type} for {contract_id}: {e}")
            return None

    def extract_ast(self, contract_id: str, label: str) -> Optional[dict]:
        """Extract AST JSON for a contract."""
        return self.extract_json(contract_id, label, self.ast_dir, "AST")

    def extract_cfg(self, contract_id: str, label: str) -> Optional[dict]:
        """Extract CFG JSON for a contract."""
        return self.extract_json(contract_id, label, self.cfg_dir, "CFG")

    def process_files_in_dir(self, directory: str, key: str, progress_desc: str) -> None:
        """
        Process JSON files in a given directory and update the grouped dictionary.

        :param directory: The directory to search files in.
        :param key: The key to store the loaded JSON data ("ast" or "cfg").
        :param progress_desc: Description for the tqdm progress bar.
        """
        if not directory:
            return

        for file_path in tqdm(glob.glob(os.path.join(directory, "*", "*.json")), desc=progress_desc):
            contract_id = os.path.basename(file_path).split('.')[0].split('-')[0]
            label = os.path.basename(os.path.dirname(file_path)).lower()

            if contract_id not in self.grouped:
                self.grouped[contract_id] = {"source_files": [], "ast": None, "cfg": None, "label": label}
            elif self.grouped[contract_id]["label"] != label:
                self.logger.warning(f"Contract {contract_id} has conflicting labels: "
                                    f"{self.grouped[contract_id]['label']} and {label}")

            self.grouped[contract_id]["source_files"].append(file_path)
            try:
                with open(file_path, "r") as f:
                    self.grouped[contract_id][key] = json.load(f)
            except Exception as e:
                self.logger.error(f"Error loading {file_path}: {e}")

    def group_files(self, mode: str = "ast_cfg", required_representations: List[str] = None) -> List[
        Tuple[str, List[str], dict, str]]:
        """
        Group JSON files from AST and CFG directories by contract identifier.
        Skips contracts that do not have the required representations.

        :param mode: "ast_cfg", "ast", or "cfg" to control which data to include.\
        :param required_representations: List of required representations (e.g., ["ast", "cfg"]).
        :return: A list of tuples (contract_id, source file paths, combined JSON, label).
        """
        required_representations = required_representations or []

        if mode in ["ast_cfg", "ast"] and self.ast_dir:
            self.process_files_in_dir(self.ast_dir, "ast", "Grouping AST")

        if mode in ["ast_cfg", "cfg"] and self.cfg_dir:
            self.process_files_in_dir(self.cfg_dir, "cfg", "Grouping CFG")

        valid_contracts = []
        for contract_id, contents in self.grouped.items():
            if any(contents[rep] is None for rep in required_representations):
                self.logger.warning(
                    f"Skipping contract {contract_id} due to missing required representations: {required_representations}")
                continue  # Skip contracts missing required data

            valid_contracts.append(
                (contract_id, contents["source_files"], self.combine_data(contents, mode), contents["label"]))

        return valid_contracts

    @staticmethod
    def combine_data(contents: dict, mode: str) -> dict:
        """
        Combine AST and/or CFG data from a contract based on the mode.

        :param contents: Dictionary containing AST and CFG data.
        :param mode: The mode in which data should be combined ("ast_cfg", "ast", "cfg").
        :return: A dictionary containing the selected data.
        """
        if mode == "ast_cfg":
            return {k: contents[k] for k in ["ast", "cfg"] if contents[k] is not None}
        return {mode: contents.get(mode)} if contents.get(mode) else {}

    @staticmethod
    def load_source_code(contract_id, source_dir, label) -> str:
        """
        Loads and preprocesses Solidity source code for a given contract.

        :param contract_id: Contract ID.
        :param source_dir: Directory containing source code.
        :param label: Classification label.
        :return: Cleaned Solidity source code.
        """
        source_path = os.path.join(source_dir, label, f"{contract_id}.sol")

        try:
            with open(source_path, "r", encoding="latin-1") as file:
                raw_code = file.read()
        except FileNotFoundError:
            print(f"Warning: Source code for contract {contract_id} not found at {source_path}.")
            return ""
        except Exception as e:
            print(f"Error loading source code for contract {contract_id}: {e}")
            return ""

        return ContractFileProcessor._clean_solidity_code(raw_code)

    @staticmethod
    def _clean_solidity_code(code: str) -> str:
        """
        Removes all Solidity comments and docstrings.

        :param code: Raw Solidity source code.
        :return: Cleaned Solidity source code.
        """
        code = re.sub(r"/\*.*?\*/", "", code, flags=re.DOTALL)  # Remove block comments
        code = re.sub(r"//.*", "", code)  # Remove single-line comments
        code = re.sub(r"@\w+.*", "", code)  # Remove NatSpec comments
        return "\n".join(line.rstrip() for line in code.splitlines() if line.strip())
