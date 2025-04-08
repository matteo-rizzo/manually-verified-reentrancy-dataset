import json
import logging
import os
import re
import subprocess
from glob import glob
from pathlib import Path
from typing import Optional, Tuple, Set, List, Dict, Any

import solcx
from rich.logging import RichHandler

# Configure rich logging
logging.basicConfig(
    level=logging.INFO,
    format="%(message)s",
    datefmt="[%X]",
    handlers=[RichHandler()]
)
logger = logging.getLogger("rich")

# Directories
INPUT_DIR = Path("dataset/verified/gt_reentrant/safe")
OUTPUT_DIR = Path("logs/verified-safe-cfg")
DEFAULT_SOLC_VERSION = "0.4.24"


def version_to_tuple(version_str: str) -> Optional[Tuple[int, ...]]:
    """Convert a version string (e.g., '0.4.9') into a tuple of integers."""
    try:
        return tuple(map(int, version_str.split('.')))
    except Exception as e:
        logger.error(f"Error converting version string '{version_str}' to tuple: {e}", exc_info=True)
        return None


def install_required_solc_version(sol_file: Path) -> None:
    """
    Parses the Solidity file for its version pragma, installs the required solc version,
    and sets it (updating the SOLC_VERSION environment variable).

    Raises:
        solcx.exceptions.UnsupportedVersionError if the version is below 0.4.11.
    """
    version_pattern = re.compile(
        r"^\s*pragma\s+solidity\s+([^;]+?)\s*;",
        re.IGNORECASE | re.MULTILINE
    )

    try:
        content = sol_file.read_text(encoding="utf-8", errors="replace")
    except Exception as e:
        logger.error(f"Error reading {sol_file}: {e}", exc_info=True)
        raise

    match = version_pattern.search(content)
    if match:
        version_constraint = match.group(1).replace(" ", "")
        # Handle caret syntax: e.g., "^0.5.0" -> "0.5.0"
        if version_constraint.startswith("^"):
            version = version_constraint[1:].strip()
        else:
            tokens = version_constraint.split()
            if len(tokens) > 1:
                lower_bound_match = re.search(r">=?\s*(\d+\.\d+\.\d+)", version_constraint)
                version = lower_bound_match.group(1) if lower_bound_match else re.sub(r"^[><=]+", "", tokens[0]).strip()
            else:
                version = re.sub(r"^[><=^]+", "", version_constraint).strip()

        vt = version_to_tuple(version)
        if vt is None or vt < (0, 4, 11):
            msg = (f"File {sol_file} requires solc version {version}, which is unsupported by py-solc-x. "
                   f"Trying default version {DEFAULT_SOLC_VERSION}.")
            logger.warning(msg)
            version = DEFAULT_SOLC_VERSION

        # Check installed versions and install if necessary.
        installed_versions = {str(v) for v in solcx.get_installed_solc_versions()}
        if version not in installed_versions:
            logger.info(f"Installing solc version {version} for {sol_file}...")
            solcx.install_solc(version)
        else:
            logger.info(f"solc version {version} already installed for {sol_file}.")
    else:
        version = DEFAULT_SOLC_VERSION
        logger.warning(f"No Solidity version pragma found in {sol_file}. Using default solc version.")
        logger.info(f"Installing solc version {version} for {sol_file}...")
        solcx.install_solc(version)

    solcx.set_solc_version(version)
    os.environ["SOLC_VERSION"] = version
    logger.info(f"Set SOLC_VERSION environment variable to {version}.")


def generate_function_cfgs(sol_file: Path) -> bool:
    """Generate function-level CFGs using Slither for the specified Solidity file."""
    try:
        install_required_solc_version(sol_file)
    except Exception as e:
        logger.error(f"Error installing required solc version for {sol_file}: {e}", exc_info=True)
        return False

    logger.info(f"Generating function-level CFGs for {sol_file}...")
    try:
        subprocess.run(
            ["slither", str(sol_file), "--print", "cfg"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
    except subprocess.CalledProcessError as e:
        logger.error(
            f"Error generating CFG for {sol_file}. Return code: {e.returncode}\n"
            f"stdout: {e.stdout}\n"
            f"stderr: {e.stderr}",
            exc_info=True
        )
        return False
    return True


def parse_dot_file(dot_file: Path) -> Tuple[Set[str], List[Tuple[str, str]]]:
    """
    Parse a DOT file and return its nodes and edges.

    Returns:
        A tuple containing a set of nodes and a list of edge tuples (source, target).
    """
    nodes: Set[str] = set()
    edges: List[Tuple[str, str]] = []
    try:
        with dot_file.open("r") as f:
            for line in f:
                if "->" in line:
                    parts = line.split("->")
                    src = parts[0].strip().strip('"')
                    dst = parts[1].strip().strip('";')
                    edges.append((src, dst))
                    nodes.update({src, dst})
                elif "[" in line:
                    node = line.split("[")[0].strip().strip('"')
                    nodes.add(node)
    except Exception as e:
        logger.error(f"Error parsing DOT file {dot_file}: {e}", exc_info=True)
    return nodes, edges


def combine_cfgs(sol_file: Path) -> Dict[str, Any]:
    """
    Combine individual function-level CFGs (DOT files) into a single graph.

    Returns:
        A dictionary with combined nodes and edges.
    """
    nodes: Set[str] = set()
    edges: List[Tuple[str, str]] = []
    for dotfile in glob(f"{sol_file}-*.dot"):
        dot_path = Path(dotfile)
        fn_nodes, fn_edges = parse_dot_file(dot_path)
        nodes.update(fn_nodes)
        edges.extend(fn_edges)
    return {
        "nodes": list(nodes),
        "edges": [{"source": src, "target": dst} for src, dst in edges]
    }


def save_json(cfg: Dict[str, Any], output_file: Path) -> None:
    """Save the CFG to a JSON file."""
    try:
        with output_file.open("w") as f:
            json.dump(cfg, f, indent=2)
    except Exception as e:
        logger.error(f"Error saving JSON to {output_file}: {e}", exc_info=True)


def generate_combined_cfg(sol_file: Path, output_dir: Path) -> None:
    """Generate and save the combined CFG for a Solidity file."""
    contract_name = sol_file.stem
    output_json = output_dir / f"{contract_name}.json"
    output_dir.mkdir(parents=True, exist_ok=True)

    if not generate_function_cfgs(sol_file):
        logger.error(f"Skipping {sol_file} due to compilation errors or unsupported solc version.")
        return

    logger.info(f"Combining CFGs into one graph for {contract_name}...")
    combined_cfg = combine_cfgs(sol_file)
    logger.info(f"Saving combined CFG to {output_json}...")
    save_json(combined_cfg, output_json)

    # Cleanup temporary DOT files.
    for dotfile in glob(f"{sol_file}-*.dot"):
        try:
            Path(dotfile).unlink()
        except Exception as e:
            logger.error(f"Failed to remove {dotfile}: {e}", exc_info=True)
    logger.info(f"Combined CFG generated and saved to {output_json}")


def process_directory(base_dir: Path, output_base: Path) -> None:
    """Recursively process all Solidity files in the directory."""
    for sol_file in base_dir.rglob("*.sol"):
        logger.info(f"Processing file: {sol_file}")
        generate_combined_cfg(sol_file, output_base)


if __name__ == "__main__":
    process_directory(INPUT_DIR, OUTPUT_DIR)
    logger.info(f"All contracts processed. CFGs are stored in {OUTPUT_DIR}")
