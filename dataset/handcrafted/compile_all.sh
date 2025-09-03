#!/bin/bash

BASE_DIR="${1:-.}"

rm -rf bins

find "$BASE_DIR" -type f -name "*.sol" | while read -r file; do
    echo "Compilazione di: $file"
    solcjs "$file" --bin -o bins   
    #solc "$file" --bin-runtime -o bins/${file%.*}
done

