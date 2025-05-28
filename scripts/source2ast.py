#!/usr/bin/env python3

import argparse
import json
import logging
import re
import subprocess
import sys
from pathlib import Path
from typing import List, Optional, Set, Dict, Any, Tuple  # Added Tuple

from rich.logging import RichHandler

# Configure rich logging
logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",
    datefmt="[%X]",
    handlers=[RichHandler()]
)
logger = logging.getLogger("rich")

# --- Constants ---
# Default version if no pragma or resolution fails
DEFAULT_SOLC_VERSION = "0.4.24"  # Changed default back for consistency, override with -v

# --- Dependency Check & Import ---
# Check for 'packaging' library (for SemVer)
try:
    from packaging.version import Version, InvalidVersion
    from packaging.specifiers import SpecifierSet, InvalidSpecifier

    PACKAGING_AVAILABLE = True
except ImportError:
    PACKAGING_AVAILABLE = False


    # Define dummy classes if packaging is not available
    class Version:
        pass  # type: ignore


    class InvalidVersion(Exception):
        pass  # type: ignore


    class SpecifierSet:
        pass  # type: ignore


    class InvalidSpecifier(Exception):
        pass  # type: ignore


    logger.warning(
        "Warning: 'packaging' library not found ('pip install packaging'). Complex pragma resolution disabled.")

# Check for 'py-solc-x' library
try:
    import solcx
    from solcx.exceptions import SolcNotInstalled, UnsupportedVersionError

    SOLCX_AVAILABLE = True
except ImportError:
    SOLCX_AVAILABLE = False


    # Define dummy classes/exceptions if solcx isn't available
    class SolcNotInstalled(Exception):
        pass  # type: ignore


    class UnsupportedVersionError(Exception):
        pass  # type: ignore


    logger.error("Error: py-solc-x is required but not found. Please install it ('pip install py-solc-x').")
    # Exiting here as solcx is crucial
    sys.exit(1)


# --- Helper Functions ---

def run_command(
        command: List[str],  # Expects List for non-shell execution
        check: bool = True,
        timeout: Optional[int] = None,
        **kwargs
) -> Optional[subprocess.CompletedProcess]:
    """Runs a command using subprocess (non-shell), returning result or None on error if check=False."""
    cmd_str = ' '.join(command)  # For logging
    logger.debug(f"Running command: {cmd_str}")
    try:
        # Execute directly, no shell needed
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=check,
            timeout=timeout,
            encoding='utf-8',  # Be explicit
            errors='replace',  # Handle potential decoding errors
            **kwargs
        )
        if result.stderr:
            logger.debug(f"Command stderr:\n{result.stderr.strip()}")
        return result
    except FileNotFoundError:
        logger.error(f"Error: Command not found: {command[0]}. Is it installed?")
        if check: sys.exit(1)
        return None
    except subprocess.TimeoutExpired:
        logger.error(f"Error: Command timed out after {timeout}s: {cmd_str}")
        if check: sys.exit(1)
        return None
    except subprocess.CalledProcessError as e:
        logger.error(f"Error running command: {cmd_str} (Code: {e.returncode})")
        if e.stderr: logger.error(f"stderr:\n{e.stderr.strip()}")
        if check: sys.exit(1)
        return None
    except Exception as e:
        logger.error(f"Unexpected error running command {cmd_str}: {e}", exc_info=True)
        if check: sys.exit(1)
        return None


def get_installed_solc_versions() -> Set[str]:
    """Gets the set of installed solc versions using py-solc-x."""
    if not SOLCX_AVAILABLE: return set()
    try:
        logger.debug("Fetching installed solc versions via py-solc-x...")
        # Convert Version objects back to strings for consistency
        versions = {str(v) for v in solcx.get_installed_solc_versions()}
        logger.debug(f"Found installed versions: {versions or '{}'}")
        return versions
    except Exception as e:
        logger.error(f"Error retrieving solc versions using py-solc-x: {e}")
        return set()


