#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/shijien/mac-dev-shogun.git"
TARGET_DIR="${HOME}/dev/tools/mac-dev-shogun"

echo "=== mac-dev-shogun one-line installer ==="

# Ensure base dev dir
mkdir -p "$(dirname "$TARGET_DIR")"

if [ -d "$TARGET_DIR/.git" ]; then
  echo "Repo already exists, pulling latest..."
  cd "$TARGET_DIR"
  git pull --rebase
else
  echo "Cloning repo into $TARGET_DIR ..."
  git clone "$REPO_URL" "$TARGET_DIR"
  cd "$TARGET_DIR"
fi

chmod +x setup_dev_env.sh setup_ai_crypto_tooling.sh setup_vscode.sh

echo
echo "Running dev environment setup..."
./setup_dev_env.sh

echo
echo "Reloading shell config..."

echo
echo "Running AI + crypto tooling setup..."
./setup_ai_crypto_tooling.sh

echo
echo "Running VS Code setup..."
./setup_vscode.sh

echo
echo "✅ mac-dev-shogun installed."
echo "Recommended:"
echo "  1) Quit and reopen iTerm2"
echo "  2) Run: source ~/.zshrc"
echo "  3) Test: node -v, conda activate ai, forge --version"
