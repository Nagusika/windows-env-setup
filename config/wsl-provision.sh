#!/bin/bash
# First-run provisioning for the WSL Ubuntu dev environment: a fish-like zsh with
# image previews in the shell, plus the modern CLI toolbox. Safe to re-run (idempotent).
#
# Deployed and executed by scripts/install-wsl.ps1, which stages the config files in
# /tmp first: starship.toml, zshrc, zsh_plugins.txt, fzf-preview.sh.
set -uo pipefail

echo "==> Installing the dev toolbox + zsh stack via apt..."
sudo apt-get update -y || true
sudo apt-get install -y \
    build-essential curl wget git vim htop tree unzip zip file \
    zsh ripgrep fd-find bat fzf chafa poppler-utils ffmpegthumbnailer || true

# eza, zoxide, git-delta: not in every Ubuntu release -> best-effort.
sudo apt-get install -y eza      2>/dev/null || true
sudo apt-get install -y git-delta 2>/dev/null || true
if ! command -v zoxide >/dev/null 2>&1; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh || true
fi

# Starship prompt (same as Windows / PowerShell).
command -v starship >/dev/null 2>&1 || curl -sS https://starship.rs/install.sh | sh -s -- -y || true

# Atuin: magical shell history (Ctrl-R), bound in .zshrc with --disable-up-arrow.
command -v atuin >/dev/null 2>&1 || curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || true

# Antidote: fast zsh plugin manager (fzf-tab + autosuggestions + fast-syntax-highlighting).
[ -d "$HOME/.antidote" ] || git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/.antidote" || true

# Yazi: terminal file manager with built-in image previews (via chafa/sixel).
if ! command -v yazi >/dev/null 2>&1; then
    echo "==> Installing yazi (file manager with image preview)..."
    tmp="$(mktemp -d)"
    if wget -qO "$tmp/yazi.zip" https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip; then
        unzip -q "$tmp/yazi.zip" -d "$tmp" || true
        mkdir -p "$HOME/.local/bin"
        find "$tmp" -name yazi -type f -exec cp {} "$HOME/.local/bin/" \; 2>/dev/null || true
        find "$tmp" -name ya   -type f -exec cp {} "$HOME/.local/bin/" \; 2>/dev/null || true
        chmod +x "$HOME/.local/bin/yazi" "$HOME/.local/bin/ya" 2>/dev/null || true
    fi
    rm -rf "$tmp"
fi

echo "==> Deploying shell configuration..."
mkdir -p "$HOME/.config/fzf"
[ -f /tmp/starship.toml ]    && cp /tmp/starship.toml    "$HOME/.config/starship.toml"
[ -f /tmp/zshrc ]            && cp /tmp/zshrc            "$HOME/.zshrc"
[ -f /tmp/zsh_plugins.txt ]  && cp /tmp/zsh_plugins.txt  "$HOME/.zsh_plugins.txt"
[ -f /tmp/fzf-preview.sh ]   && { cp /tmp/fzf-preview.sh "$HOME/.config/fzf/preview.sh"; chmod +x "$HOME/.config/fzf/preview.sh"; }

# Configure git to use delta (pretty diffs) when available.
if command -v delta >/dev/null 2>&1; then
    git config --global core.pager delta
    git config --global interactive.diffFilter 'delta --color-only'
    git config --global delta.navigate true
    git config --global delta.line-numbers true
fi

# Make zsh the default login shell.
if command -v zsh >/dev/null 2>&1 && [ "$SHELL" != "$(command -v zsh)" ]; then
    sudo chsh -s "$(command -v zsh)" "$USER" 2>/dev/null || chsh -s "$(command -v zsh)" 2>/dev/null || true
    echo "==> Default shell set to zsh (effective on next session)."
fi

# Keep a minimal, idempotent bash fallback for anyone still on bash.
MARK_BEGIN="# >>> windows-env-setup >>>"
BASHRC="$HOME/.bashrc"
if ! grep -qF "$MARK_BEGIN" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" <<'EOF'

# >>> windows-env-setup >>>
export HISTCONTROL=ignoreboth
export HISTSIZE=100000
export HISTFILESIZE=200000
shopt -s histappend
command -v fdfind >/dev/null && alias fd='fdfind'
command -v batcat >/dev/null && alias bat='batcat'
command -v eza    >/dev/null && alias ls='eza --group-directories-first --icons'
command -v starship >/dev/null && eval "$(starship init bash)"
command -v zoxide   >/dev/null && eval "$(zoxide init bash)"
# <<< windows-env-setup <<<
EOF
fi

echo "==> Done. Start a new WSL session to drop into the configured zsh."