def ensure_solc_version_installed(
        version: str,
        installed_versions: Set[str],
        attempted_installs: Set[str]
) -> bool:
    """Checks if a version is installed via solcx, tries to install it if not. Returns True if available."""
    if not SOLCX_AVAILABLE: return False  # Should have exited earlier, but double check

    # Basic check for obviously invalid version format before proceeding
    if not re.fullmatch(r"0\.\d+\.\d+", version):
        logger.error(f"Version '{version}' has invalid format. Cannot install.")
        return False

    if version in installed_versions:
        return True
    if version in attempted_installs:
        logger.debug(f"Previously failed install attempt for {version}. Skipping.")
        return False  # Avoid retrying failed installs

    logger.info(f"Solc version {version} not found locally. Attempting installation via py-solc-x...")
    attempted_installs.add(version)  # Mark as attempted
    try:
        # Check minimum supported version by py-solc-x (0.4.11)
        min_supported = "0.4.11"
        should_install = True
        base_version_tuple = parse_version(version)
        min_supported_tuple = parse_version(min_supported)

        if base_version_tuple is None:
            logger.error(f"Version {version} format is invalid for comparison. Cannot install.")
            should_install = False
        elif min_supported_tuple and base_version_tuple < min_supported_tuple:
            logger.error(f"Version {version} is below py-solc-x minimum support ({min_supported}). Cannot install.")
            should_install = False

        if not should_install:
            return False

        # Proceed with installation
        solcx.install_solc(version, show_progress=False)  # Set show_progress as needed
        logger.info(f"Successfully installed solc version {version}.")
        installed_versions.add(version)  # Update our tracked set
        return True
    except (UnsupportedVersionError, SolcNotInstalled, Exception) as e:
        logger.error(f"Failed to install solc version {version} using py-solc-x: {e}", exc_info=False)
        return False


# --- Pragma/Version Resolution ---

def extract_pragma_requirement_string(file_path: Path) -> Optional[str]:
    """Extracts the first full pragma solidity requirement string."""
    try:
        content = ""
        with file_path.open('r', encoding='utf-8', errors='ignore') as f:
            for i, line in enumerate(f):
                content += line
                if i > 50: break
        match = re.search(r"pragma\s+solidity\s+([^;]+);", content, re.IGNORECASE)
        if match:
            requirement = match.group(1).strip()
            logger.debug(f"Found pragma requirement '{requirement}' in {file_path.name}")
            return requirement
    except Exception as e:
        logger.warning(f"Could not read or parse pragma from {file_path}: {e}")
    logger.debug(f"No pragma requirement found in {file_path.name}")
    return None


def find_best_matching_version_with_packaging(requirement: str, installed_versions: Set[str]) -> Optional[str]:
    """Finds the highest installed version satisfying the SemVer requirement using 'packaging'."""
    if not PACKAGING_AVAILABLE:
        logger.error("Internal Error: find_best_matching_version_with_packaging called but 'packaging' is unavailable.")
        return None
    if not requirement: return None
    try:
        spec = SpecifierSet(requirement, prereleases=False)
    except InvalidSpecifier:
        logger.warning(f"Invalid pragma specifier format: '{requirement}'. Cannot resolve using 'packaging'.")
        return None

    valid_versions: List[Version] = []
    for v_str in installed_versions:
        try:
            version = Version(v_str)
            if version in spec: valid_versions.append(version)
        except InvalidVersion: continue
        except TypeError: logger.warning(f"Could not compare version {v_str} against spec {requirement}. Skipping.")

    if valid_versions:
        best_version = min(valid_versions)
        logger.debug(f"Requirement '{requirement}' matches installed: {[str(v) for v in valid_versions]}. Best: {best_version}")
        return str(best_version)
    else:
        logger.debug(f"No installed version satisfies requirement '{requirement}'")
        return None

def parse_version(version_str: str) -> Optional[Tuple[int, int, int]]:
    """Parses X.Y.Z string into a tuple of ints, returns None if invalid."""
    parts = version_str.split('.')
    if len(parts) == 3 and all(p.isdigit() for p in parts):
        try:
            return tuple(map(int, parts))  # type: ignore
        except ValueError:
            return None
    return None


def find_best_matching_version_fallback(requirement: str, installed_versions: Set[str]) -> Optional[str]:
    """Fallback logic to find best version without 'packaging' library."""
    logger.warning(f"Using fallback version extraction for requirement: '{requirement}'")
    resolved_version: Optional[str] = None
    best_version_tuple: Optional[Tuple[int, int, int]] = None

    caret_match = re.match(r"\^(\d+\.\d+\.\d+)", requirement)
    if caret_match:
        base_version_str = caret_match.group(1)
        base_version_tuple = parse_version(base_version_str)
        if base_version_tuple:
            logger.debug(f"Fallback: Handling caret requirement for base {base_version_str}")
            major, minor, patch = base_version_tuple
            upper_bound_tuple = (major + 1, 0, 0)
            candidate_versions: List[Tuple[int, int, int]] = []
            for v_str in installed_versions:
                v_tuple = parse_version(v_str)
                if v_tuple and v_tuple >= base_version_tuple and v_tuple < upper_bound_tuple:
                    candidate_versions.append(v_tuple)
            if candidate_versions:
                best_version_tuple = min(candidate_versions)
                resolved_version = f"{best_version_tuple[0]}.{best_version_tuple[1]}.{best_version_tuple[2]}"
                logger.info(f"Fallback: Found best match for caret '{requirement}': {resolved_version}")

    if resolved_version is None:
        exact_match = re.search(r"(\d+\.\d+\.\d+)", requirement)
        if exact_match:
            resolved_version = exact_match.group(1)
            logger.info(f"Fallback: Found first exact version: {resolved_version}")

    if resolved_version is None:
        logger.warning(f"Fallback: No specific version pattern found in pragma '{requirement}'.")

    return resolved_version


