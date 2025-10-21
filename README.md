# Windows Environment Setup

Automated installation and configuration script for a complete Windows development environment with **100+ useful FOSS tools**.

## ✨ Features

- 🎯 **Interactive Installation** - Y/N prompts for each component
- 📦 **100+ Packages** - Comprehensive collection of FOSS tools
- 🎨 **Color-coded Feedback** - Clear visual progress indicators
- 🔧 **Flexible** - Choose exactly what you want to install
- 🛡️ **Safe** - All packages from verified sources via winget
- 📝 **Detailed Logging** - Track everything in log files
- 🚀 **Non-destructive** - Won't overwrite existing installations

## 🎯 Core Components

### Essential Tools (with Y/N prompts)
- **winget** - Windows Package Manager (auto-installed if missing)
- **Git** - Version control system
- **GitHub CLI** - Command-line interface for GitHub
- **Windows Terminal** - Modern terminal for Windows
- **NerdFonts** - Fonts with icons (CascadiaCode, FiraCode)

### Window Manager (with Y/N prompts)
- **GlazeWM** - Tiling window manager for Windows
- **Zebar** - Customizable status bar (works with GlazeWM)

### Optional Components
- **WSL2 + Ubuntu** - Linux Subsystem for Windows
- **Docker Desktop** - Containerization platform

### Additional Packages (100+ tools in 12 categories)
- Base Shell & UX (PowerShell 7, PowerToys, VSCodium, Flow Launcher...)
- Browsers (Firefox, LibreWolf)
- CLI Toolbox (ripgrep, fd, fzf, bat, jq, eza, zoxide, Starship...)
- Network/Debug/Monitoring (Wireshark, Nmap, Process Hacker...)
- Storage/Sync (7-Zip, Rclone, Syncthing...)
- Backups (restic, Kopia, Duplicati)
- PDF/Images/Notes (GIMP, Inkscape, Joplin, Obsidian...)
- Media (VLC, mpv.net, Audacity, OBS Studio)
- Remote/P2P (RustDesk, qBittorrent)
- Security/Privacy (KeePassXC, Bitwarden, VeraCrypt)
- Boot Tools (Rufus, Ventoy)
- Development Tools (Python, Go, Rust, Node.js...)

See [PACKAGES.md](PACKAGES.md) for complete list and usage examples.

## 🚀 Quick Start

> **New to this?** Check out the [Quick Start Guide](QUICK_START.md) for step-by-step instructions!

### Complete Installation (Recommended)
```powershell
# Run as administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

The script will prompt you for each component:
```
Install Git? (Y/n): y
Install GitHub CLI? (Y/n): y
Install Windows Terminal? (Y/n): y
Install NerdFonts (CascadiaCode, FiraCode)? (Y/n): y
Install GlazeWM (Tiling Window Manager)? (Y/n): y
Install Zebar (Status Bar for GlazeWM)? (Y/n): y
Install WSL2 with Ubuntu? (Y/n): y
Install Docker Desktop? (y/N): n
Install additional useful packages? (Y/n): y
  Install Base Shell & UX packages? (Y/n): y
  Install CLI Toolbox (FOSS) packages? (Y/n): y
  ...
