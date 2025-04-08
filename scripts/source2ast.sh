#!/bin/bash

: <<'END_COMMENT'
This script processes Solidity files to generate their Abstract Syntax Trees (ASTs) using the Solidity compiler (solc). The script performs the following tasks:

1. Scans a specified base directory for Solidity (.sol) files.
2. Extracts the pragma version specified in each Solidity file to determine the appropriate solc version to use.
3. Checks if the required solc version is installed; if not, installs it.
4. Uses solc to generate the AST for each Solidity file.
5. Saves the generated ASTs to a specified output directory, maintaining the directory structure of the input files.
6. Skips any files that specify a solc version below the minimum supported version (0.3.6).

The script supports an option to use a single specified solc version for all files instead of extracting the pragma version from each file.

Usage:
    ./source2ast.sh [-v solc_version] [-s]

Options:
    -v solc_version   Specify the solc version to use (default: 0.8.6)
    -s                Use a single specified compiler for all files

Dependencies:
    - solc
    - solc-select

END_COMMENT

# Base directory containing subfolders with Solidity contracts
BASE_DIR="dataset/verified/gt_reentrant/safe"

# Base output directory for ASTs
OUTPUT_BASE_DIR="logs/verified-safe-ast"

# Default solc version to use if no pragma is specified or if single compiler mode is selected
DEFAULT_SOLC_VERSION="0.4.22"
USE_SINGLE_COMPILER=false

# Minimum supported solc version
MIN_SUPPORTED_SOLC_VERSION="0.3.6"

# Function to display usage information
usage() {
    echo "Usage: $0 [-v solc_version] [-s]"
    echo "  -v solc_version   Specify the solc version to use (default: 0.8.6)"
    echo "  -s                Use a single specified compiler for all files"
    exit 1
}

# Parse command-line options
while getopts "v:s" opt; do
    case $opt in
        v)
            DEFAULT_SOLC_VERSION="$OPTARG"
            ;;
        s)
            USE_SINGLE_COMPILER=true
            ;;
        *)
            usage
            ;;
    esac
done

# Check if solc is installed
if ! command -v solc &> /dev/null; then
    echo "Error: solc could not be found. Please install it."
    exit 1
fi

# Check if solc-select is installed
if ! command -v solc-select &> /dev/null; then
    echo "Error: solc-select could not be found. Please install it."
    exit 1
fi

# Function to compare version numbers
version_gte() {
    # Compare two version numbers
    # Returns 0 if $1 >= $2, 1 otherwise
    local version1=$1
    local version2=$2
    [ "$(printf '%s\n' "$version1" "$version2" | sort -V | head -n 1)" = "$version2" ]
}

# Function to extract the pragma version from a Solidity file
extract_pragma_version() {
    local sol_file=$1
    grep -Eo "^pragma [^;]+( [^;]+)*;" "$sol_file" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+"
}

# Function to check if a solc version is installed, and install it if not
check_and_install_solc_version() {
    local version=$1
    if ! solc-select versions | grep -q "$version"; then
        echo "solc version $version is not installed. Installing..."
        solc-select install "$version"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install solc version $version. Please install it manually."
        fi
    fi
}

# Function to get the solc AST option based on the version
get_solc_ast_option() {
    local version=$1
    if [[ "$version" < "0.5.0" ]]; then
        echo "--ast-json"
    else
        echo "--ast-compact-json"
    fi
}

# Function to process each Solidity file
process_file() {
    local sol_file=$1
    local output_dir=$2

    local solc_version="$DEFAULT_SOLC_VERSION"

    if [ "$USE_SINGLE_COMPILER" = false ]; then
        # Extract the pragma version from the file, or use the default version
        pragma_version=$(extract_pragma_version "$sol_file")
        if [ -n "$pragma_version" ]; then
            if version_gte "$pragma_version" "$MIN_SUPPORTED_SOLC_VERSION"; then
                solc_version="$pragma_version"
            else
                echo "Skipping $sol_file due to unsupported solc version $pragma_version"
                return
            fi
        fi
    fi

    # Check and install the required solc version if not already installed
    check_and_install_solc_version "$solc_version"

    # Extract filename without extension and prepare output filename
    local filename=$(basename -- "$sol_file")
    local contract_name="${filename%.*}"
    local output_file="$output_dir/$contract_name.json"

    # Compile contract to get AST using the appropriate AST option and process it
    echo "Processing $sol_file with solc version $solc_version..."

    # Run the solc command to get the AST
    ast_content=$(solc-select use "$solc_version" && solc $(get_solc_ast_option "$solc_version") "$sol_file")

    # Save the AST content
    echo "$ast_content" > "$output_file"
    echo "AST saved to $output_file"
}

# Function to process directories recursively
process_directory() {
    local dir=$1
    local output_base=$2

    # Create corresponding output directory with prefix 'ast_'
    local base_name=$(basename -- "$dir")
    local output_dir="$output_base/ast_$base_name"
    mkdir -p "$output_dir"

    # Process each Solidity file in the directory
    for file in "$dir"/*.sol; do
        if [[ -f "$file" ]]; then
            process_file "$file" "$output_dir"
        fi
    done

    # Recurse into subdirectories
    for subdir in "$dir"/*; do
        if [[ -d "$subdir" ]]; then
            process_directory "$subdir" "$output_base/ast_$base_name"
        fi
    done
}

# Main script execution

# If using a single compiler, ensure the specified solc version is installed and set
if [ "$USE_SINGLE_COMPILER" = true ]; then
    check_and_install_solc_version "$DEFAULT_SOLC_VERSION"
    solc-select use "$DEFAULT_SOLC_VERSION"
else
    # Store the current solc version
    current_version=$(solc --version | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
fi

# Start processing from the base directory
process_directory "$BASE_DIR" "$OUTPUT_BASE_DIR"

# Revert to the original solc version if not using a single compiler for all files
if [ "$USE_SINGLE_COMPILER" = false ]; then
    solc-select use "$current_version"
fi

echo "All contracts processed. ASTs are stored in $OUTPUT_BASE_DIR"