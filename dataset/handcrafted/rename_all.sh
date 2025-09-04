#!/bin/bash

BASE_DIR="${1:-.}"

find "$BASE_DIR" -type f -name "*.bin" | while read -r file; do
    # Rimuove l'estensione .bin
    newfile="${file%.bin}.hex"
    echo "Renaming: $file -> $newfile"
    mv "$file" "$newfile"
done







addr.call("f()");

I(addr).f()