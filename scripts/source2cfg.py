#!/usr/bin/env python3

import argparse
import json
import logging
import re
import shutil
import subprocess
import sys
from glob import glob
from pathlib import Path
from typing import List, Optional, Set, Dict, Tuple

# --- Dependency Check & Import ---
# Check for 'rich' library (for colored logging)
try:
    from rich.logging import RichHandler

    RICH_AVAILABLE = True
except ImportError:
    RICH_AVAILABLE = False
    RichHandler = object  # Dummy for type hinting if needed

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
    # Warning logged later if needed

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
    # Error logged later if needed

# --- Setup Logger Instance ---
# Get logger instance early, configuration happens in main()
logger = logging.getLogger("rich" if RICH_AVAILABLE else __name__)

# --- Constants ---
# Default version if no pragma or resolution fails
DEFAULT_SOLC_VERSION = "0.4.24"  # Default, can be overridden by args


# --- Helper Functions ---

def run_command(
        command: List[str],
        check: bool = True,
        timeout: Optional[int] = None,
        **kwargs
) -> Optional[subprocess.CompletedProcess]:
    """Runs a command using subprocess (non-shell), returning result or None on error if check=False."""
    cmd_str = ' '.join(command)
    logger.debug(f"Running command: {cmd_str}")
    try:
        result = subprocess.run(
            command, capture_output=True, text=True, check=check, timeout=timeout,
            encoding='utf-8', errors='replace', **kwargs
        )
        if result.stderr: logger.debug(f"Command stderr:\n{result.stderr.strip()}")
        return result
    except FileNotFoundError:
        logger.error(f"Error: Command not found: {command[0]}. Is it installed and in PATH?")
        if check: sys.exit(1)
        return None
    except subprocess.TimeoutExpired:
        logger.error(f"Error: Command timed out after {timeout}s: {cmd_str}")
        if check: sys.exit(1)
        return None
    except subprocess.CalledProcessError as e:
        log_func = logger.error if check else logger.warning
        log_func(f"Command failed: {cmd_str} (Code: {e.returncode})")
        if e.stderr: log_func(f"stderr:\n{e.stderr.strip()}")
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
    if not SOLCX_AVAILABLE: return False

    if not re.fullmatch(r"0\.\d+\.\d+", version):
        logger.error(f"Version '{version}' has invalid format. Cannot install.")
        return False

    if version in installed_versions: return True
    if version in attempted_installs:
        logger.debug(f"Previously failed install attempt for {version}. Skipping.")
        return False

    logger.info(f"Solc version {version} not found locally. Attempting installation via py-solc-x...")
    attempted_installs.add(version)
    try:
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

        if not should_install: return False

        solcx.install_solc(version, show_progress=False)
        logger.info(f"Successfully installed solc version {version}.")
        installed_versions.add(version)
        return True
    except (UnsupportedVersionError, SolcNotInstalled, Exception) as e:
        logger.error(f"Failed to install solc version {version} using py-solc-x: {e}", exc_info=False)
        return False


# --- Pragma/Version Resolution (Copied from AST script) ---

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
        spec = SpecifierSet(requirement, prereleases=True)
    except InvalidSpecifier:
        logger.warning(f"Invalid pragma specifier format: '{requirement}'. Cannot resolve using 'packaging'.")
        return None

    valid_versions: List[Version] = []
    for v_str in installed_versions:
        try:
            version = Version(v_str)
            if version in spec: valid_versions.append(version)
        except InvalidVersion:
            continue
        except TypeError:
            logger.warning(f"Could not compare version {v_str} against spec {requirement}. Skipping.")

    if valid_versions:
        best_version = min(valid_versions)
        logger.debug(
            f"Requirement '{requirement}' matches installed: {[str(v) for v in valid_versions]}. Best: {best_version}")
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
            major, minor, patch = base_version_tuple
            if major > 0:
                upper_bound_tuple: Tuple[int, int, int] = (major + 1, 0, 0)
            elif minor > 0:
                upper_bound_tuple = (0, minor + 1, 0)
            else:
                upper_bound_tuple = (0, 1, 0)  # Approx <0.1.0 for ^0.0.z

            logger.debug(
                f"Fallback: Handling caret ^ {base_version_str}. Range: >= {base_version_tuple} and < {upper_bound_tuple}")
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


