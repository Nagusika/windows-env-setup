# Windows Environment Setup

Automated installation and configuration script for a Windows development environment with a **lean, curated set of essential FOSS tools** — built to work on a company-managed laptop without tripping your IT policy.

## ✨ Features

- 🎯 **Interactive Installation** - Y/N prompts for each component
- 📦 **Lean by default** - ~20 essential packages, not a kitchen sink
- 🎨 **Color-coded Feedback** - Clear visual progress indicators
- 🔧 **Flexible** - Choose exactly what you want to install
- 🛡️ **Corporate-safe by default** - Installed from winget's verified sources; policy-risky tools are opt-in only (⚠️ see [SECURITY.md](SECURITY.md))
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

### Additional Packages (a lean set across a few categories)
- Shell & Terminal (PowerShell 7, Windows Terminal, PowerToys, VSCodium, 7-Zip)
- CLI Toolbox (ripgrep, fd, fzf, bat, jq, eza, zoxide, fnm, Starship)
- Development (Python, Go, Rust, Node.js)
- Security / Passwords (KeePassXC, Bitwarden)
- Package Managers (Scoop)
- ⚠️ Advanced — opt-in, may violate IT policy (Wireshark, Nmap, RustDesk, Rufus, Ventoy, VeraCrypt...) — see [SECURITY.md](SECURITY.md)

See [PACKAGES.md](docs/PACKAGES.md) for complete list and usage examples.

## 🐧 Beyond packages: the tweaks that matter

Installing tools is the easy part — these are the configurations you'd otherwise hand-tune:

**WSL, tuned for a work machine**
- **Corporate networking** — `networkingMode=mirrored` + `dnsTunneling` + `autoProxy`, so VPN, `localhost` and the corporate proxy just work inside WSL.
- **Faster & lighter** — `appendWindowsPath=false` (snappier shell start), `autoMemoryReclaim` + `sparseVhd` (no more `vmmem` eating your RAM/disk).
- **Ready to use** — Ubuntu is provisioned with the same CLI toolbox as Windows (ripgrep, fd, bat, fzf, eza, zoxide) and a tuned `~/.bashrc`.

**One coherent look**
- A **Gruvbox** scheme for Windows Terminal (matching the GlazeWM/Zebar desktop) with a Nerd Font by default.
- The **same Starship prompt** in PowerShell and WSL.

**Windows, decluttered (no admin needed)**
- **Dark mode** + a **minimal, left-aligned taskbar**: Windows icon, pinned apps and clock only — search box, Task View, Widgets and Chat hidden.
- File extensions shown, Explorer opens to *This PC*. All HKCU registry tweaks, fully declarative in [config/windows-tweaks.json](config/windows-tweaks.json) — runs standalone without elevation.

Everything is applied idempotently — re-run any time.

## 🚀 Quick Start

> **New to this?** Check out the [Quick Start Guide](docs/QUICK_START.md) for step-by-step instructions!

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
  Install 'Shell & Terminal' packages? (Y/n): y
  Install 'CLI Toolbox (FOSS)' packages? (Y/n): y
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
.\scripts\apply-windows-tweaks.ps1   # dark mode + minimal taskbar (no admin)
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
├── logs/                    # Installation logs (gitignored)
├── docs/                    # Documentation (QUICK_START, PACKAGES, GlazeWM guide)
├── LICENSE                  # MIT License
├── SECURITY.md              # Corporate policy disclaimer + reporting
└── CONTRIBUTING.md          # Development setup
```

## 📚 Documentation

- **[docs/QUICK_START.md](docs/QUICK_START.md)** - 5-minute setup guide for beginners
- **[docs/GLAZEWM_ZEBAR_GUIDE.md](docs/GLAZEWM_ZEBAR_GUIDE.md)** - Complete guide for GlazeWM + Zebar
- **[docs/PACKAGES.md](docs/PACKAGES.md)** - Package list with command examples

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

Contributor setup (pre-commit, PSScriptAnalyzer, commit conventions) lives in
[CONTRIBUTING.md](CONTRIBUTING.md).

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

This project is open source and available under the [MIT License](LICENSE).