```

### Individual Installation
```powershell
# Install specific component
.\scripts\install-winget.ps1
.\scripts\install-wsl.ps1
.\scripts\install-terminal.ps1
.\scripts\install-nerdfonts.ps1
.\scripts\install-glazewm.ps1
.\scripts\install-zebar.ps1
.\scripts\install-docker.ps1
.\scripts\install-git.ps1
.\scripts\install-github-cli.ps1
```

## Prerequisites

- Windows 10/11
- PowerShell 5.1+ or PowerShell Core 7+
- Administrator rights
- Internet connection

## 📁 Project Structure

```
windows-env-setup/
├── install.ps1              # Main interactive installation script
├── scripts/                 # Individual installation scripts
│   ├── install-winget.ps1
│   ├── install-wsl.ps1
│   ├── install-terminal.ps1
│   ├── install-nerdfonts.ps1
│   ├── install-glazewm.ps1
│   ├── install-zebar.ps1
│   ├── install-docker.ps1
│   ├── install-git.ps1
│   └── install-github-cli.ps1
├── config/                  # Configuration files
│   ├── wsl.conf
│   ├── terminal-settings.json
│   ├── glazewm-config.yaml
│   ├── zebar-with-glazewm.html
│   └── styles_gruvbox.css
├── logs/                    # Installation logs
├── IMPROVEMENTS.md          # Detailed changelog
├── PACKAGES.md              # Package reference guide
└── SUMMARY.md               # Quick overview
```

## 📚 Documentation

- **[docs/README.md](docs/README.md)** ⭐ - Documentation index
- **[docs/QUICK_START.md](docs/QUICK_START.md)** - 5-minute setup guide for beginners
- **[docs/GLAZEWM_ZEBAR_GUIDE.md](docs/GLAZEWM_ZEBAR_GUIDE.md)** ⭐ - Complete guide for GlazeWM + Zebar
- **[docs/PACKAGES.md](docs/PACKAGES.md)** - Complete package list with command examples
- **[docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)** - Project structure overview

## 🔄 Rollback

To uninstall components:
```powershell
.\uninstall.ps1
```

Or use winget:
```powershell
# List installed packages
winget list

# Uninstall specific package
winget uninstall --id PackageId
```

## Development

This project uses `pre-commit` to enforce code quality and consistency. To set up your local environment, follow these steps:

1.  **Install pre-commit**:

    If you have Python installed, you can install `pre-commit` using pip:
    ```bash
    pip install pre-commit
    ```

2.  **Install PSScriptAnalyzer**:

    The PowerShell hook requires the `PSScriptAnalyzer` module. Open a PowerShell terminal as an administrator and run:
    ```powershell
    Install-Module -Name PSScriptAnalyzer -Force -SkipPublisherCheck
    ```

3.  **Install the Git Hooks**:

    In the root of the repository, run:
    ```bash
    pre-commit install
    ```

Now, `pre-commit` will run automatically on every `git commit`.

## 📝 Notes

- ✅ Scripts check for component presence before installation
- ✅ Non-blocking errors - one failure won't stop the entire process
- ✅ Logs are saved in the `logs/` folder with timestamps
- ✅ Color-coded output for easy progress tracking
- ⚠️ Restart required after WSL and Docker installation
- ⚠️ Some installations may take several minutes
- 💾 Full installation requires ~5-10 GB disk space

## 🎯 Recommended Setups

### Minimal Developer Setup
```
✓ Git
✓ Windows Terminal
✓ NerdFonts
✓ CLI Toolbox (ripgrep, fd, fzf, bat, jq)
```

### Tiling Window Manager Setup
```
✓ All core tools
✓ GlazeWM (Tiling Window Manager)
✓ Zebar (Status Bar)
✓ Windows Terminal
✓ NerdFonts
```

### Full Developer Setup
```
✓ All core tools
✓ GlazeWM + Zebar
✓ WSL2 + Ubuntu
✓ Docker Desktop
✓ CLI Toolbox
✓ Development Tools (Python, Go, Rust, Node.js)
✓ Storage/Sync tools
```

### Power User Setup
```
✓ Everything!
```

## 🐛 Troubleshooting

**Installation fails?**
- Check `logs\install.log` for detailed errors
- Ensure you're running as Administrator
- Verify internet connection
- Try individual scripts: `.\scripts\install-<component>.ps1`

**Winget not found?**
- The script auto-installs winget if missing
- Manually update: `winget upgrade --all`

**WSL installation issues?**
- Restart may be required after enabling features
- Run `wsl --status` to check WSL version
- Ensure virtualization is enabled in BIOS

**Package installation fails?**
- Some packages may not be available in your region
- Check package ID: `winget search <package-name>`
- Skip problematic packages and continue

## 🔄 Updates

Keep your packages up to date:
```powershell
# Update all installed packages
winget upgrade --all

# Update specific package
winget upgrade --id PackageId
```

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new packages
- Improve documentation
- Submit pull requests

## 📄 License

This project is open source and available under the MIT License.