# --- CFG Generation Specific Functions ---

def generate_slither_cfgs(sol_file: Path, solc_executable_path: Path) -> Optional[subprocess.CompletedProcess]:
    """Generate function-level CFGs using Slither. Returns CompletedProcess object on success, None on failure."""
    logger.info(f"Generating function CFGs for '{sol_file.name}' using solc at '{solc_executable_path}'...")
    command = [
        "slither",  # Assumes slither is in PATH
        str(sol_file),
        "--print", "cfg",
        "--solc", str(solc_executable_path)  # Explicitly provide the solc path
    ]
    # Run slither, don't exit script on failure (check=False)
    result = run_command(command, check=False, timeout=300)

    if not result or result.returncode != 0:
        # Error logs handled by run_command or the caller
        logger.error(f"Slither command failed for '{sol_file.name}'.")
        return None  # Failure

    # Log full stderr for debugging even on success exit code
    if result.stderr:
        logger.debug(f"Slither stderr for '{sol_file.name}':\n{result.stderr.strip()}")

    # Check if stderr contains common error indicators even if exit code was 0
    if result.stderr and ("Error:" in result.stderr or "Exception:" in result.stderr):
        logger.error(f"Slither reported errors in stderr for '{sol_file.name}' despite exit code 0.")
        return None  # Treat as failure

    logger.info(f"Slither command finished successfully for '{sol_file.name}'.")
    return result  # Success, return result object


def parse_dot_file(dot_file: Path) -> Tuple[Set[str], List[Tuple[str, str]]]:
    """
    Parse a DOT file and return its nodes and edges.
    Returns: A tuple containing a set of nodes and a list of edge tuples (source, target).
    """
    nodes: Set[str] = set()
    edges: List[Tuple[str, str]] = []
    try:
        with dot_file.open("r", encoding='utf-8', errors='ignore') as f:
            for line in f:
                line = line.strip()
                if "->" in line:
                    # Basic parsing, might need refinement for complex labels/attributes
                    parts = line.split("->")
                    src = parts[0].split('[')[0].strip().strip('"')  # Handle potential attributes on source
                    dst = parts[1].split('[')[0].strip().strip('";')  # Handle potential attributes/semicolon on target
                    if src and dst:  # Ensure non-empty nodes
                        edges.append((src, dst))
                        nodes.update({src, dst})
                elif line and not line.startswith(('graph', 'digraph', '}', '{')) and '[' in line:
                    # Attempt to find node definitions (lines like "NodeA [label=...]")
                    node = line.split('[')[0].strip().strip('"')
                    if node:  # Ensure non-empty node
                        nodes.add(node)
    except Exception as e:
        logger.error(f"Error parsing DOT file {dot_file}: {e}", exc_info=True)
    return nodes, edges


