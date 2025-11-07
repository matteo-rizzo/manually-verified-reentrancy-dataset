#!/bin/bash

BASE_DIR="failed"
OUTPUT_BASE_DIR="out"
OUTPUT_FAIL_DIR="error"

FALLBACK_SOLC_VERSIONS=("0.4.4" "0.5.17" "0.4.12" "0.4.6" "0.4.22" "0.6.10" "0.7.4" "0.5.3" "0.8.6")
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
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

extract_pragma_version() {
    grep -Eo "^pragma [^;]+( [^;]+)*;" "$1" | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+"
}

check_and_install_solc_version() {
    local version=$1
    if ! solc-select versions | grep -q "$version"; then
        echo "Installing solc version $version..."
        solc-select install "$version" || {
            echo "Error: Failed to install solc version $version"
            return 1
        }
    fi
    return 0
}

get_relative_path() {
    local full_path="$1"
    if command -v realpath &>/dev/null; then
        realpath --relative-to="$BASE_DIR" "$full_path"
    else
        echo "${full_path#$BASE_DIR/}"
    fi
}

copy_to_failed_dir() {
    local sol_file=$1
    local rel_path
    rel_path=$(get_relative_path "$sol_file")
    local fail_output_path="$OUTPUT_FAIL_DIR/$rel_path"
    mkdir -p "$(dirname "$fail_output_path")"
    cp "$sol_file" "$fail_output_path"
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
            echo "⚠️ No pragma found in $sol_file. Attempting fallback versions..."

            for fallback_version in "${FALLBACK_SOLC_VERSIONS[@]}"; do
                echo "⏳ Trying fallback pragma version $fallback_version for $sol_file"

                temp_file=$(mktemp /tmp/sol_fixed_XXXXXX) || {
                    echo "❌ Failed to create temp file"
                    continue
                }

                if grep -qi "SPDX-License-Identifier" "$sol_file"; then
                    awk -v ver="$fallback_version" '
                        BEGIN { inserted = 0 }
                        {
                            print $0
                            if (!inserted && match($0, /SPDX-License-Identifier/)) {
                                print "pragma solidity ^" ver ";"
                                inserted = 1
                            }
                        }
                    ' "$sol_file" > "$temp_file"
                else
                    echo "pragma solidity ^$fallback_version;" > "$temp_file"
                    cat "$sol_file" >> "$temp_file"
                fi

                check_and_install_solc_version "$fallback_version" || continue
                solc-select use "$fallback_version" || continue

                if solc --allow-paths . --overwrite --bin "$temp_file" &> /dev/null; then
                    mkdir -p "$output_dir"
                    cp "$temp_file" "$output_dir/$(basename "$sol_file")"  # Save the modified file with the injected pragma
                    echo "✅ Compiled successfully with injected pragma $fallback_version: $sol_file"
                    rm "$temp_file"
                    return
                else
                    echo "❌ Compilation failed with pragma $fallback_version"
                    rm "$temp_file"
                fi
            done

            echo "❌ All fallback versions failed: $sol_file"
            copy_to_failed_dir "$sol_file"
            return
        fi
    fi

    check_and_install_solc_version "$solc_version" || return
    solc-select use "$solc_version" || return

    temp_file=$(mktemp /tmp/sol_fixed_XXXXXX) || {
        echo "❌ Failed to create temp file"
        copy_to_failed_dir "$sol_file"
        return
    }

    cp "$sol_file" "$temp_file"

    if solc --allow-paths . --overwrite --bin "$temp_file" &> /dev/null; then
        mkdir -p "$output_dir"
        cp "$temp_file" "$output_dir/$(basename "$sol_file")"  # Save the modified file with the pragma
        echo "✅ Compiled successfully with pragma $solc_version: $sol_file"
    else
        echo "❌ Compilation failed: $sol_file"
        copy_to_failed_dir "$sol_file"
    fi

    rm "$temp_file"
}

process_directory() {
    local dir=$1
    local rel_path
    rel_path=$(get_relative_path "$dir")
    local output_dir="$OUTPUT_BASE_DIR/$rel_path"

    echo "📂 Scanning directory: $dir"

    for file in "$dir"/*.sol; do
        [ -f "$file" ] && process_file "$file" "$output_dir"
    done

    for subdir in "$dir"/*; do
        [ -d "$subdir" ] && process_directory "$subdir"
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
process_directory "$BASE_DIR"

if [ "$USE_SINGLE_COMPILER" = false ] && [ -n "$current_version" ]; then
    solc-select use "$current_version"
else
    echo "⚠️ No previous solc version set, skipping reset."
fi

echo "✅ Done! Compilable contracts are in: $OUTPUT_BASE_DIR"
echo "❌ Failed contracts are in: $OUTPUT_FAIL_DIR"
