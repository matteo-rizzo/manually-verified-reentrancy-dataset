import json
import logging
import os
import re
import subprocess
from glob import glob

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

# Base directory containing subfolders with Solidity contracts
BASE_DIR = "dataset/raw/src"

# Base output directory for CFGs
OUTPUT_BASE_DIR = "dataset/raw/cfg"


def version_to_tuple(version_str):
    """Convert a version string (e.g., '0.4.9') into a tuple of integers."""
    try:
        return tuple(map(int, version_str.split('.')))
    except Exception as e:
        logger.error(f"Error converting version string '{version_str}' to tuple: {e}")
        return None


def install_required_solc_version(sol_file):
    """
    Parse the Solidity file for its version pragma, install the required solc version,
    and set it (also updating the SOLC_VERSION env variable).
    If the version is less than 0.4.11 (unsupported by py-solc-x), log an error and raise an exception.
    """
    version_pattern = re.compile(
        r"^\s*pragma\s+solidity\s+([^;]+?)\s*;",
        re.IGNORECASE | re.MULTILINE
    )
    # Open the file with errors='replace' to handle non-UTF-8 bytes.
    with open(sol_file, "r", encoding="utf-8", errors="replace") as f:
        content = f.read()
    match = version_pattern.search(content)
    if match:
        # Preserve the original spacing for parsing.
        version_constraint = match.group(1).replace(" ", "")

        # Handle caret (^) syntax: e.g. "^0.5.0" -> "0.5.0"
        if version_constraint.startswith("^"):
            version = version_constraint[1:].strip()
        else:
            # Split into tokens (for cases like ">=0.4.21 <0.6.0")
            tokens = version_constraint.split()
            if len(tokens) > 1:
                # Look for a lower-bound operator (>= or >).
                lower_bound_match = re.search(r">=?\s*([\d]+\.[\d]+\.[\d]+)", version_constraint)
                if lower_bound_match:
                    version = lower_bound_match.group(1)
                else:
                    # Fallback: use the first token and strip any comparison operators.
                    token = tokens[0]
                    version = re.sub(r"^[><=]+", "", token).strip()
            else:
                # Single token: remove any leading operators.
                version = re.sub(r"^[><=^]+", "", version_constraint).strip()

        # Now we have a version string, e.g. "0.4.21"
        vt = version_to_tuple(version)
        if vt is None or vt < (0, 4, 11):
            logger.error(
                f"File {sol_file} requires solc version {version}, which is unsupported by py-solc-x. Skipping file.")
            raise solcx.exceptions.UnsupportedVersionError("py-solc-x does not support solc versions <0.4.11")

        # Check installed versions.
        installed_versions = [str(v) for v in solcx.get_installed_solc_versions()]
        if version not in installed_versions:
            logger.info(f"Installing solc version {version} for {sol_file}...")
            solcx.install_solc(version)
        else:
            logger.info(f"solc version {version} already installed for {sol_file}.")
        solcx.set_solc_version(version)
        os.environ["SOLC_VERSION"] = version
        logger.info(f"Set SOLC_VERSION environment variable to {version}.")
    else:
        logger.warning(f"No Solidity version pragma found in {sol_file}. Using default solc version.")


def generate_function_cfgs(sol_file):
    """Generate function-level CFGs using Slither."""
    try:
        install_required_solc_version(sol_file)
    except solcx.exceptions.UnsupportedVersionError:
        # Skip this file by returning False.
        return False

    logger.info(f"Generating function-level CFGs for {sol_file}...")
    try:
        subprocess.run(["slither", sol_file, "--print", "cfg"], check=True)
    except subprocess.CalledProcessError as e:
        logger.error(f"Error generating CFG for {sol_file}: {e}")
        return False
    return True


def parse_dot_file(dot_file):
    """Parse a DOT file and return its nodes and edges."""
    nodes = set()
    edges = []
    with open(dot_file, "r") as f:
        for line in f:
            if "->" in line:  # Edge
                parts = line.split("->")
                src = parts[0].strip().strip('"')
                dst = parts[1].strip().strip('";')
                edges.append((src, dst))
                nodes.add(src)
                nodes.add(dst)
            elif "[" in line:  # Node
                node = line.split("[")[0].strip().strip('"')
                nodes.add(node)
    return nodes, edges


def combine_cfgs(sol_file):
    """Combine individual function-level CFGs into a single graph."""
    nodes = set()
    edges = []
    for dotfile in glob(f"{sol_file}-*.dot"):
        fn_nodes, fn_edges = parse_dot_file(dotfile)
        nodes.update(fn_nodes)
        edges.extend(fn_edges)
    return {"nodes": list(nodes), "edges": [{"source": src, "target": dst} for src, dst in edges]}


def save_json(cfg, output_file):
    """Save the CFG to a JSON file."""
    with open(output_file, "w") as f:
        json.dump(cfg, f, indent=2)


def generate_combined_cfg(sol_file, output_dir):
    """Generate and save the combined CFG for a Solidity file."""
    filename = os.path.basename(sol_file)
    contract_name = os.path.splitext(filename)[0]
    output_json = os.path.join(output_dir, f"{contract_name}-combined.json")
    os.makedirs(output_dir, exist_ok=True)

    if not generate_function_cfgs(sol_file):
        logger.error(f"Skipping {sol_file} due to compilation errors or unsupported solc version.")
        return

    logger.info(f"Combining CFGs into one graph for {contract_name}...")
    combined_cfg = combine_cfgs(sol_file)
    logger.info(f"Saving combined CFG to {output_json}...")
    save_json(combined_cfg, output_json)
    for dotfile in glob(f"{sol_file}-*.dot"):
        os.remove(dotfile)
    logger.info(f"Combined CFG generated and saved to {output_json}")


def process_directory(base_dir, output_base):
    """Process all Solidity files in the directory recursively."""
    for root, _, files in os.walk(base_dir):
        output_dir = os.path.join(output_base, f"cfg_{os.path.basename(root)}")
        for file in files:
            if file.endswith(".sol"):
                sol_file = os.path.join(root, file)
                logger.info(f"Processing file: {sol_file}")
                generate_combined_cfg(sol_file, output_dir)


if __name__ == "__main__":
    process_directory(BASE_DIR, OUTPUT_BASE_DIR)
    logger.info(f"All contracts processed. Combined CFGs are stored in {OUTPUT_BASE_DIR}")
