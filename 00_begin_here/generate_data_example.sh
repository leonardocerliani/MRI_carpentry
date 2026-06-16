#!/usr/bin/env bash

# Simple dataset structure replicator
# -----------------------------------
# This script takes a directory and creates a mirrored version of it
# with the same folder structure but EMPTY files.
#
# Example:
#   ./generate_data_example.sh data
#   → creates data_example/ with identical structure

SRC="$1"

# Check if input directory is provided
if [[ -z "$SRC" ]]; then
  echo "Usage: $0 <source_dir>"
  exit 1
fi

# Output directory is automatically created as "<source>_example"
DST="${SRC%/}_example"

# Create root of output directory
mkdir -p "$DST"

# Recreate directory structure
# (finds all folders and mirrors them under DST)
find "$SRC" -type d | while read -r dir; do
  mkdir -p "$DST/${dir#$SRC/}"
done

# Recreate files as empty placeholders
# (same names, no content copied)
find "$SRC" -type f | while read -r file; do
  touch "$DST/${file#$SRC/}"
done