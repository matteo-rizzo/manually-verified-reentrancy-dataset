#!/usr/bin/env python3

import argparse
import logging
import re
import sys
from pathlib import Path
from typing import Tuple

# --- Dependency Check & Import ---
try:
    import chardet
    CHARDET_AVAILABLE = True
except ImportError:
    CHARDET_AVAILABLE = False
    # No critical error yet, will fail later if needed

# --- Setup Logging ---
# Configured in main() based on verbosity argument
logging.basicConfig(level=logging.WARNING, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

# --- Core Pruning Logic ---

def remove_block(code: str, block_type: str, block_name: str) -> Tuple[str, bool]:
    """
    Finds and removes a specific block (contract, library, interface) by name.
    Uses brace counting, which has limitations (comments, strings).
    Returns the modified code and a boolean indicating if changes were made.
    """
    # Regex to find the start of the block definition
    # Uses \s+ for required spaces, \w+ for the name
    # Makes sure it's the specific name requested
    pattern = rf'((?:{block_type})\s+{block_name})\s*{{'
    match = re.search(pattern, code)

    if not match:
        return code, False # Block not found

    start_brace_index = match.end() -1 # Index of the opening brace '{'
    logger.debug(f"Found start of '{block_type} {block_name}' at index {match.start()}")

    brace_count = 1 # Start count at 1 for the opening brace found
    end_brace_index = -1 # Initialize to -1 (not found)

    # Start searching for the matching closing brace
    for i in range(start_brace_index + 1, len(code)):
        if code[i] == '{':
            brace_count += 1
        elif code[i] == '}':
            brace_count -= 1
            if brace_count == 0:
                end_brace_index = i
                break # Found the matching closing brace

    if end_brace_index == -1:
        logger.warning(f"Could not find matching closing brace for '{block_type} {block_name}' starting at index {start_brace_index}. Skipping removal.")
        return code, False # Indicate no change was made due to error

    # Remove the entire block from start of definition to end brace
    block_start_index = match.start()
    code_before = code[:block_start_index]
    code_after = code[end_brace_index + 1:]

    # Add a newline if needed to avoid joining lines
    if code_before and not code_before.endswith(('\n', '\r')):
         code_before += '\n'
    if code_after and not code_after.startswith(('\n', '\r')):
         code_after = '\n' + code_after

    cleaned_code = code_before + code_after
    logger.debug(f"Removed block '{block_type} {block_name}'")
    return cleaned_code, True


def prune_code(solidity_code: str) -> str:
    """Applies all pruning steps to the code string."""
    cleaned_code = solidity_code

    # 1. Remove specific blocks (Owned, Ownable, specific interfaces/libraries if desired)
    #    Using a loop isn't strictly necessary if names are unique, but safer.
    blocks_to_remove = [
        ("contract", "Owned"),
        ("contract", "Ownable"),
        # Add other specific library/interface names here if needed
        # ("library", "SafeMath"),
        # ("interface", "IERC20"),
    ]
    code_changed = True
    while code_changed: # Loop in case removing one block affects regex for another
        code_changed = False
        for block_type, block_name in blocks_to_remove:
            cleaned_code, changed_this_pass = remove_block(cleaned_code, block_type, block_name)
            if changed_this_pass:
                code_changed = True # Signal that a change occurred, loop again

    # 2. Remove Pragma line(s)
    # Matches start of line, optional space, pragma solidity, anything until ;, optional space, end of line
    cleaned_code = re.sub(r"^\s*pragma\s+solidity\s*[^;]*;\s*$", "", cleaned_code, flags=re.MULTILINE)
    logger.debug("Removed pragma lines.")

    # 3. Reduce multiple empty lines to single empty lines
    # Replace one or more occurrences of (newline + optional whitespace + newline) with just two newlines
    cleaned_code = re.sub(r'\n\s*\n+', '\n\n', cleaned_code)
    logger.debug("Reduced multiple empty lines.")

    # 4. Remove leading/trailing whitespace and ensure single trailing newline
    cleaned_code = cleaned_code.strip() + '\n'
    logger.debug("Stripped leading/trailing whitespace.")

    return cleaned_code


def process_file(file_path: Path, output_dir: Path):
    """Reads, prunes, and writes a single Solidity file."""
    logger.info(f"Processing file: {file_path}")
    try:
        # Read with encoding detection
        raw_content = file_path.read_bytes()
        if not raw_content:
             logger.warning(f"Skipping empty file: {file_path}")
             return

        # Detect encoding
        if not CHARDET_AVAILABLE:
             logger.error("Error: 'chardet' library is required but not installed ('pip install chardet'). Cannot detect encoding.")
             # As a fallback, try UTF-8, but warn
             logger.warning(f"Attempting to read {file_path} as UTF-8 (chardet not available).")
             detected_encoding = 'utf-8'
             try:
                 solidity_code = raw_content.decode(detected_encoding)
             except UnicodeDecodeError:
                  logger.error(f"Failed to decode {file_path} as UTF-8. Skipping.")
                  return
        else:
            detection = chardet.detect(raw_content)
            detected_encoding = detection['encoding']
            confidence = detection['confidence']
            if not detected_encoding or confidence < 0.7: # Be reasonably confident
                logger.warning(f"Low confidence ({confidence:.2f}) detecting encoding for {file_path} (detected: {detected_encoding}). Falling back to UTF-8.")
                detected_encoding = 'utf-8' # Fallback

            logger.debug(f"Detected encoding: {detected_encoding} with confidence {confidence:.2f}" if detection else "Detection failed")

            # Decode using detected encoding
            try:
                solidity_code = raw_content.decode(detected_encoding)
            except (UnicodeDecodeError, TypeError) as e: # TypeError if encoding is None
                logger.error(f"Error decoding {file_path} with detected encoding '{detected_encoding}': {e}. Skipping.")
                return

        # Prune the code
        cleaned_code = prune_code(solidity_code)

        # Prepare output path
        output_path = output_dir / file_path.name
        output_dir.mkdir(parents=True, exist_ok=True) # Ensure output subdir exists

        # Write the cleaned code
        output_path.write_text(cleaned_code, encoding='utf-8')
        logger.info(f"Successfully processed and saved to: {output_path}")

    except FileNotFoundError:
        logger.error(f"File not found: {file_path}")
    except Exception as e:
        logger.error(f"Failed to process file {file_path}: {e}", exc_info=True) # Log traceback for unexpected errors

def process_directory(input_dir: Path, output_dir: Path):
    """Finds and processes all .sol files in a directory recursively."""
    logger.info(f"Scanning directory: {input_dir}")
    count = 0
    for file_path in input_dir.rglob("*.sol"):
        if file_path.is_file():
            try:
                # Calculate relative path to maintain structure
                relative_path = file_path.relative_to(input_dir)
                # Output subdir is base output + relative parent path
                output_subdir = output_dir / relative_path.parent
                process_file(file_path, output_subdir)
                count += 1
            except KeyboardInterrupt:
                logger.warning("Keyboard interrupt received. Exiting.")
                sys.exit(1)
            except Exception as e:
                # Log error but continue with other files
                logger.error(f"Unexpected error processing directory for file {file_path}: {e}", exc_info=True)
    logger.info(f"Finished processing directory. Processed {count} files.")


def main():
    # --- Argument Parsing ---
    parser = argparse.ArgumentParser(
        description="Prune Solidity files by removing specific blocks (Owned, Ownable), pragma lines, and excess empty lines.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        "input_path",
        type=Path,
        help="Path to the input Solidity file or directory."
    )
    parser.add_argument(
        "-o", "--output",
        type=Path,
        default=Path("./pruned"), # Default output directory
        help="Path to the output directory."
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose (INFO) logging."
    )
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Enable debug logging (very verbose)."
    )
    args = parser.parse_args()

    # --- Configure Logging Level ---
    if args.debug:
        logger.setLevel(logging.DEBUG)
    elif args.verbose:
        logger.setLevel(logging.INFO)
    else:
        logger.setLevel(logging.WARNING) # Default to warnings only

    # --- Dependency Check ---
    if not CHARDET_AVAILABLE:
        logger.error("Error: 'chardet' library not found. Please install it using 'pip install chardet'.")
        sys.exit(1)

    # --- Process Input ---
    input_path: Path = args.input_path
    output_dir: Path = args.output

    if not input_path.exists():
        logger.error(f"Error: Input path does not exist: {input_path}")
        sys.exit(1)

    try:
        if input_path.is_file() and input_path.suffix == ".sol":
            # If input is a single file, output directly into the output directory
            logger.info(f"Processing single file: {input_path}")
            output_dir.mkdir(parents=True, exist_ok=True) # Ensure base output dir exists
            process_file(input_path, output_dir)
            logger.info("Processing complete.")
        elif input_path.is_dir():
            logger.info(f"Processing directory: {input_path}")
            process_directory(input_path, output_dir)
            # Completion message logged by process_directory
        else:
            logger.error(f"Error: Input path {input_path} is not a valid .sol file or directory.")
            sys.exit(1)
    except Exception as e:
         logger.critical(f"A critical error occurred: {e}", exc_info=True)
         sys.exit(1)


if __name__ == "__main__":
    main()
