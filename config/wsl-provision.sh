#!/bin/bash
# First-run provisioning for the WSL Ubuntu dev environment.
# Mirrors the Windows CLI toolbox inside Linux. Safe to re-run (idempotent).
#
# Deployed and executed by scripts/install-wsl.ps1. Expects /tmp/starship.toml
# to optionally exist (the shared Starship config).
set -uo pipefail

echo "==> Updating apt and installing the dev toolbox..."
sudo apt-get update -y || true
sudo apt-get install -y \
    build-essential curl wget git vim htop tree unzip zip \
    ripgrep fd-find bat fzf || true

# eza and zoxide are not in every Ubuntu release; best-effort.
sudo apt-get install -y eza 2>/dev/null || true
if ! command -v zoxide >/dev/null 2>&1; then
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh || true
fi

# Starship prompt (matches the Windows / PowerShell prompt).
if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y || true
fi

# Deploy the shared Starship config if it was provided.
mkdir -p "$HOME/.config"
if [ -f /tmp/starship.toml ]; then
    cp /tmp/starship.toml "$HOME/.config/starship.toml"
fi

# Idempotent ~/.bashrc block (delimited by markers so a re-run never duplicates).
MARK_BEGIN="# >>> windows-env-setup >>>"
BASHRC="$HOME/.bashrc"
if ! grep -qF "$MARK_BEGIN" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" <<'EOF'

# >>> windows-env-setup >>>
# History: dedupe, large, append across sessions.
export HISTCONTROL=ignoreboth
export HISTSIZE=100000
export HISTFILESIZE=200000
shopt -s histappend
# Ubuntu ships fd as 'fdfind' and bat as 'batcat'.
command -v fdfind >/dev/null && alias fd='fdfind'
command -v batcat >/dev/null && alias bat='batcat'
command -v eza    >/dev/null && alias ls='eza --group-directories-first --icons'
# Prompt + smart cd.
command -v starship >/dev/null && eval "$(starship init bash)"
command -v zoxide   >/dev/null && eval "$(zoxide init bash)"
# <<< windows-env-setup <<<
EOF
    echo "==> Added windows-env-setup block to ~/.bashrc"
fi

echo "==> WSL dev environment ready. Open a new shell to load it."
