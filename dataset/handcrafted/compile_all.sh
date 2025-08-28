#!/bin/bash

# Directory di partenza (default: directory corrente)
BASE_DIR="${1:-.}"

# Trova tutti i file .sol ricorsivamente e invoca solc
find "$BASE_DIR" -type f -name "*.sol" | while read -r file; do
    echo "Compilazione di: $file"
    solcjs "$file" --bin -o bins   
done

