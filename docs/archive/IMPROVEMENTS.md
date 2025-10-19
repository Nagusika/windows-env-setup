# Installation Script Improvements

## Changes Made

### 1. **Interactive Y/N Prompts**
- Added `Confirm-Action` function for user prompts
- Each component now asks for confirmation before installation
- Default values set appropriately (Y for essential tools, N for Docker)
- Format: `(Y/n)` for default Yes, `(y/N)` for default No

### 2. **Simplified Script Logic**
- Removed complex parameter switches (`-SkipWSL`, `-SkipDocker`, etc.)
- Cleaner flow with interactive prompts
- Better error handling with retry instructions
- Non-blocking errors for optional components

### 3. **Enhanced Logging**
- Color-coded log messages:
  - **Green**: SUCCESS
  - **Red**: ERROR
  - **Yellow**: WARN
  - **Cyan**: SKIP
  - **White**: INFO
- Better visual feedback during installation

### 4. **Comprehensive Package List**
Added extensive winget package categories with FOSS tools:

#### **Base Shell & UX**
- PowerShell 7
- Windows Terminal
- PowerToys
- Flow Launcher
- Notepad++
- VSCodium

#### **Browsers (FOSS)**
- Firefox
- LibreWolf (hardened Firefox)

#### **CLI Toolbox (FOSS)**
- ripgrep (fast grep)
- fd (fast find)
- fzf (fuzzy finder)
- bat (cat with syntax highlighting)
- jq (JSON processor)
- eza (modern ls)
- zoxide (smart cd)
- fnm (Node version manager)
- Starship (cross-shell prompt)

#### **Network / Debug / Monitoring**
- Wireshark
- Nmap
- iperf3
- Process Hacker (advanced Task Manager)
- Libre Hardware Monitor
- Fan Control
- CrystalDiskInfo
- CrystalDiskMark

#### **Storage / FS / Sync**
- 7-Zip
- Rclone
- Syncthing
- WinFsp
- SSHFS-Win

#### **Backups (FOSS)**
- restic
- Kopia
- Duplicati

#### **PDF / Images / Notes**
- Sumatra PDF
- PDFsam
- ImageGlass
- GIMP
- Inkscape
- Joplin
- Obsidian

#### **Media (FOSS)**
- VLC
- mpv.net
- Audacity
- OBS Studio

#### **Remote / P2P**
- RustDesk (open-source TeamViewer alternative)
- qBittorrent

#### **Security / Privacy / Passwords**
- KeePassXC
- Bitwarden
- VeraCrypt

#### **Boot Tools (FOSS)**
- Rufus
- Ventoy

#### **Development Tools**
- Python 3.12
- Go
- Rust
- Node.js
- JetBrains Toolbox
- Postman
- Insomnia

#### **Package Managers**
- Scoop

### 5. **Installation Methods Verified**

All installation methods use **winget** (the official Windows Package Manager):
- ✅ **Reliable**: Official Microsoft tool
- ✅ **Consistent**: Same method for all packages
- ✅ **Maintained**: Packages are kept up-to-date
- ✅ **Safe**: Verified sources with digital signatures

### 6. **Better User Experience**
- Clear section headers with visual separators
- Category-based package installation
- User can choose which categories to install
- Helpful retry instructions on errors
- Summary at the end with restart prompt

## Usage

```powershell
# Run as Administrator
.\install.ps1
```

The script will:
1. Check prerequisites (Windows 10+, PowerShell 5.1+, Admin rights)
2. Install/verify winget
3. Prompt for each component installation
4. Prompt for package categories
5. Display summary and offer restart

## Example Interaction

```
========================================
  Windows Environment Setup Script
========================================

Install Git? (Y/n): y
Install GitHub CLI? (Y/n): y
Install Windows Terminal? (Y/n): y
Install NerdFonts (CascadiaCode, FiraCode)? (Y/n): y
Install WSL2 with Ubuntu? (Y/n): y
Install Docker Desktop? (y/N): n
Install additional useful packages (CLI tools, browsers, utilities)? (Y/n): y

Install Base Shell & UX packages? (Y/n): y
Install Browsers (FOSS) packages? (Y/n): y
Install CLI Toolbox (FOSS) packages? (Y/n): y
...
```

## Notes

- All packages are FOSS (Free and Open Source Software) or free to use
- Installation is non-destructive (won't overwrite existing installations)
- Each category can be installed independently
- Errors in one package won't stop the entire installation
- Logs are saved to `logs\install.log`
