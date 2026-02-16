#!/bin/bash

set -euo pipefail

# --- DETECT OS ---
OS="$(uname)"

if [[ "$OS" == "Darwin" ]]; then
    SOURCE_DIR="/Users/hjohnson/Projects/nomo-app/data/raw/NOMO-01"
elif [[ "$OS" == "Linux" ]]; then
    SOURCE_DIR="/srv/shiny-server/nomo/data/raw/NOMO-01"
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# --- DESTINATION RELATIVE TO SOURCE ---
DEST_DIR="${SOURCE_DIR}/2026-02-12_touch"

mkdir -p "$DEST_DIR"

cd "$SOURCE_DIR" || exit 1

# --- STORE FILE LIST IN VARIABLE ---
FILES=$(find . -maxdepth 1 -type f -name "????-??-??_??????Z.txt")

# --- MOVE FILES IF ANY EXIST ---
if [[ -n "$FILES" ]]; then
    mv $FILES "$DEST_DIR"/
fi
