#!/bin/bash

SOLC_DIR="${HOME}/.solc-select/artifacts/"

# Check input argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <folder-path>"
    exit 1
fi

DIRECTORY="$1"

# Check if the provided path is a directory
if [ ! -d "$DIRECTORY" ]; then
    echo "Error: directory '$DIRECTORY' does not exist."
    exit 1
fi

# Compilation flags (adjust as needed)
COMPILATION_FLAGS="--bin-runtime"

# Function to extract the Solidity version from the pragma statement
extract_solidity_version() {
    local file="$1"
    local version

    version=$(grep -oP 'pragma solidity\s+\^?\s*\K[0-9]+\.[0-9]+\.[0-9]+' "$file" | head -n 1)
    echo "$version"
}

out_dir="$DIRECTORY"/hex
mkdir -p "$out_dir"

# Loop through all .sol files in the given directory (non-recursive)
for file in "$DIRECTORY"/*.sol; do
    if [ ! -e "$file" ]; then
        echo "No .sol files found in the directory."
        exit 0
    fi

    echo "📄 Processing: $file"

    version=$(extract_solidity_version "$file")

    if [ -z "$version" ]; then
        echo "⚠️  No Solidity version found in file: $file"
        continue
    fi

    echo "🔧 Switching to solc version $version"

    # Install and use the correct solc version (if not already installed)
    solc-select install "$version" 2>/dev/null
    solc-select use "$version"

    SOLC_PATH="${SOLC_DIR}/solc-${version}/solc-${version}"

    if [ ! -x "$SOLC_PATH" ]; then
        echo "❌ solc binary for version $version not found or not executable at $SOLC_PATH"
        continue
    fi

    echo "🚀 Compiling with $SOLC_PATH"

    # Compile the Solidity file
    out_file=`basename ${file%.*}`
    "$SOLC_PATH" $COMPILATION_FLAGS "$file" --output-dir $out_dir/$out_file

    if [ $? -eq 0 ]; then
        echo "✅ Successfully compiled $file"
    else
        echo "❌ Compilation failed for $file"
    fi

    for bfile in $out_dir/$out_file/*.bin-runtime; do
        name=${bfile%.*}
        mv $bfile $name.hex
    done

    echo "" 
done
