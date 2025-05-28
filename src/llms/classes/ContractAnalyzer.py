import json
import multiprocessing
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Tuple, Any

from src.classes.utils.DebugLogger import DebugLogger
from src.classes.xrag.ContractFileProcessor import ContractFileProcessor
from src.classes.xrag.Document import Document
from src.classes.xrag.KnowledgeBase import KnowledgeBase
from src.functions.xrag import process_input_contract_worker


class ContractAnalyzer:
    def __init__(
            self,
            dataset_base: str,
            mode: str = "ast_cfg",
            model: str = "default",
            use_multiprocessing: bool = False
    ) -> None:
        """
        Initializes the ContractAnalyzer class.

        :param dataset_base: Base path for the dataset, expects a format placeholder.
        :param mode: The mode of analysis (e.g., 'ast_cfg', 'ast', 'cfg').
        :param model: The LLM model name.
        :param use_multiprocessing: If True, enables multiprocessing; otherwise, runs sequentially.
        """
        self.mode = mode
        self.dataset_base = dataset_base
        self.use_multiprocessing = use_multiprocessing
        self.logger = DebugLogger()
        self.logger.info(f"Initializing ContractAnalyzer with mode: {self.mode}")

        # Initialize knowledge base and LLM processor
        self.kb = KnowledgeBase("knowledge_base.db")
        self.kb.clear_contracts()

        # Load directories and check existence
        self.candidate_dirs = self._get_directories("train")
        self.input_dirs = self._get_directories("test")

        for key, path in {**self.candidate_dirs, **self.input_dirs}.items():
            if not os.path.exists(path):
                self.logger.warning(f"Warning: Expected directory {key} does not exist at {path}.")

        self.logger.info(f"Candidate directories: {self.candidate_dirs}")
        self.logger.info(f"Input directories: {self.input_dirs}")

        # Prepare candidate documents and retriever
        self.candidate_documents = self._prepare_documents("candidate")
        self.logger.info(f"Candidate documents prepared. Total: {len(self.candidate_documents)}")

        # Create log directory
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.log_dir = Path(f"logs/xrag/{model}/{self.mode}_{timestamp}")
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.logger.info(f"Log directory created at {self.log_dir}")

    def store_contracts(self, contracts: List[Tuple[str, List[str], Dict, str]]) -> None:
        """Stores contract information in the knowledge base."""
        for contract_id, source_files, combined_json, label in contracts:
            self.kb.store_combined_contract(contract_id, source_files, combined_json, label)

    def load_contracts(self) -> List[Document]:
        """Loads all stored contracts from the knowledge base."""
        return self.kb.load_all_contracts()

    def _get_directories(self, dataset_type: str) -> Dict[str, str]:
        """Returns the directory paths for a given dataset type."""
        try:
            base_path = self.dataset_base.format(dataset_type)
        except (KeyError, IndexError):
            self.logger.error(f"Invalid dataset_base format: {self.dataset_base}")
            raise ValueError("dataset_base must contain a placeholder for dataset_type (e.g., 'path/{}')")

        return {
            "src": os.path.join(base_path, "source"),
            "ast": os.path.join(base_path, "ast"),
            "cfg": os.path.join(base_path, "cfg"),
        }

    def analyze_contracts(self):
        """Analyzes input contracts using multiprocessing (if enabled) or sequential processing."""
        input_documents = self._prepare_documents("input")
        self.logger.info(f"Input documents prepared. Total: {len(input_documents)}")

        if not input_documents:
            self.logger.warning("No input documents found. Skipping analysis.")
            return

        # Prepare tasks with only serializable data
        tasks = []
        for input_doc in input_documents:
            tasks.append(
                (
                    input_doc,
                    self.candidate_documents,
                    self.input_dirs,
                    self.candidate_dirs,
                    str(self.log_dir),
                    str(self.mode)
                )
            )

        # Process contracts using multiprocessing or sequentially
        results = []
        if self.use_multiprocessing:
            self.logger.info("Using multiprocessing for contract analysis.")
            with multiprocessing.Pool() as pool:
                try:
                    results = pool.map(self._safe_process_worker, tasks)
                except Exception as e:
                    self.logger.error(f"Error in multiprocessing: {e}")
        else:
            self.logger.info("Running contract analysis sequentially (no multiprocessing).")
            for task in tasks:
                try:
                    results.append(self._safe_process_worker(task))
                except Exception as e:
                    self.logger.error(f"Error processing contract: {e}")

        self.logger.info(f"Completed processing all input contracts. Processed: {len(results)}")

    def _prepare_documents(self, contract_type: str) -> list[dict[str, Any]]:
        """Prepares documents for a given contract type ('candidate' or 'input')."""
        is_input = contract_type == "input"
        directories = self.input_dirs if is_input else self.candidate_dirs
        processor = ContractFileProcessor(ast_dir=directories["ast"], cfg_dir=directories["cfg"])
        self.logger.info(f"Preparing {contract_type} documents using ContractFileProcessor.")
        documents = self._process_contracts(processor, is_input)
        return [doc.to_dict() for doc in documents]

    def _process_contracts(self, processor: ContractFileProcessor, is_input: bool) -> List[Document]:
        """Processes contracts using the given processor."""
        contracts = processor.group_files(mode=self.mode)

        if not contracts:
            self.logger.warning(f"No {'input' if is_input else 'candidate'} contracts found.")
            return []

        processed_docs = []

        for contract in contracts:
            contract_id = contract[0]
            source_code = contract[2] if isinstance(contract[2], str) else json.dumps(contract[2], indent=2)
            label = contract[3]

            json_rep = {}
            if is_input:
                # Extract AST and CFG using the processor
                json_rep = {"json": {
                    "ast": processor.extract_ast(contract_id, label) if self.mode in ["ast", "ast_cfg"] else None,
                    "cfg": processor.extract_cfg(contract_id, label) if self.mode in ["cfg", "ast_cfg"] else None
                }}

            # Construct Document object with AST and CFG data
            doc = Document(
                text=source_code,
                metadata={
                    "contract_id": contract_id,
                    "label": label,
                    **json_rep
                },
            )
            processed_docs.append(doc)

        self.logger.info(f"Processed {len(processed_docs)} {'input' if is_input else 'candidate'} contracts.")

        if is_input:
            return processed_docs
        else:
            self.store_contracts(contracts)
            stored_contracts = self.load_contracts()
            self.logger.info(f"Stored and loaded {len(stored_contracts)} candidate contracts.")
            return stored_contracts

    @staticmethod
    def _safe_process_worker(task):
        """Wrapper to safely process a task and catch exceptions."""
        try:
            return process_input_contract_worker(task)
        except Exception as e:
            DebugLogger().error(f"Error in worker process: {e}")
            return None  # Return None for failed tasks
