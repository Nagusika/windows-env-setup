#!/usr/bin/env bash
# Universal fzf / fzf-tab preview: directories via eza, images via chafa (sixel),
# everything else via bat. Deployed to ~/.config/fzf/preview.sh by wsl-provision.sh.
set -u

target="${1:-}"
[ -z "$target" ] && exit 0

if [ -d "$target" ]; then
    eza -1 --color=always --icons --group-directories-first "$target" 2>/dev/null || ls -1 "$target"
    exit 0
fi

cols="${FZF_PREVIEW_COLUMNS:-80}"
lines="${FZF_PREVIEW_LINES:-25}"

case "$(file --mime-type -bL "$target" 2>/dev/null)" in
    image/*)
        if command -v chafa >/dev/null 2>&1; then
            chafa -f sixel -s "${cols}x${lines}" "$target" 2>/dev/null \
                || chafa -s "${cols}x${lines}" "$target" 2>/dev/null
        else
            file -b "$target"
        fi
        ;;
    *)
        if command -v batcat >/dev/null 2>&1; then
            batcat --style=numbers --color=always --line-range :200 "$target"
        elif command -v bat >/dev/null 2>&1; then
            bat --style=numbers --color=always --line-range :200 "$target"
        else
            head -n 200 "$target"
        fi
        ;;
esac
