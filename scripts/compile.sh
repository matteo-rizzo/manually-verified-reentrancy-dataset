#!/bin/bash

# Base directory containing subfolders with Solidity contracts
BASE_DIR="dataset/raw/merged-deduplicated/safe"
# Output directory to store only compilable Solidity contracts
OUTPUT_BASE_DIR="logs/compilable_contracts_safe"

DEFAULT_SOLC_VERSION="0.8.6"
USE_SINGLE_COMPILER=false
MIN_SUPPORTED_SOLC_VERSION="0.3.6"

usage() {
    echo "Usage: $0 [-v solc_version] [-s]"
    echo "  -v solc_version   Specify the solc version to use (default: 0.8.6)"
    echo "  -s                Use a single specified compiler for all files"
    exit 1
}

while getopts "v:s" opt; do
    case $opt in
        v) DEFAULT_SOLC_VERSION="$OPTARG" ;;
        s) USE_SINGLE_COMPILER=true ;;
        *) usage ;;
    esac
done

if ! command -v solc &> /dev/null; then
    echo "Error: solc could not be found. Please install it."
    exit 1
fi

if ! command -v solc-select &> /dev/null; then
    echo "Error: solc-select could not be found. Please install it."
    exit 1
fi

version_gte() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n 1)" = "$2" ]
}

extract_pragma_version() {
    grep -Eo "^pragma [^;]+( [^;]+)*;" "$1" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+"
}

check_and_install_solc_version() {
    local version=$1
    if ! solc-select versions | grep -q "$version"; then
        echo "Installing solc version $version..."
        solc-select install "$version"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to install solc version $version"
            return 1
        fi
    fi
    return 0
}

process_file() {
    local sol_file=$1
    local output_dir=$2

    local solc_version="$DEFAULT_SOLC_VERSION"

    if [ "$USE_SINGLE_COMPILER" = false ]; then
        pragma_version=$(extract_pragma_version "$sol_file")
        if [ -n "$pragma_version" ]; then
            if version_gte "$pragma_version" "$MIN_SUPPORTED_SOLC_VERSION"; then
                solc_version="$pragma_version"
            else
                echo "⚠️ Skipping $sol_file: unsupported pragma version $pragma_version"
                return
            fi
        else
            echo "⚠️ Skipping $sol_file: could not extract pragma version"
            return
        fi
    fi

    if [ -z "$solc_version" ]; then
        echo "❌ Error: No solc version resolved for $sol_file"
        return
    fi

    check_and_install_solc_version "$solc_version" || return
    solc-select use "$solc_version" || return

    # Try to compile the contract
    if solc --allow-paths . --overwrite --bin "$sol_file" &> /dev/null; then
        mkdir -p "$output_dir"
        cp "$sol_file" "$output_dir"
        echo "✅ Compiled successfully: $sol_file"
    else
        echo "❌ Compilation failed: $sol_file"
    fi
}

process_directory() {
    local dir=$1
    local output_base=$2

    local rel_path=${dir#"$BASE_DIR"}
    local output_dir="$output_base/$rel_path"

    for file in "$dir"/*.sol; do
        [ -f "$file" ] && process_file "$file" "$output_dir"
    done

    for subdir in "$dir"/*; do
        [ -d "$subdir" ] && process_directory "$subdir" "$output_base"
    done
}

if [ "$USE_SINGLE_COMPILER" = true ]; then
    check_and_install_solc_version "$DEFAULT_SOLC_VERSION"
    solc-select use "$DEFAULT_SOLC_VERSION"
else
    if solc --version &>/dev/null; then
        current_version=$(solc --version | grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
    else
        current_version=""
    fi
fi

echo "🔍 Scanning and compiling contracts..."
process_directory "$BASE_DIR" "$OUTPUT_BASE_DIR"

if [ "$USE_SINGLE_COMPILER" = false ] && [ -n "$current_version" ]; then
    solc-select use "$current_version"
else
    echo "⚠️ No previous solc version set, skipping reset."
fi

echo "✅ Done! Compilable contracts are in: $OUTPUT_BASE_DIR"
