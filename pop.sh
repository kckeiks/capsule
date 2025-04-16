#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JETBRAINS_SCRIPT="$REPO_DIR/setup-jetbrains.sh"

echo "Checking file permissions for helper scripts..."

# -- Check and fix permissions for known scripts --
declare -a DEP_SCRIPTS=(
  "$JETBRAINS_SCRIPT"
)

for script in "${DEP_SCRIPTS[@]}"; do
  if [ -f "$script" ]; then
    if [ ! -x "$script" ]; then
      echo "Fixing permissions: $script"
      chmod +x "$script"
    fi
  else
    echo "Missing dependency script: $script"
  fi
done

echo "All helper script permissions are OK"
echo "Setting up dotfiles in the home directory..."

# --- Dotfile setup ---
HOME_DOTFILES=(
  ".bashrc"
  ".gitconfig"
)

for file in "${HOME_DOTFILES[@]}"; do
  SRC="$REPO_DIR/configs/home/$file"
  DEST="$HOME/$file"

  if [ -e "$DEST" ] && [ ! -L "$DEST" ]; then
    echo "Backing up $DEST to $DEST.backup"
    mv "$DEST" "$DEST.backup"
  fi

  ln -sf "$SRC" "$DEST"
  echo "Linked $file to $DEST"
done

# --- Run JetBrains config setup ---
if [ -x "$JETBRAINS_SCRIPT" ]; then
  echo "Running JetBrains IDE setup..."
  "$JETBRAINS_SCRIPT"
else
  echo "Skipping JetBrains setup: script not executable"
fi

