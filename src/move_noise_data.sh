#!/bin/bash

set -euo pipefail

# --- DETECT OS ---
OS="$(uname)"

if [[ "$OS" == "Darwin" ]]; then
    PROJ_DIR="/Users/hjohnson/Projects/nomo-app/"
elif [[ "$OS" == "Linux" ]]; then
    PROJ_DIR="/srv/shiny-server/nomo/"
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# --- DESTINATION RELATIVE TO SOURCE ---
SOURCE_DIR="${PROJ_DIR}/data/raw/NOMO-01"
DEST_DIR="${SOURCE_DIR}/2026-03-16_bench"

mkdir -p "$DEST_DIR"

cd "$SOURCE_DIR" 

# --- STORE FILE LIST IN VARIABLE ---
FILES=$(find . -maxdepth 1 -type f -name "????-??-??_??????Z.txt")

# --- MOVE FILES IF ANY EXIST ---
if [[ -n "$FILES" ]]; then
    mv $FILES "$DEST_DIR"/
fi

# --- PROCESS NOISE DATA
cd "$PROJ_DIR"
R_FILE="${PROJ_DIR}/r/proc_noise.R"
Rscript "$R_FILE"