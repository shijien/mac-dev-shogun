#!/usr/bin/env bash
set -e

echo "=== AI + Crypto dev tooling setup (Node, Conda, Rust, Foundry, Solana) ==="

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is intended for macOS only."
  exit 1
fi

###############################################################################
# 1. Ensure Homebrew
###############################################################################
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Please run: ./setup_dev_env.sh first."
  exit 1
fi

# Apple Silicon brew env
if [[ -d /opt/homebrew/bin ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

###############################################################################
# 2. Create dev folders
###############################################################################
echo "Creating dev folders..."
mkdir -p "$HOME/dev/ai" "$HOME/dev/crypto" "$HOME/dev/tools"

###############################################################################
# 3. Node.js via fnm
###############################################################################
echo "Installing fnm (Node.js version manager)..."
if ! command -v fnm >/dev/null 2>&1; then
  brew install fnm
else
  echo "fnm already installed."
fi

echo "Configuring fnm..."
if ! grep -q "fnm env --use-on-cd" "$HOME/.zshrc"; then
  cat << 'EOF' >> "$HOME/.zshrc"

# fnm (Node.js manager)
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi
EOF
fi

echo "Installing Node.js 22 (LTS-ish) with fnm..."
eval "$(fnm env --use-on-cd)"
fnm install 22
fnm default 22

echo "Node version installed:"
node -v
npm -v

echo "Installing global JS tooling (pnpm, yarn)..."
npm install -g pnpm yarn

###############################################################################
# 4. Miniforge (Conda) + AI environment
###############################################################################
MINI_DIR="$HOME/miniforge3"

if [ ! -d "$MINI_DIR" ]; then
  echo "Installing Miniforge (Conda for Apple Silicon)..."
  ARCH_NAME="arm64"
  URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-${ARCH_NAME}.sh"
  TMP_INSTALLER="/tmp/miniforge.sh"

  curl -L -o "$TMP_INSTALLER" "$URL"
  bash "$TMP_INSTALLER" -b -p "$MINI_DIR"
  rm -f "$TMP_INSTALLER"
else
  echo "Miniforge already installed at $MINI_DIR"
fi

# Initialize conda in this script
# shellcheck source=/dev/null
source "$MINI_DIR/etc/profile.d/conda.sh"

# Add to zshrc if missing
if ! grep -q "miniforge3/etc/profile.d/conda.sh" "$HOME/.zshrc"; then
  cat << 'EOF' >> "$HOME/.zshrc"

# Miniforge / Conda
if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
  . "$HOME/miniforge3/etc/profile.d/conda.sh"
fi
EOF
fi

echo "Creating AI conda env 'ai' with Python 3.11 (if not exists)..."
if ! conda env list | grep -q "^ai "; then
  conda create -n ai python=3.11 -y
else
  echo "Conda env 'ai' already exists."
fi

echo "Installing AI Python stack into 'ai' env..."

# Core Python DS stack
conda run -n ai conda install -y numpy pandas scipy scikit-learn jupyterlab matplotlib

# Deep learning / NLP stack (pip for maximum freshness)
conda run -n ai pip install --upgrade pip
conda run -n ai pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
conda run -n ai pip install "transformers[torch]" datasets accelerate sentencepiece
conda run -n ai pip install ipykernel

# Register kernel
conda run -n ai python -m ipykernel install --user --name ai --display-name "Python (ai)"

# Handy aliases (if not present)
if ! grep -q "alias acai=" "$HOME/.zshrc"; then
  cat << 'EOF' >> "$HOME/.zshrc"

# AI helpers
alias acai="conda activate ai"
alias jlab="acai && jupyter lab"
EOF
fi

###############################################################################
# 5. Rust toolchain
###############################################################################
if ! command -v rustc >/dev/null 2>&1; then
  echo "Installing Rust toolchain..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
  echo "Rust already installed."
fi

if ! grep -q ".cargo/env" "$HOME/.zshrc"; then
  cat << 'EOF' >> "$HOME/.zshrc"

# Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"
EOF
fi

# shellcheck source=/dev/null
source "$HOME/.cargo/env"

echo "Installing useful Rust cargo tools..."
cargo install cargo-edit cargo-watch --quiet || true

###############################################################################
# 6. Foundry (EVM dev)
###############################################################################
if ! command -v forge >/dev/null 2>&1; then
  echo "Installing Foundry (forge, cast, anvil)..."
  curl -L https://foundry.paradigm.xyz | bash
  # foundryup is placed in ~/.foundry/bin
  # shellcheck source=/dev/null
  source "$HOME/.zshrc" 2>/dev/null || true
  "$HOME/.foundry/bin/foundryup"
else
  echo "Foundry already installed. Updating via foundryup..."
  foundryup
fi

if ! grep -q ".foundry/bin" "$HOME/.zshrc"; then
  cat << 'EOF' >> "$HOME/.zshrc"

# Foundry (EVM dev)
if [ -d "$HOME/.foundry/bin" ]; then
  export PATH="$HOME/.foundry/bin:$PATH"
fi
EOF
fi

###############################################################################
# 7. Solana CLI
###############################################################################
if ! command -v solana >/dev/null 2>&1; then
  echo "Installing Solana CLI..."
  sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
else
  echo "Solana CLI already installed."
fi

if ! grep -q "solana/install/active_release/bin" "$HOME/.zshrc"; then
  cat << 'EOF' >> "$HOME/.zshrc"

# Solana CLI
if [ -d "$HOME/.local/share/solana/install/active_release/bin" ]; then
  export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
fi
EOF
fi

# Add Solana helper aliases if missing
if ! grep -q "sol-dev=" "$HOME/.zshrc"; then
  cat << 'EOF' >> "$HOME/.zshrc"

# Solana helpers
alias sol-dev="solana config set --url https://api.devnet.solana.com && solana config get"
alias sol-local="solana config set --url http://127.0.0.1:8899 && solana config get"
EOF
fi

###############################################################################
# 8. Final summary
###############################################################################
echo
echo "============================================================"
echo "AI + Crypto tooling setup complete ✅"
echo
echo "Installed / configured:"
echo "- fnm + Node 22 (with pnpm, yarn)"
echo "- Miniforge (Conda) + 'ai' env with PyTorch, Transformers, Jupyter"
echo "- Rust toolchain + cargo-edit, cargo-watch"
echo "- Foundry (forge, cast, anvil)"
echo "- Solana CLI (+ dev/local aliases)"
echo "- dev folders: ~/dev/ai and ~/dev/crypto"
echo
echo "Now run: source ~/.zshrc"
echo "Then open a new iTerm2 window and test:"
echo "  node -v"
echo "  pnpm -v"
echo "  acai && python -c 'import torch; print(torch.__version__)'"
echo "  forge --version"
echo "  solana --version"
echo "============================================================"
