# Windows Environment Setup

Repository to automate the installation and configuration of Windows development environment.

## Installed Components

- **winget** - Windows Package Manager
- **WSL Ubuntu Latest** - Linux Subsystem for Windows
- **Windows Terminal** - Modern terminal for Windows
- **NerdFonts** - Fonts with icons for Windows and WSL
- **Docker Desktop** - Containerization
- **Git** - Version control system
- **GitHub CLI** - Command-line interface for GitHub

## Usage

### Complete Installation
```powershell
# Run as administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install.ps1
```

### Individual Installation
```powershell
# Install specific component
.\scripts\install-winget.ps1
.\scripts\install-wsl.ps1
.\scripts\install-terminal.ps1
.\scripts\install-nerdfonts.ps1
.\scripts\install-docker.ps1
.\scripts\install-git.ps1
.\scripts\install-github-cli.ps1
```

## Prerequisites

- Windows 10/11
- PowerShell 5.1+ or PowerShell Core 7+
- Administrator rights
- Internet connection

## Structure

```
windows-env-setup/
├── install.ps1              # Main script
├── scripts/                 # Individual installation scripts
│   ├── install-winget.ps1
│   ├── install-wsl.ps1
│   ├── install-terminal.ps1
│   ├── install-nerdfonts.ps1
│   ├── install-docker.ps1
│   ├── install-git.ps1
│   └── install-github-cli.ps1
├── config/                  # Configuration files
│   ├── wsl.conf
│   └── terminal-settings.json
└── logs/                    # Installation logs
```

## Rollback

To uninstall components:
```powershell
.\uninstall.ps1
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

## Notes

- Scripts check for component presence before installation
- Logs are saved in the `logs/` folder
- Restart required after WSL and Docker installation