# --- Updated Function ---
def combine_cfgs_and_save(sol_file: Path, output_json_path: Path,
                          slither_result: Optional[subprocess.CompletedProcess]) -> bool:
    """
    Finds *.dot files generated by slither for sol_file, combines them, saves to JSON.
    Returns True on success. Includes check for Slither stderr if no files found.
    """
    logger.info(f"Combining CFGs for '{sol_file.name}'...")
    combined_nodes: Set[str] = set()
    combined_edges: List[Tuple[str, str]] = []

    # --- Define Glob Patterns (Corrected) ---
    # Pattern 1: Next to the source file (Slither's typical behavior)
    # Use the full filename (sol_file) as the base, not just the stem.
    pattern1 = f"{sol_file}-*.dot"
    # Pattern 2: In the current working directory (using filename)
    pattern2 = f"{Path.cwd() / sol_file.name}-*.dot"

    logger.debug(f"Looking for DOT files matching: '{pattern1}'")
    dot_files_pattern1 = glob(pattern1)
    logger.debug(f"Found {len(dot_files_pattern1)} files with pattern 1.")

    # Combine results, avoiding duplicates if CWD is source dir
    all_dot_files_set = set(dot_files_pattern1)
    if Path.cwd() != sol_file.parent:
        logger.debug(f"Looking for DOT files matching: '{pattern2}'")
        dot_files_pattern2 = glob(pattern2)
        logger.debug(f"Found {len(dot_files_pattern2)} files with pattern 2.")
        all_dot_files_set.update(dot_files_pattern2)  # Add files from CWD

    all_dot_files = list(all_dot_files_set)
    logger.debug(f"Processing {len(all_dot_files)} unique DOT files found.")
    # --- End Glob Patterns ---

    # Check if any files were found *before* looping
    if not all_dot_files:
        logger.error(
            f"No DOT files found for '{sol_file.name}' after slither ran (checked source dir and CWD). Cannot generate combined CFG.")
        # Log Slither's stderr if available, as it might contain clues
        if slither_result and slither_result.stderr:
            logger.error(
                f"Slither stderr for {sol_file.name} (which might provide clues):\n{slither_result.stderr.strip()}")
        elif slither_result:
            logger.error(f"Slither stderr was empty for {sol_file.name}.")
        else:
            logger.error(f"Slither result object was not available for {sol_file.name}.")
        return False

    # Loop through found files
    for dotfile_str in all_dot_files:
        dot_path = Path(dotfile_str)
        logger.debug(f"Parsing DOT file: {dot_path.name}")
        fn_nodes, fn_edges = parse_dot_file(dot_path)
        combined_nodes.update(fn_nodes)
        combined_edges.extend(fn_edges)
        # Clean up individual dot file after processing
        try:
            dot_path.unlink()
            logger.debug(f"Removed intermediate file: {dot_path.name}")
        except OSError as e:
            logger.warning(f"Failed to remove intermediate file {dot_path}: {e}")

    # Prepare final JSON structure
    output_cfg = {
        "nodes": sorted(list(combined_nodes)),  # Sort for consistent output
        "edges": [{"source": src, "target": dst} for src, dst in combined_edges]
    }

    # Save the combined CFG
    logger.info(f"Saving combined CFG to '{output_json_path}'...")
    try:
        output_json_path.parent.mkdir(parents=True, exist_ok=True)  # Ensure dir exists
        with output_json_path.open("w", encoding='utf-8') as f:
            json.dump(output_cfg, f, indent=2)
        logger.info(f"Combined CFG saved successfully.")
        return True
    except Exception as e:
        logger.error(f"Error saving combined CFG JSON to {output_json_path}: {e}", exc_info=True)
        return False


# --- End Updated Function ---

# --- Main Orchestration Function per File ---

