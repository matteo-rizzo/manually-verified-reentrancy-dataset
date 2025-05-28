import csv
import logging
import os

from rich.logging import RichHandler

# Setup logging with rich
logging.basicConfig(
    level="INFO",
    format="%(message)s",
    datefmt="[%X]",
    handlers=[RichHandler()]
)
logger = logging.getLogger("rich")


class ContractProcessor:
    """Class to process Solidity contracts for reentrancy checks."""

    def __init__(self, folder_path, dataset_label):
        """
        Initialize ContractProcessor.

        :param folder_path: Path to the folder containing Solidity contracts.
        :param dataset_label: Label for the dataset ('reentrant' or 'safe').
        """
        self.folder_path = folder_path
        self.dataset_label = dataset_label

    def process_files(self):
        """
        Process all Solidity files in the specified folder.

        :return: List of processed contract data as dictionaries.
        """
        if not os.path.exists(self.folder_path):
            logger.error(f"Folder not found: {self.folder_path}")
            return []

        rows = []
        for root, _, files in os.walk(self.folder_path):
            for file in files:
                if file.endswith(".sol"):  # Only process Solidity files
                    file_path = os.path.join(root, file)
                    rows.append(self._process_file(file_path))
        return rows

    def _process_file(self, file_path):
        """
        Process a single Solidity file for the reentrancy property.

        :param file_path: Path to the Solidity file.
        :return: Dictionary containing processed contract data.
        """
        contract_name = os.path.basename(file_path).replace(".sol", "")
        row = {
            "dataset": "ManuallyVerified",
            "id": contract_name,
            "property": "Reentrancy",
            "property_holds": "t" if self.dataset_label == "reentrant" else "f",
            "chain": "main",
            "addr": contract_name,
            "contractname": contract_name,
            "fp_sol": f"{self.dataset_label}/{contract_name}",
            "fp_bytecode": f"{self.dataset_label}/{contract_name}",
            "fp_runtime": f"{self.dataset_label}/{contract_name}",
        }
        logger.info(f"Processed contract: {contract_name} | Reentrancy: {row['property_holds']}")
        return row


class ManuallyVerifiedGenerator:
    """Main class to orchestrate the dataset building process."""

    def __init__(self, reentrant_dir, safe_dir, output_csv):
        """
        Initialize the dataset builder.

        :param reentrant_dir: Path to the folder containing reentrant contracts.
        :param safe_dir: Path to the folder containing safe contracts.
        :param output_csv: Path to the output CSV file.
        """
        self.reentrant_dir = reentrant_dir
        self.safe_dir = safe_dir
        self.output_csv = output_csv
        self.fieldnames = [
            "dataset", "id", "property", "property_holds", "chain", "addr",
            "contractname", "fp_sol", "fp_bytecode", "fp_runtime"
        ]

    def write_to_csv(self, rows):
        """
        Write rows to the specified CSV file.

        :param rows: List of dictionaries containing data to write.
        """
        try:
            with open(self.output_csv, mode="w", newline="", encoding="utf-8") as csv_file:
                writer = csv.DictWriter(csv_file, fieldnames=self.fieldnames)
                writer.writeheader()
                writer.writerows(rows)
            logger.info(f"Dataset written to {self.output_csv}")
        except Exception as e:
            logger.error(f"Error writing to CSV: {e}")

    def build_dataset(self):
        """
        Build the dataset by processing contracts and writing to CSV.
        """
        all_rows = []

        logger.info("Processing reentrant contracts...")
        all_rows.extend(ContractProcessor(self.reentrant_dir, "reentrant").process_files())

        logger.info("Processing safe contracts...")
        all_rows.extend(ContractProcessor(self.safe_dir, "safe").process_files())

        logger.info("Writing data to CSV...")
        self.write_to_csv(all_rows)


if __name__ == "__main__":
    # Paths to your dataset folders
    REENTRANT_DIR = os.path.join("..", "dataset", "handcrafted", "source", "reentrant")
    SAFE_DIR = os.path.join("..", "dataset", "handcrafted", "source", "safe")
    OUTPUT_CSV = "manually_verified.csv"

    dataset_builder = ManuallyVerifiedGenerator(REENTRANT_DIR, SAFE_DIR, OUTPUT_CSV)
    dataset_builder.build_dataset()
