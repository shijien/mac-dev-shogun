#!/usr/bin/env bash
set -e

echo "=== macOS AI/Crypto dev shell setup (iTerm2 + zinit + starship) ==="

###############################################################################
# 0. Basic checks
###############################################################################
if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "This script is intended for macOS only."
  exit 1
fi

###############################################################################
# 1. Install Homebrew if missing
###############################################################################
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew already installed. Updating..."
  brew update
fi

# Add brew to PATH for Apple Silicon
if [[ -d /opt/homebrew/bin ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

###############################################################################
# 2. Install core tools
###############################################################################
echo "Installing core CLI tools with Homebrew..."
brew install git fzf starship ripgrep

# Install fzf keybindings
if [ -f "$(brew --prefix)/opt/fzf/install" ]; then
  yes | "$(brew --prefix)/opt/fzf/install" || true
fi

###############################################################################
# 3. Install zinit manually
###############################################################################
echo "Setting up zinit..."
if [ ! -d "$HOME/.zinit/bin" ]; then
  mkdir -p "$HOME/.zinit"
  git clone https://github.com/zdharma-continuum/zinit.git "$HOME/.zinit/bin"
else
  echo "zinit already present, skipping clone."
fi

###############################################################################
# 4. Backup old configs
###############################################################################
timestamp=$(date +%s)

if [ -f "$HOME/.zshrc" ]; then
  echo "Backing up existing ~/.zshrc to ~/.zshrc.backup.$timestamp"
  cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$timestamp"
fi

mkdir -p "$HOME/.config"
if [ -f "$HOME/.config/starship.toml" ]; then
  echo "Backing up existing starship config to ~/.config/starship.toml.backup.$timestamp"
  cp "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.backup.$timestamp"
fi

###############################################################################
# 5. Write new .zshrc (zinit-based, AI + crypto friendly)
###############################################################################
cat > "$HOME/.zshrc" << 'EOF'
# --------------------------------------------------
# Basic environment
# --------------------------------------------------
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Homebrew (Apple Silicon)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# History
HISTSIZE=500000
SAVEHIST=500000
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS

# Quality of life
setopt AUTO_CD
setopt CORRECT
setopt NO_BEEP

# --------------------------------------------------
# Zinit init
# --------------------------------------------------
export ZINIT[HOME_DIR]="$HOME/.zinit"
source "$HOME/.zinit/bin/zinit.zsh"

# --------------------------------------------------
# Zinit plugins
# --------------------------------------------------

# Autosuggestions
zinit light zsh-users/zsh-autosuggestions

# fzf integration
zinit light junegunn/fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# History substring search
zinit light zsh-users/zsh-history-substring-search

# Syntax highlighting (must be late)
zinit wait lucid for \
  zsh-users/zsh-syntax-highlighting

# fzf-tab
zinit light Aloxaf/fzf-tab

# --------------------------------------------------
# Starship prompt
# --------------------------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# --------------------------------------------------
# Language env hooks (optional, won't fail if missing)
# --------------------------------------------------
# Conda / Miniforge
if [ -f "$HOME/miniforge3/etc/profile.d/conda.sh" ]; then
  . "$HOME/miniforge3/etc/profile.d/conda.sh"
fi

# Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# fnm (Node manager)
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi

# Paths
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Foundry (EVM)
if [ -d "$HOME/.foundry/bin" ]; then
  export PATH="$HOME/.foundry/bin:$PATH"
fi

# Solana
if [ -d "$HOME/.local/share/solana/install/active_release/bin" ]; then
  export PATH="$HOME/.local/share/solana/install/active_release/bin:$PATH"
fi

# --------------------------------------------------
# Aliases
# --------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias dev='cd ~/dev'
alias devai='cd ~/dev/ai'
alias devcrypto='cd ~/dev/crypto'

# Git
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gl='git pull'
alias gfl='git log --oneline --graph --decorate --all'

# Python / AI
alias acai="conda activate ai"
alias jlab="acai && jupyter lab"
alias py="python"

# Foundry
alias fbuild="forge build"
alias ftest="forge test"
alias fanvil="anvil"

# Solana
alias sol-dev="solana config set --url https://api.devnet.solana.com"
alias sol-local="solana config set --url http://127.0.0.1:8899"

# Docker
alias d="docker"
alias dc="docker compose"
alias dps="docker ps"

# Edit zshrc quickly
alias ez='${EDITOR:-nano} ~/.zshrc'

# mkcd: make dir & cd
mkcd () { mkdir -p "$1" && cd "$1"; }

# Shell-GPT alias if installed
if command -v sgpt >/dev/null 2>&1; then
  alias ai="sgpt"
fi

# fzf-tab config
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'r:|=*' 'l:|=*'
zstyle ':fzf-tab:*' switch-group '='
EOF

echo "Wrote new ~/.zshrc"

###############################################################################
# 6. Write starship config
###############################################################################
cat > "$HOME/.config/starship.toml" << 'EOF'
add_newline = true

[directory]
truncation_length = 3
truncate_to_repo = true
truncation_symbol = "…/"

[git_branch]
symbol = " "
format = "[$symbol$branch]($style) "
style = "blue"

[git_status]
disabled = false

[nodejs]
# Show Node icon + version without the word 'via'
format = " [$symbol$version]($style) "
symbol = "⬢ "
detect_extensions = ["js", "ts", "mjs", "cjs"]
detect_files = ["package.json", "pnpm-lock.yaml", "yarn.lock", "bun.lockb"]

[python]
symbol = "🐍 "
format = " [$symbol$version]($style) "

[rust]
symbol = "🦀 "

[docker_context]
symbol = "🐳 "

[time]
disabled = false
time_format = "%H:%M"
format = " 🕒 [$time]($style) "
EOF

echo "Wrote ~/.config/starship.toml"

###############################################################################
# 7. Install JetBrainsMono Nerd Font (for proper icons)
###############################################################################
FONT_DIR="$HOME/Library/Fonts"
JETBRAINS_ZIP="/tmp/JetBrainsMonoNerdFont.zip"

echo "Downloading JetBrainsMono Nerd Font..."
curl -L -o "$JETBRAINS_ZIP" \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip

echo "Installing JetBrainsMono Nerd Font into $FONT_DIR..."
mkdir -p "$FONT_DIR"
unzip -oq "$JETBRAINS_ZIP" -d "$FONT_DIR"
rm -f "$JETBRAINS_ZIP"

echo "JetBrainsMono Nerd Font installed."

###############################################################################
# 8. Final message
###############################################################################
echo
echo "============================================================"
echo "Setup complete ✅"
echo
echo "Next steps:"
echo "1) In iTerm2: Preferences → Profiles → Text"
echo "   - Set Font to 'JetBrainsMono Nerd Font'"
echo "   - Enable 'Use a different font for non-ASCII text'"
echo "   - Set Non-ASCII Font also to 'JetBrainsMono Nerd Font'"
echo
echo "2) Restart iTerm2 (⌘+Q then reopen) so fonts + plugins reload."
echo "3) Run: source ~/.zshrc"
echo
echo "Your shell is now: iTerm2 + zinit + starship + Nerd Font,"
echo "tuned for AI + crypto development."
echo "============================================================"