def get_solc_ast_option(version_str: str) -> str:
    """Determines the correct AST flag based on solc version."""
    version_tuple = parse_version(version_str)
    if version_tuple and version_tuple < (0, 5, 0):
        return "--ast-json"
    elif PACKAGING_AVAILABLE:
        try:
            if Version(version_str) < Version("0.5.0"): return "--ast-json"
        except InvalidVersion:
            pass
    return "--ast-compact-json"


def determine_target_version(
        file_path: Path,
        args: argparse.Namespace,
        installed_versions: Set[str],
        version_cache: Dict[str, Optional[str]]
) -> str:
    """Determines the solc version to use for a given file."""
    if args.single: return args.version

    requirement = extract_pragma_requirement_string(file_path)
    if not requirement:
        logger.warning(f"No pragma found in '{file_path.name}'. Using default: {args.version}")
        return args.version

    if requirement in version_cache:
        cached_result = version_cache[requirement]
        if cached_result:
            logger.debug(f"Using cached version {cached_result} for pragma '{requirement}'")
            return cached_result
        else:
            logger.debug(f"Cached result for pragma '{requirement}' is None. Using default.")
            return args.version

    resolved_version: Optional[str] = None
    if PACKAGING_AVAILABLE:
        resolved_version = find_best_matching_version_with_packaging(requirement, installed_versions)
        if resolved_version is None:
            logger.debug(f"Packaging library could not resolve '{requirement}'. Trying fallback.")

    if resolved_version is None:
        resolved_version = find_best_matching_version_fallback(requirement, installed_versions)

    version_cache[requirement] = resolved_version

    if resolved_version:
        return resolved_version
    else:
        logger.warning(f"Could not resolve pragma '{requirement}' after fallback. Using default: {args.version}")
        return args.version


def increment_patch_version(version_str: str) -> Optional[str]:
    """Increments the patch segment of a version string X.Y.Z."""
    version_tuple = parse_version(version_str)
    if version_tuple:
        major, minor, patch = version_tuple
        next_patch = patch + 1
        return f"{major}.{minor}.{next_patch}"
    else:
        logger.warning(f"Cannot increment version: Invalid format '{version_str}'")
        return None


# --- Core Processing Function ---

