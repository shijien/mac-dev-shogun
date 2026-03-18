<div align="center">

# 🥷 mac-dev-shogun

**Automated macOS developer environment bootstrapper for Apple Silicon**

![Logo](./logo.svg)

[![macOS Apple Silicon](https://img.shields.io/badge/macOS-Apple%20Silicon-black?logo=apple&style=flat-square)](https://github.com/shijien/mac-dev-shogun)
[![Python](https://img.shields.io/badge/Python-3.11-blue?logo=python&style=flat-square)](https://github.com/shijien/mac-dev-shogun)
[![Node.js](https://img.shields.io/badge/Node.js-22.x-green?logo=node.js&style=flat-square)](https://github.com/shijien/mac-dev-shogun)
[![Rust](https://img.shields.io/badge/Rust-stable-orange?logo=rust&style=flat-square)](https://github.com/shijien/mac-dev-shogun)
[![Release](https://img.shields.io/github/v/release/shijien/mac-dev-shogun?style=flat-square)](https://github.com/shijien/mac-dev-shogun/releases)
[![License](https://img.shields.io/github/license/shijien/mac-dev-shogun?style=flat-square)](./LICENSE)

</div>

---

`mac-dev-shogun` is a collection of idempotent shell scripts that bootstrap a macOS machine (M1/M2/M3/M4) into a full AI + Web3 engineering workstation — shell environment, language toolchains, AI/ML stack, crypto tools, and editor config in one shot.

## What gets installed

| Category | Tools |
|---|---|
| **Shell** | zsh · zinit · starship · fzf · ripgrep · JetBrainsMono Nerd Font |
| **AI / ML** | Miniforge (Conda) · Python 3.11 · PyTorch · Transformers · JupyterLab |
| **Web3 / Crypto** | Node.js 22 (fnm) · pnpm · yarn · Rust · Foundry · Solana CLI |
| **Editor** | VS Code + extensions (Python, Jupyter, Rust Analyzer, Solidity, ESLint, Docker) |

---

## Prerequisites

- macOS on Apple Silicon (M1/M2/M3/M4)
- Internet connection
- `git` (pre-installed on macOS, or install via `xcode-select --install`)

---

## Installation

### Option 1 — Homebrew (recommended)

```bash
brew tap shijien/mac-dev-shogun https://github.com/shijien/mac-dev-shogun
brew install mac-dev-shogun
```

Then run each setup step:

```bash
mac-dev-shogun dev       # shell environment
mac-dev-shogun tooling   # AI + crypto toolchains
mac-dev-shogun vscode    # VS Code + extensions
```

### Option 2 — One-liner

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/shijien/mac-dev-shogun/main/install.sh)"
```

Clones the repo to `~/dev/tools/mac-dev-shogun` and runs all three setup scripts in sequence.

---

## Scripts

### `setup_dev_env.sh`

Sets up the shell environment:

- Installs Homebrew (if missing), `git`, `fzf`, `starship`, `ripgrep`
- Clones [zinit](https://github.com/zdharma-continuum/zinit) and configures plugins: autosuggestions, syntax highlighting, fzf-tab, history substring search
- Writes a new `~/.zshrc` (existing file backed up to `~/.zshrc.backup.<timestamp>`)
- Writes `~/.config/starship.toml` with a Node/Python/Rust/Docker-aware prompt
- Downloads and installs JetBrainsMono Nerd Font to `~/Library/Fonts`

```bash
./setup_dev_env.sh
source ~/.zshrc
```

> **Note:** This script overwrites `~/.zshrc`. Your existing config is backed up before any changes are made.

### `setup_ai_crypto_tooling.sh`

Installs language toolchains and development tools:

- **Node.js** — [fnm](https://github.com/Schniz/fnm) + Node 22 LTS + pnpm + yarn
- **Python / AI** — Miniforge (Conda) + `ai` env (Python 3.11, PyTorch, Transformers, JupyterLab, scikit-learn)
- **Rust** — rustup stable + cargo-edit, cargo-watch
- **EVM** — [Foundry](https://github.com/foundry-rs/foundry) (forge, cast, anvil)
- **Solana** — [Solana CLI](https://docs.solanalabs.com/cli/install) (stable)

```bash
./setup_ai_crypto_tooling.sh
source ~/.zshrc
```

### `setup_vscode.sh`

Installs VS Code (via Homebrew Cask if not present) and the following extensions:

| Extension | Purpose |
|---|---|
| `ms-python.python` + `ms-python.pylance` | Python language support |
| `ms-toolsai.jupyter` | Jupyter notebooks |
| `rust-lang.rust-analyzer` | Rust language support |
| `JuanBlanco.solidity` | Solidity / EVM |
| `dbaeumer.vscode-eslint` + `esbenp.prettier-vscode` | JS/TS linting and formatting |
| `ms-azuretools.vscode-docker` + `ms-vscode-remote.remote-containers` | Docker + DevContainers |
| `enkia.tokyo-night` + `PKief.material-icon-theme` | Theme + icons |

```bash
./setup_vscode.sh
```

> **Note:** The `code` CLI must be available in `PATH`. If VS Code is already installed but `code` is not found, run **Cmd+Shift+P → "Shell Command: Install 'code' command in PATH"** in VS Code, then re-run this script.

---

## Repository structure

```
mac-dev-shogun/
├── install.sh                  # one-liner entry point
├── setup_dev_env.sh            # shell environment setup
├── setup_ai_crypto_tooling.sh  # language toolchains
├── setup_vscode.sh             # editor setup
├── mac-dev-shogun.rb           # Homebrew formula
├── tag_release.sh              # release helper
├── logo.svg
├── LICENSE
└── README.md
```

---

## Post-install verification

```bash
# Shell
starship --version
node -v && pnpm -v

# AI stack
conda run -n ai python -c "import torch; print(torch.__version__)"
jupyter --version

# Crypto / Web3
forge --version
solana --version
cargo --version
```

---

## Updating

### Via Homebrew

```bash
brew upgrade mac-dev-shogun
```

### Manually

```bash
cd ~/dev/tools/mac-dev-shogun
git pull --rebase
./setup_dev_env.sh && ./setup_ai_crypto_tooling.sh && ./setup_vscode.sh
```

---

## Troubleshooting

**Conda base env activates automatically on every new shell**

```bash
conda config --set auto_activate_base false
```

**Starship shows `(base)` even when not in an active conda env**

Add to `~/.config/starship.toml`:

```toml
[conda]
ignore_base = true
```

**VS Code Python interpreter not pointing to the `ai` conda env**

Open the command palette and select **Python: Select Interpreter**, then choose:

```
~/miniforge3/envs/ai/bin/python
```

---

## Releasing a new version

1. Tag and push: `./tag_release.sh vX.Y.Z`
2. Compute the new tarball SHA256: `curl -sL <tarball-url> | shasum -a 256`
3. Update `sha256` in `mac-dev-shogun.rb`
4. Commit and push — users receive the update via `brew upgrade mac-dev-shogun`

---

## License

MIT — see [LICENSE](./LICENSE)
