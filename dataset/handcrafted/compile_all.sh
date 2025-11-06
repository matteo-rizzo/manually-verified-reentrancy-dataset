#!/bin/bash

BASE_DIR="${1:-.}"

rm -rf bins

find "$BASE_DIR" -type f -name "*.sol" | while read -r file; do
    echo "Compilazione di: $file"
    #solcjs "$file" --bin -o bins   
    solc "$file" --bin -o bins/${file%.*}
done

# rename all
find "bins" -type f -name "*.bin" | while read -r file; do
    newfile="${file%.bin}.hex"
    echo "Renaming: $file -> $newfile"
    mv "$file" "$newfile"
done