def process_solidity_file(
        file_path: Path,
        output_dir_base: Path,
        input_dir_base: Path,
        target_solc_version: str
) -> bool:
    """
    Generates AST using py-solc-x path. Attempts to extract valid JSON from output.
    Saves extracted JSON (with absolutePath removed) if valid. Parses the JSON object.
    Returns True on success (valid JSON parsed and saved), False otherwise.
    """
    relative_path = file_path.relative_to(input_dir_base)
    logger.info(f"Processing '{relative_path}' with solc {target_solc_version}...")

    ast_option = get_solc_ast_option(target_solc_version)
    output_file_path = (output_dir_base / relative_path).with_suffix('.json')

    try:
        output_file_path.parent.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        logger.error(f"Error creating output directory '{output_file_path.parent}': {e}")
        return False

    solc_executable: Optional[Path] = None
    try:
        install_folder = solcx.get_solcx_install_folder()
        executable_name = f"solc-v{target_solc_version}"
        solc_executable = Path(install_folder) / executable_name
        if not solc_executable.is_file():
            logger.error(f"Calculated solc executable path not found: {solc_executable}")
            try:
                logger.error(f"Contents of install folder '{install_folder}': {list(Path(install_folder).glob('*'))}")
            except Exception:
                pass
            return False
        logger.debug(f"Using solc executable: {solc_executable}")
    except Exception as e:
        logger.error(f"Error determining solc executable path for version {target_solc_version}: {e}", exc_info=True)
        return False

    command = [str(solc_executable), ast_option, str(file_path)]
    result = run_command(command, check=False, timeout=180)

    if not result or result.returncode != 0:
        logger.error(f"AST generation failed for '{relative_path}'. Solc exited with error.")
        return False

    # --- Validate, Extract JSON, Parse, Modify, and Save Output ---
    ast_content_str = result.stdout  # The raw string output from solc
    if not ast_content_str:
        logger.warning(f"Skipping save for '{relative_path}': solc produced empty output.")
        return False

    parsed_ast: Optional[Any] = None
    json_to_save_str: Optional[str] = None  # Will hold the string to be saved

    try:
        # Attempt 1: Parse the entire output directly
        logger.debug(f"Attempting to parse entire solc output for '{relative_path}'...")
        parsed_ast = json.loads(ast_content_str)
        json_to_save_str = ast_content_str  # Tentatively use original if it's valid JSON
        logger.debug(f"Successfully parsed entire AST JSON for '{relative_path}'.")

    except json.JSONDecodeError:
        logger.info(f"Solc output for '{relative_path}' is not pure JSON. Attempting extraction...")
        # Attempt 2: Extract content between first '{' and last '}'
        try:
            start_index = ast_content_str.find('{')
            end_index = ast_content_str.rfind('}')
            if start_index != -1 and end_index != -1 and end_index > start_index:
                json_substring = ast_content_str[start_index: end_index + 1]
                logger.debug(f"Attempting to parse extracted substring: '{json_substring[:100]}...'")
                # Try parsing the extracted substring
                parsed_ast = json.loads(json_substring)
                json_to_save_str = json_substring  # Use extracted substring if it's valid JSON
                logger.info(f"Successfully extracted and parsed JSON object for '{relative_path}'.")
            else:
                logger.warning(f"Could not find JSON object braces '{{...}}' in output for '{relative_path}'.")
                parsed_ast = None  # Ensure parsed_ast is None if extraction failed
        except json.JSONDecodeError:
            logger.warning(f"Could not parse valid JSON even after extracting substring for '{relative_path}'.")
            logger.debug(f"Original output snippet: {ast_content_str[:300]}...")
            parsed_ast = None  # Ensure parsed_ast is None if parsing failed
        except Exception as e:
            logger.error(f"Error during JSON extraction/parsing for '{relative_path}': {e}")
            parsed_ast = None

    # Proceed only if we successfully obtained a parsed AST object
    if parsed_ast is not None:
        try:
            # --- Remove absolutePath from the parsed object ---
            removed_path = None
            if isinstance(parsed_ast, dict):
                # Use pop with default None: removes key if exists, does nothing otherwise
                removed_path = parsed_ast.pop('absolutePath', None)
                if removed_path is None and "attributes" in parsed_ast.keys() :
                    removed_path = parsed_ast['attributes'].pop('absolutePath', None)
                if removed_path:
                    logger.debug(f"Removed 'absolutePath': {removed_path} from parsed AST.")
                else:
                    logger.debug("'absolutePath' key not found in parsed AST dict.")
            else:
                logger.debug("Parsed AST is not a dictionary, cannot remove 'absolutePath'.")
            # --- End Removal ---

            # --- Serialize the MODIFIED parsed_ast back to JSON string ---
            # Use indent=2 for readability in the output file
            final_json_string_to_save = json.dumps(parsed_ast, indent=2)
            # --- End Serialize ---

            # Write the MODIFIED and re-serialized JSON string content
            output_file_path.write_text(final_json_string_to_save, encoding='utf-8')
            logger.info(f"AST (absolutePath removed) saved to '{output_file_path.relative_to(output_dir_base.parent)}'")
            return True  # Indicate success

        except OSError as e:
            logger.error(f"Error saving modified AST to '{output_file_path}': {e}")
            return False  # Indicate failure
        except TypeError as e:  # Catch potential errors during json.dumps
            logger.error(f"Error serializing modified AST for '{relative_path}': {e}")
            return False
    else:
        # Failed to parse valid JSON by any method
        logger.warning(f"Skipping save for '{relative_path}': Failed to obtain valid JSON content.")
        return False  # Indicate failure


# --- Main Execution ---

