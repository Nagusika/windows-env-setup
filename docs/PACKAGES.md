# Package Reference Guide

The default install is deliberately lean — a usable Linux-like dev environment, not a
kitchen sink. Policy-risky tools live in the opt-in **Advanced** tier (see
[SECURITY.md](../SECURITY.md)). The source of truth is
[manifests/packages.json](../manifests/packages.json).

## Categories

| Category | Tier | Tools |
|----------|------|-------|
| **Shell & Terminal** | default | PowerShell 7, Windows Terminal, PowerToys, VSCodium, 7-Zip |
| **CLI Toolbox** | default | ripgrep, fd, fzf, bat, jq, eza, zoxide, fnm, Starship |
| **Development** | default | Python, Go, Rust, Node.js |
| **Security / Passwords** | default | KeePassXC, Bitwarden |
| **Package Managers** | default | Scoop |
| **Advanced ⚠️** | opt-in | Wireshark, Nmap, Process Hacker, RustDesk, Rufus, Ventoy, VeraCrypt, SSHFS-Win, WinFsp |

> Git and GitHub CLI are installed by their own scripts, not the package manifest.

## Quick command reference

### CLI toolbox
```powershell
rg "search term" --type ps1     # ripgrep - fast text search
fd "filename"                   # fd - fast file finder
ls | fzf                        # fzf - fuzzy finder
bat file.ps1                    # bat - cat with syntax highlighting
cat data.json | jq '.field'     # jq - JSON processor
eza --long --git --icons        # eza - modern ls
z project                       # zoxide - smart cd
```

### Development
```powershell
python --version
go version
rustc --version ; cargo --version
node --version ; npm --version
fnm install 20 ; fnm use 20     # fnm - Node version manager
```

## Recommended PowerShell profile

Add to `$PROFILE` after installing the CLI toolbox:
```powershell
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-Alias -Name cat -Value bat
Set-Alias -Name ls  -Value eza
fnm env --use-on-cd | Out-String | Invoke-Expression
```

## After installing Git
```powershell
git config --global user.name  "Your Name"
git config --global user.email "your.email@example.com"
git config --global init.defaultBranch main
```

## After installing WSL
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential curl wget git vim htop tree
```

## Managing packages
```powershell
winget list                       # list installed
winget upgrade --all              # update everything
winget uninstall --id <PackageId> # remove one
```

## Resources
- winget: https://github.com/microsoft/winget-cli
- Scoop: https://scoop.sh
- Starship: https://starship.rs
- Modern Unix tools: https://github.com/ibraheemdev/modern-unix
