import argparse
import json
import os
import time
from pathlib import Path

from src.classes.utils.DebugLogger import DebugLogger
from src.classes.utils.EnvLoader import EnvLoader
from src.classes.xrag.LLMHandler import LLMHandler
from src.functions.utils import get_missing_files

# Load environment configuration.
try:
    EnvLoader(env_dir="src").load_env_files()
except Exception as e:
    print(f"Error loading environment configuration: {e}")
    exit(1)

logger = DebugLogger()
LOGS_BASE_DIR = Path("logs", "baseline")


def load_and_filter_contracts(path_to_contracts: Path, files_to_process: list[str] = None) -> list[Path]:
    """
    Loads and filters Solidity contract file paths with better error handling.
    """
    if not path_to_contracts.is_dir():
        logger.error(f"Directory not found: {path_to_contracts}")
        return []
    try:
        if files_to_process is None:
            files = [f for f in path_to_contracts.iterdir() if f.is_file() and f.name.endswith(".sol")]
        else:
            files = []
            for filename in files_to_process:
                filepath = path_to_contracts / filename
                if filepath.is_file() and filename.endswith(".sol"):
                    files.append(filepath)
                elif not filepath.is_file():
                    logger.warning(f"File not found: {filepath}")
                elif not filename.endswith(".sol"):
                    logger.warning(f"Skipping non-Solidity file: {filepath}")
        return sorted(files)
    except OSError as e:
        logger.error(f"Error accessing directory {path_to_contracts}: {e}")
        return []


def process_contract(path_to_file: Path, gt_category: str, llm: LLMHandler, log_dir: Path) -> bool:
    """
    Processes a single contract file with improved error handling.
    Returns True if classification is correct, False otherwise.
    """
    filename = path_to_file.name
    try:
        contract_content = path_to_file.read_text(encoding='latin-1')
    except UnicodeDecodeError as e:
        logger.error(f"Error decoding file {path_to_file} with latin-1: {e}. Trying utf-8.")
        try:
            contract_content = path_to_file.read_text(encoding='utf-8')
        except Exception as e:
            logger.error(f"Error reading file {path_to_file}: {e}")
            return False
    except Exception as e:
        logger.error(f"Error reading file {path_to_file}: {e}")
        return False

    logger.debug(f"Processing file: {filename}")

    try:
        llm_response = llm.analyze_contract(contract_content)
        if llm_response:
            answer = json.loads(llm_response)
        else:
            logger.error(f"Empty LLM response for file {filename}: {llm_response}")
            return False
    except json.JSONDecodeError as e:
        logger.error(f"Error decoding JSON response for file {filename}: {e}")
        return False
    except Exception as e:
        logger.error(f"Error generating completion for file {filename}: {e}")
        return False

    output_path = log_dir / f"{filename.split('.')[0]}.json"
    try:
        output_path.write_text(json.dumps(answer, indent=4, ensure_ascii=True), encoding='utf-8')
    except OSError as e:
        logger.error(f"Error writing output file {output_path}: {e}")
    except Exception as e:
        logger.error(f"Unexpected error writing output file {output_path}: {e}")

    return answer.get("classification", "").strip().lower() == gt_category.lower()


def evaluate(path_to_contracts: Path, model_name: str = None, files_to_process: list[str] = None) -> None:
    """
    Evaluates Solidity contracts in the given directory with better error handling.
    """
    if not path_to_contracts.is_dir():
        logger.error(f"Directory not found: {path_to_contracts}")
        return

    gt_category = path_to_contracts.name
    timestamp = time.strftime("%Y%m%d-%H%M%S")
    log_dir = LOGS_BASE_DIR / model_name / f"{gt_category}_{timestamp}"
    try:
        log_dir.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        logger.error(f"Error creating log directory {log_dir}: {e}")
        return

    solidity_files = load_and_filter_contracts(path_to_contracts, files_to_process)
    total_files = len(solidity_files)

    if total_files == 0:
        logger.warning(f"No Solidity (.sol) files found in {path_to_contracts}.")
        return

    logger.info(f"Testing {model_name} on {total_files} files from category: {gt_category}")
    logger.info(f"Results will be logged at: {log_dir}")

    llm = LLMHandler()
    correct = 0
    for index, path_to_file in enumerate(solidity_files, start=1):
        if process_contract(path_to_file, gt_category, llm, log_dir):
            correct += 1
        running_accuracy = correct / index
        logger.info(f"Processed {index}/{total_files} files. Running accuracy: {running_accuracy:.2%}")

    if total_files > 0:
        accuracy = correct / total_files
        logger.info(f"Final classification accuracy for {model_name} - '{gt_category}': {accuracy:.2%}")
        logger.debug(f"Processed {total_files} files. Final Accuracy: {accuracy:.2%}")
    else:
        logger.warning(f"No files were processed for category '{gt_category}'.")


def main(args) -> None:
    """
    Main function to evaluate test datasets with improved error handling.
    """
    dataset_path = Path(args.dataset_path)
    path_to_reentrant = dataset_path / "source" / "reentrant"
    path_to_safe = dataset_path / "source" / "safe"

    all_reentrant_files = [f.name for f in path_to_reentrant.iterdir() if f.is_file() and f.name.endswith(".sol")]
    all_safe_files = [f.name for f in path_to_safe.iterdir() if f.is_file() and f.name.endswith(".sol")]
    missing_reentrant_files = all_reentrant_files
    missing_safe_files = all_safe_files

    if args.missing_files_dir:
        missing_files_path = Path(args.missing_files_dir)
        try:
            missing_reentrant_files = get_missing_files(str(missing_files_path), all_reentrant_files)
            missing_safe_files = get_missing_files(str(missing_files_path), all_safe_files)
        except OSError as e:
            logger.error(f"Error accessing missing files directory {missing_files_path}: {e}")
            missing_reentrant_files = []
            missing_safe_files = []

    os.environ["MODEL_NAME"] = args.model_name

    evaluate(path_to_reentrant, args.model_name, missing_reentrant_files)
    evaluate(path_to_safe, args.model_name, missing_safe_files)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Contract Analysis CLI for analyzing manually verified contracts.")
    parser.add_argument("--dataset-path", type=str, default="dataset/manually-verified",
                        help="Base path for the dataset.")
    parser.add_argument("--model-name", type=str, required=True, help="OpenAI or Google model name.")
    parser.add_argument("--missing-files-dir", type=str, default="",
                        help="Path to a directory to check missing files against")
    args = parser.parse_args()
    main(args)