def generate_cfg_for_file(
        file_path: Path,
        output_dir_base: Path,
        input_dir_base: Path,
        args: argparse.Namespace,
        installed_versions: Set[str],
        attempted_installs: Set[str],
        version_cache: Dict[str, Optional[str]]
) -> bool:
    """
    Orchestrates version selection, installation, slither execution, retry,
    and CFG combination/saving for a single Solidity file.
    Returns True if CFG was successfully generated and saved, False otherwise.
    """
    # --- Determine Initial Version ---
    initial_target_version = determine_target_version(
        file_path, args, installed_versions, version_cache
    )

    # --- Ensure Initial Version Installed ---
    if not ensure_solc_version_installed(
            initial_target_version, installed_versions, attempted_installs
    ):
        logger.warning(
            f"Skipping '{file_path.relative_to(input_dir_base)}': Cannot ensure initial solc version {initial_target_version} is installed.")
        return False  # Indicate skip/failure for counter

    # --- Get Solc Executable Path ---
    solc_executable: Optional[Path] = None
    try:
        install_folder = solcx.get_solcx_install_folder()
        executable_name = f"solc-v{initial_target_version}"
        solc_executable = Path(install_folder) / executable_name
        if not solc_executable.is_file():
            logger.error(f"Solc executable path not found for version {initial_target_version}: {solc_executable}")
            return False
    except Exception as e:
        logger.error(f"Error determining solc executable path for version {initial_target_version}: {e}")
        return False

    # --- Processing Attempts ---
    slither_success = False
    slither_result: Optional[subprocess.CompletedProcess] = None  # Store result for potential stderr logging

    # First Attempt with initial version
    logger.debug(f"Attempt 1: Generating CFG for '{file_path.name}' with version {initial_target_version}")
    slither_result = generate_slither_cfgs(file_path, solc_executable)
    slither_success = slither_result is not None

    if not slither_success and not args.single:
        logger.info(
            f"Attempt 1 (Slither) failed for '{file_path.relative_to(input_dir_base)}' with {initial_target_version}.")

    # Retry Logic
    if not slither_success and not args.single:
        logger.info(f"Attempting retry with next patch version...")
        next_target_version = increment_patch_version(initial_target_version)

        if next_target_version:
            logger.debug(f"Calculated next version: {next_target_version}")
            # Ensure next version installed
            if ensure_solc_version_installed(next_target_version, installed_versions, attempted_installs):
                # Get executable path for next version
                try:
                    install_folder = solcx.get_solcx_install_folder()
                    executable_name = f"solc-v{next_target_version}"
                    next_solc_executable = Path(install_folder) / executable_name
                    if not next_solc_executable.is_file():
                        logger.error(
                            f"Solc executable path not found for retry version {next_target_version}: {next_solc_executable}")
                        # Cannot retry if executable not found
                    else:
                        # --- Second Slither Attempt ---
                        logger.info(
                            f"--> Attempt 2: Generating CFG for '{file_path.relative_to(input_dir_base)}' with version {next_target_version}")
                        next_slither_result = generate_slither_cfgs(file_path, next_solc_executable)
                        slither_success = next_slither_result is not None  # Update success flag
                        if slither_success:
                            slither_result = next_slither_result  # Store successful result
                        else:
                            logger.warning(
                                f"Attempt 2 (Slither) failed for '{file_path.relative_to(input_dir_base)}' with version {next_target_version}.")
                        # --- End Second Slither Attempt ---
                except Exception as e:
                    logger.error(f"Error determining solc executable path for retry version {next_target_version}: {e}")
            else:
                logger.warning(
                    f"Skipping retry for '{file_path.relative_to(input_dir_base)}': Cannot ensure next solc version {next_target_version} is installed.")
        else:
            logger.warning(f"Could not calculate next patch version for {initial_target_version}. Cannot retry.")
    # End Retry Logic

    # --- Combine and Save if Slither Succeeded ---
    if slither_success:
        # Determine final output path
        relative_path = file_path.relative_to(input_dir_base)
        # Save JSON directly in the base output directory, named after the sol file
        output_json_path = (output_dir_base / relative_path).with_suffix('.json')

        # Pass the slither result object in case stderr needs logging if combine fails
        if combine_cfgs_and_save(file_path, output_json_path, slither_result):
            return True  # Overall success for this file
        else:
            # Error logged within combine_cfgs_and_save
            return False  # Failed during combination/save
    else:
        # Slither failed on both attempts (or only one attempt in single mode)
        logger.error(f"Slither execution failed for '{file_path.name}'. No CFG generated.")
        # Clean up any potentially leftover DOT files from failed runs
        dot_pattern = f"{file_path.parent / file_path.stem}-*.dot"  # Use stem here for cleanup pattern
        dot_pattern_alt = f"{file_path}-*.dot"  # Use full name for cleanup pattern too
        logger.debug(f"Cleaning up potential dot files: {dot_pattern} and {dot_pattern_alt}")
        for dotfile in glob(dot_pattern) + glob(dot_pattern_alt):
            try:
                Path(dotfile).unlink()
            except OSError:
                pass
        return False  # Indicate overall failure for this file


# --- Main Execution ---

