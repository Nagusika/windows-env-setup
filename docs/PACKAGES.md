# Package Reference Guide

## Quick Command Reference

### CLI Tools

```powershell
# ripgrep - Fast text search
rg "search term" --type ps1

# fd - Fast file finder
fd "filename"

# fzf - Fuzzy finder
ls | fzf

# bat - Cat with syntax highlighting
bat file.ps1

# jq - JSON processor
cat data.json | jq '.field'

# eza - Modern ls replacement
eza --long --git --icons

# zoxide - Smart cd
z project  # jumps to most used directory matching "project"

# Starship - Cross-shell prompt
# Auto-configured after installation
```

### Development Tools

```powershell
# Python
python --version

# Go
go version

# Rust
rustc --version
cargo --version

# Node.js
node --version
npm --version

# fnm - Fast Node Manager
fnm install 20
fnm use 20
```

### Network Tools

```powershell
# Nmap - Network scanner
nmap -sV 192.168.1.1

# iperf3 - Network performance
iperf3 -s  # server
iperf3 -c server_ip  # client

# Wireshark
# GUI tool for packet analysis
```

### Storage & Sync

```powershell
# Rclone - Cloud storage sync
rclone config
rclone sync source: dest:

# Syncthing
# Web UI: http://localhost:8384

# 7-Zip
7z a archive.7z folder/
7z x archive.7z
```

### Backup Tools

```powershell
# restic - Fast, secure backup
restic init --repo /path/to/repo
restic backup /path/to/data
restic restore latest --target /restore/path

# Kopia - Modern backup tool
kopia repository create filesystem --path /path/to/repo
kopia snapshot create /path/to/data
kopia snapshot list

# Duplicati
# Web UI: http://localhost:8200
```

### Security & Privacy

```powershell
# KeePassXC - Password manager
# GUI application

# Bitwarden - Password manager
# GUI application + browser extension

# VeraCrypt - Disk encryption
# GUI application for encrypted volumes
```

## Package Categories Explained

### Base Shell & UX
Essential tools for improving Windows terminal experience and productivity.

### Browsers (FOSS)
Privacy-focused, open-source web browsers without telemetry.

### CLI Toolbox (FOSS)
Modern command-line tools that replace traditional Unix utilities with faster, more user-friendly alternatives.

### Network / Debug / Monitoring
Tools for network analysis, system monitoring, and hardware diagnostics.

### Storage / FS / Sync
File compression, cloud sync, and network filesystem tools.

### Backups (FOSS)
Reliable backup solutions with encryption and deduplication.

### PDF / Images / Notes
Lightweight, open-source tools for document viewing, image editing, and note-taking.

### Media (FOSS)
Media players and audio/video editing tools.

### Remote / P2P
Remote desktop and file sharing applications.

### Security / Privacy / Passwords
Password managers and encryption tools.

### Boot Tools (FOSS)
USB bootable drive creation tools.

### Development Tools
Programming languages, IDEs, and API testing tools.

### Package Managers
Alternative package managers for Windows (Scoop installs to user directory).

## Recommended Configurations

### After Installing CLI Tools

Add to your PowerShell profile (`$PROFILE`):

```powershell
# Starship prompt
Invoke-Expression (&starship init powershell)

# Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Aliases
Set-Alias -Name cat -Value bat
Set-Alias -Name ls -Value eza

# fnm (Node version manager)
fnm env --use-on-cd | Out-String | Invoke-Expression
```

### After Installing Git

```powershell
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
git config --global core.autocrlf true
git config --global init.defaultBranch main
```

### After Installing WSL

```bash
# Inside WSL Ubuntu
sudo apt update && sudo apt upgrade -y

# Install common tools
sudo apt install -y build-essential curl wget git vim htop tree

# Optional: Install Docker in WSL
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

## Useful Resources

- **Winget**: https://github.com/microsoft/winget-cli
- **Scoop**: https://scoop.sh
- **PowerToys**: https://github.com/microsoft/PowerToys
- **Starship**: https://starship.rs
- **Modern Unix Tools**: https://github.com/ibraheemdev/modern-unix

## Uninstalling Packages

```powershell
# List installed packages
winget list

# Uninstall a package
winget uninstall --id PackageId

# Example
winget uninstall --id VideoLAN.VLC
```

## Updating Packages

```powershell
# Update all packages
winget upgrade --all

# Update specific package
winget upgrade --id PackageId

# Check for updates
winget upgrade
```
