#!/usr/bin/env bash
set -e

echo "=== VS Code setup (editor + core extensions) ==="

###############################################################################
# 1. OS & Homebrew checks
###############################################################################
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "❌ This script is intended for macOS only."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "❌ Homebrew not found."
  echo "Please install Homebrew first: https://brew.sh/"
  exit 1
fi

# Make sure brew env is loaded (Apple Silicon)
if [[ -d /opt/homebrew/bin ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

###############################################################################
# 2. Install VS Code (if not already installed)
###############################################################################
if ! ls /Applications | grep -q "Visual Studio Code.app"; then
  echo "➡ Installing Visual Studio Code via Homebrew..."
  brew install --cask visual-studio-code
else
  echo "✅ Visual Studio Code already installed."
fi

###############################################################################
# 3. Check for 'code' CLI
###############################################################################
if ! command -v code >/dev/null 2>&1; then
  cat << 'EOF'

❌ The 'code' CLI tool is not available yet.

To enable it:

1. Open Visual Studio Code:
   - You can run:  open -a "Visual Studio Code"

2. In VS Code:
   - Press: Cmd + Shift + P
   - Type:  Shell Command: Install 'code' command in PATH
   - Hit Enter

3. Close this terminal and reopen it, or run:
   - source ~/.zshrc

Then re-run this script:

   ./setup_vscode.sh

EOF
  exit 1
fi

echo "✅ 'code' CLI is available. Installing core extensions..."

###############################################################################
# 4. Core extensions for AI + Crypto dev
###############################################################################

# Python / AI
code --install-extension ms-python.python            || true
code --install-extension ms-python.vscode-pylance    || true
code --install-extension ms-toolsai.jupyter          || true

# Rust
code --install-extension rust-lang.rust-analyzer     || true

# Solidity / Web3
code --install-extension JuanBlanco.solidity         || true

# JS / TS / formatting
code --install-extension esbenp.prettier-vscode      || true
code --install-extension dbaeumer.vscode-eslint      || true

# Docker / DevContainers
code --install-extension ms-azuretools.vscode-docker || true
code --install-extension ms-vscode-remote.remote-containers || true

# Git / DX
code --install-extension eamodio.gitlens             || true
code --install-extension streetsidesoftware.code-spell-checker || true

# Theme + icons
code --install-extension enkia.tokyo-night           || true
code --install-extension vscode-icons-team.vscode-icons || true

echo
echo "✅ VS Code core extensions installed."

###############################################################################
# 5. Final tips
###############################################################################
cat << 'EOF'

Done! 🎉

Recommended next steps in VS Code:

1. Set your Python interpreter to your 'ai' env:
   - Cmd + Shift + P → "Python: Select Interpreter"
   - Enter:
     /opt/homebrew/Caskroom/miniforge/base/envs/ai/bin/python
   (or your ~/miniforge3/envs/ai/bin/python symlink if you use masking)

2. Pick the theme:
   - Cmd + K, then Cmd + T
   - Choose: "Tokyo Night"

3. Open your dev workspace:
   - cd ~/dev
   - code .

You're ready to vibe-code with AI + crypto tooling ✨

EOF