def main():
    parser = argparse.ArgumentParser(
        description="Generate combined function-level CFGs from Solidity files using Slither and py-solc-x.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument("-i", "--input", type=Path, default="dataset/handcrafted-raw", help="Input directory.")
    parser.add_argument("-o", "--output", type=Path, default="logs/cfg",
                        help="Base output directory for combined CFG JSONs.")  # Changed default
    parser.add_argument("-v", "--version", default=DEFAULT_SOLC_VERSION, help="Solc version for --single or fallback.")
    parser.add_argument("-s", "--single", action="store_true", help="Use only the --version specified.")
    parser.add_argument("--debug", action="store_true", help="Enable debug logging.")
    args = parser.parse_args()

    # --- CONFIGURE LOGGING HERE ---
    log_level = logging.DEBUG if args.debug else logging.INFO
    log_handlers: list[logging.Handler] = []
    log_format = '%(levelname)s: %(message)s'  # Default format for standard logging

    if RICH_AVAILABLE:
        log_handlers.append(RichHandler(rich_tracebacks=True, show_path=False, log_time_format="[%X]"))
        log_format = "%(message)s"  # Rich handles the rest
        logger_name = "rich"
    else:
        logger_name = __name__

    logging.basicConfig(level=log_level, format=log_format, datefmt="[%X]",
                        handlers=log_handlers if log_handlers else None)
    logger = logging.getLogger(logger_name)
    logger.setLevel(log_level)

    # Log warnings for missing optional dependencies after logging is configured
    if not args.single and not PACKAGING_AVAILABLE:
        logger.warning(
            "Warning: 'packaging' library not found ('pip install packaging'). Complex pragma resolution disabled.")
    if not RICH_AVAILABLE:
        logger.warning("Warning: 'rich' library not found ('pip install rich'). Falling back to standard logging.")
    # --- END LOGGING CONFIGURATION ---

    # --- Mandatory Dependency Checks ---
    if not SOLCX_AVAILABLE:
        logger.critical("CRITICAL: py-solc-x is required but not found. Please install it ('pip install py-solc-x').")
        sys.exit(1)
    if not shutil.which("slither"):
        logger.critical(
            "CRITICAL: slither command not found. Please install Slither (https://github.com/crytic/slither#installation).")
        sys.exit(1)
    # --- End Dependency Checks ---

    input_dir: Path = args.input.resolve()
    output_dir_base: Path = args.output.resolve()  # Combined CFGs go directly here

    if not input_dir.is_dir(): logger.error(f"Input directory '{input_dir}' not found."); sys.exit(1)
    try:
        output_dir_base.mkdir(parents=True, exist_ok=True)  # Ensure base output dir exists
    except OSError as e:
        logger.error(f"Cannot create output directory '{output_dir_base}': {e}"); sys.exit(1)

    logger.info(f"Input directory: {input_dir}")
    logger.info(f"CFG output directory: {output_dir_base}")

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
        # Use parent.name for slightly shorter logging if path is deep
        log_file_name = f"{file_path.parent.name}/{file_path.name}" if file_path.parent != input_dir else file_path.name
        logger.info(f"--- Processing file: {log_file_name} ---")
        # Orchestrate the whole process for one file
        if generate_cfg_for_file(
                file_path, output_dir_base, input_dir, args,
                installed_versions, attempted_installs, version_cache
        ):
            success_count += 1
        else:
            # Check if it was skipped vs errored (install check happens first)
            # Re-determine target version to check if it's installed/attempted
            target_v = determine_target_version(file_path, args, installed_versions, version_cache)
            # Check if the *reason* for failure might be install-related
            # A bit heuristic: if the target version isn't installed AND wasn't even attempted (or failed attempt), count as skipped.
            if not (target_v in installed_versions or target_v in attempted_installs):
                skipped_count += 1  # Failed because install failed/skipped early
            else:
                error_count += 1  # Failed during slither or combine/save

    # --- Summary ---
    logger.info("-" * 60)
    logger.info("Processing Summary:")
    logger.info(f"  Total files found:      {len(sol_files)}")
    logger.info(f"  Successfully generated: {success_count}")
    logger.info(f"  Skipped (version issue):{skipped_count}")
    logger.info(f"  Errors (slither/other): {error_count}")
    logger.info(f"  CFGs saved in:          {output_dir_base}")
    logger.info("-" * 60)


if __name__ == "__main__":
    main()
