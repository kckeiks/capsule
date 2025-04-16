#!/bin/bash
set -e

echo "Setting up JetBrains IDE configs (Selective Sync)..."

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JETBRAINS_CONFIG_DIR="$HOME/.config/JetBrains"

declare -A JETBRAINS_PRODUCTS=(
  [goland]="GoLand"
  [rustrover]="RustRover"
)

# Only version control these config folders
SYNC_FOLDERS=(
  "options"
  "keymaps"
  "codestyles"
  "snippets"
  "templates"
)

for ide_key in "${!JETBRAINS_PRODUCTS[@]}"; do
  IDE_NAME="${JETBRAINS_PRODUCTS[$ide_key]}"
  MATCHED_DIR=$(find "$JETBRAINS_CONFIG_DIR" -maxdepth 1 -type d -name "${IDE_NAME}*" | sort -r | head -n 1)

  if [ -z "$MATCHED_DIR" ]; then
    echo "$IDE_NAME not found. Skipping..."
    continue
  fi

  echo "🔍 Found $IDE_NAME config at: $MATCHED_DIR"
  SRC_IDE_DIR="$REPO_DIR/configs/jetbrains/$ide_key"

  for subdir in "${SYNC_FOLDERS[@]}"; do
    SRC_SUBDIR="$SRC_IDE_DIR/$subdir"
    DEST_SUBDIR="$MATCHED_DIR/$subdir"

    if [ ! -d "$SRC_SUBDIR" ]; then
      echo "Missing $subdir in repo for $ide_key. Skipping..."
      continue
    fi

    if [ -e "$DEST_SUBDIR" ] && [ ! -L "$DEST_SUBDIR" ]; then
      echo "Backing up $DEST_SUBDIR → ${DEST_SUBDIR}.backup"
      mv "$DEST_SUBDIR" "${DEST_SUBDIR}.backup"
    fi

    echo "Linking $DEST_SUBDIR → $SRC_SUBDIR"
    ln -sfn "$SRC_SUBDIR" "$DEST_SUBDIR"
  done

  echo "Finished syncing $IDE_NAME configs"
done