def main():
    parser = argparse.ArgumentParser(
        description="Generate Solidity ASTs using py-solc-x for version management.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("-i", "--input", type=Path, default="dataset/handcrafted-raw",
                        help="Input directory.")
    parser.add_argument("-o", "--output", type=Path, default="logs",
                        help="Base output directory (ASTs in 'ast' subdir).")
    parser.add_argument("-v", "--version", default=DEFAULT_SOLC_VERSION, help="Solc version for --single or fallback.")
    parser.add_argument("-s", "--single", action="store_true", help="Use only the --version specified.")
    parser.add_argument("--debug", action="store_true", help="Enable debug logging.")
    args = parser.parse_args()

    if args.debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    if not SOLCX_AVAILABLE: sys.exit(1)
    # No warning needed here for packaging, determine_target_version handles logging

    input_dir: Path = args.input.resolve()
    output_dir_base: Path = args.output.resolve()
    ast_output_dir = output_dir_base / "ast"

    if not input_dir.is_dir(): logger.error(f"Input directory '{input_dir}' not found."); sys.exit(1)
    try:
        ast_output_dir.mkdir(parents=True, exist_ok=True)
    except OSError as e:
        logger.error(f"Cannot create output directory '{ast_output_dir}': {e}");
        sys.exit(1)

    logger.info(f"Input directory: {input_dir}")
    logger.info(f"AST output directory: {ast_output_dir}")

    installed_versions = get_installed_solc_versions()
    attempted_installs: Set[str] = set()

    if args.single:
        logger.info(f"Single compiler mode: Using solc {args.version}")
        if not ensure_solc_version_installed(args.version, installed_versions, attempted_installs):
            logger.error(f"Exiting: Required single version {args.version} could not be installed.")
            sys.exit(1)

    logger.info(f"Scanning for .sol files in '{input_dir}'...")
    try:
        sol_files = list(input_dir.rglob('*.sol'))
        logger.info(f"Found {len(sol_files)} source files.")
    except Exception as e:
        logger.error(f"Error scanning for files in '{input_dir}': {e}")
        sys.exit(1)

    success_count, skipped_count, error_count = 0, 0, 0
    version_cache: Dict[str, Optional[str]] = {}

    for file_path in sol_files:
        # Determine initial version
        initial_target_version = determine_target_version(
            file_path, args, installed_versions, version_cache
        )

        # Ensure initial version is installed
        if not ensure_solc_version_installed(
                initial_target_version, installed_versions, attempted_installs
        ):
            logger.warning(
                f"Skipping '{file_path.relative_to(input_dir)}': Cannot ensure initial solc version {initial_target_version} is installed.")
            skipped_count += 1
            continue

        # --- Processing Attempts ---
        success = False  # Reset success flag for each file

        # First Attempt
        logger.debug(f"Attempt 1: Processing '{file_path.name}' with version {initial_target_version}")
        if process_solidity_file(file_path, ast_output_dir, input_dir, initial_target_version):
            success = True
        else:
            # Log failure of first attempt only if retry will be attempted
            if not args.single:
                logger.info(f"Attempt 1 failed for '{file_path.relative_to(input_dir)}' with {initial_target_version}.")
            # Error is already logged by process_solidity_file

        # Retry Logic (only if first attempt failed and not in single mode)
        if not success and not args.single:
            logger.info(f"Attempting retry with next patch version...")
            next_target_version = increment_patch_version(initial_target_version)

            if next_target_version:
                logger.debug(f"Calculated next version: {next_target_version}")
                # Ensure the next version is installed
                if ensure_solc_version_installed(
                        next_target_version, installed_versions, attempted_installs
                ):
                    # --- Second Processing Attempt ---
                    logger.info(
                        f"--> Attempt 2: Processing '{file_path.relative_to(input_dir)}' with version {next_target_version}")
                    if process_solidity_file(
                            file_path, ast_output_dir, input_dir, next_target_version
                    ):
                        success = True  # Retry succeeded!
                    else:
                        logger.warning(
                            f"Attempt 2 failed for '{file_path.relative_to(input_dir)}' with version {next_target_version}.")
                    # --- End Second Attempt ---
                else:
                    logger.warning(
                        f"Skipping retry for '{file_path.relative_to(input_dir)}': Cannot ensure next solc version {next_target_version} is installed.")
            else:
                logger.warning(
                    f"Could not calculate next patch version for {initial_target_version}. Cannot retry '{file_path.relative_to(input_dir)}'.")
        # End Retry Logic

        # --- Update Counters ---
        if success:
            success_count += 1
        else:
            # If we got here without success, it's an error
            # (assuming initial install check passed, otherwise it was skipped)
            error_count += 1

    # --- Summary ---
    logger.info("-" * 60)
    logger.info("Processing Summary:")
    logger.info(f"  Total files found:      {len(sol_files)}")
    logger.info(f"  Successfully generated: {success_count}")
    logger.info(f"  Skipped (version issue):{skipped_count}")
    logger.info(f"  Errors (solc/output):   {error_count}")
    logger.info(f"  ASTs saved in:          {ast_output_dir}")
    logger.info("-" * 60)


if __name__ == "__main__":
    main()
