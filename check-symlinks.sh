#!/bin/bash

# -----------------------------------------------------------------------------
# check-symlinks.sh
#
# Description:
#   Audit JetBrains IDE config folders to verify which ones are symlinked,
#   which ones are regular folders, and which are missing.
#
# Usage:
#   ./check-symlinks.sh         # runs the audit
#   ./check-symlinks.sh -h      # show help
#   ./check-symlinks.sh --help  # show help
#
# This script is safe to run anytime. If a folder is not symlinked and you
# want to fix it, just re-run `setup-jetbrains.sh`.
# -----------------------------------------------------------------------------

# Handle --help or -h flags
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  grep '^#' "$0" | sed 's/^# \{0,1\}//'
  exit 0
fi

echo "Auditing JetBrains config folder symlinks..."

JETBRAINS_CONFIG_DIR="$HOME/.config/JetBrains"
SYNC_FOLDERS=(
  "options"
  "keymaps"
  "codestyles"
  "snippets"
  "templates"
)

declare -A JETBRAINS_PRODUCTS=(
  [goland]="GoLand"
  [rustrover]="RustRover"
)

for ide_key in "${!JETBRAINS_PRODUCTS[@]}"; do
  IDE_NAME="${JETBRAINS_PRODUCTS[$ide_key]}"
  MATCHED_DIR=$(find "$JETBRAINS_CONFIG_DIR" -maxdepth 1 -type d -name "${IDE_NAME}*" | sort -r | head -n 1)

  if [ -z "$MATCHED_DIR" ]; then
    echo "$IDE_NAME not found"
    continue
  fi

  echo "$IDE_NAME at $MATCHED_DIR"

  for subdir in "${SYNC_FOLDERS[@]}"; do
    DEST="$MATCHED_DIR/$subdir"

    if [ -L "$DEST" ]; then
      echo "$subdir → symlink"
    elif [ -d "$DEST" ]; then
      echo "$subdir → regular folder"
    else
      echo "$subdir → not found"
    fi
  done
done

