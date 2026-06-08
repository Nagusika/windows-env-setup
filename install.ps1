#Requires -Version 5.1
#Requires -RunAsAdministrator

# Main Windows environment installation script. Run from an elevated PowerShell.

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$LogDir = Join-Path $PSScriptRoot 'logs'

# Shared helpers (logging, prompts, honest native-exit handling).
Import-Module (Join-Path $PSScriptRoot 'WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $LogDir 'install.log')

# Function to check prerequisites
function Test-Prerequisites {
    Write-Log "Checking prerequisites..."

    $OSVersion = [System.Environment]::OSVersion.Version
    if ($OSVersion.Major -lt 10) {
        throw "Windows 10 or higher required"
    }

    # PowerShell version and administrator rights are enforced by the #Requires
    # directives at the top of this script, so they fail fast before any side effect.
    Write-Log "Prerequisites validated" "SUCCESS"
}

# Function to install winget
function Install-Winget {
    Write-Log "Checking winget installation..."
    
    try {
        $null = Get-Command winget -ErrorAction Stop
        Write-Log "winget is already installed" "INFO"
        return
    }
    catch {
        Write-Log "winget not found, installing..." "WARN"
    }
    
    try {
        & ".\scripts\install-winget.ps1"
        Write-Log "winget installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing winget: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to install WSL
function Install-WSL {
    if (-not (Confirm-Action "Install WSL2 with Ubuntu?" $true)) {
        Write-Log "WSL installation skipped by user" "SKIP"
        return
    }
    
    Write-Log "Installing WSL Ubuntu..."
    try {
        & ".\scripts\install-wsl.ps1"
        Write-Log "WSL Ubuntu installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing WSL: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-wsl.ps1" "INFO"
    }
}

# Function to install Windows Terminal
function Install-Terminal {
    if (-not (Confirm-Action "Install Windows Terminal?" $true)) {
        Write-Log "Windows Terminal installation skipped by user" "SKIP"
        return
    }
    
    Write-Log "Installing Windows Terminal..."
    try {
        & ".\scripts\install-terminal.ps1"
        Write-Log "Windows Terminal installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Windows Terminal: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-terminal.ps1" "INFO"
    }
}

# Function to install NerdFonts
function Install-NerdFonts {
    if (-not (Confirm-Action "Install NerdFonts (CascadiaCode, FiraCode)?" $true)) {
        Write-Log "NerdFonts installation skipped by user" "SKIP"
        return
    }
    
    Write-Log "Installing NerdFonts..."
    try {
        & ".\scripts\install-nerdfonts.ps1"
        Write-Log "NerdFonts installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing NerdFonts: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-nerdfonts.ps1" "INFO"
    }
}

# Function to install Git
function Install-Git {
    if (-not (Confirm-Action "Install Git?" $true)) {
        Write-Log "Git installation skipped by user" "SKIP"
        return
    }

    Write-Log "Installing Git..."
    try {
        & ".\scripts\install-git.ps1"
        Write-Log "Git installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Git: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-git.ps1" "INFO"
    }
}

# Function to install GitHub CLI
function Install-GitHubCli {
    if (-not (Confirm-Action "Install GitHub CLI?" $true)) {
        Write-Log "GitHub CLI installation skipped by user" "SKIP"
        return
    }

    Write-Log "Installing GitHub CLI..."
    try {
        & ".\scripts\install-github-cli.ps1"
        Write-Log "GitHub CLI installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing GitHub CLI: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-github-cli.ps1" "INFO"
    }
}

# Function to install GlazeWM
function Install-GlazeWM {
    if (-not (Confirm-Action "Install GlazeWM (Tiling Window Manager)?" $true)) {
        Write-Log "GlazeWM installation skipped by user" "SKIP"
        return
    }

    Write-Log "Installing GlazeWM..."
    try {
        & ".\scripts\install-glazewm.ps1"
        Write-Log "GlazeWM installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing GlazeWM: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-glazewm.ps1" "INFO"
    }
}

# Function to install Zebar
function Install-Zebar {
    if (-not (Confirm-Action "Install Zebar (Status Bar for GlazeWM)?" $true)) {
        Write-Log "Zebar installation skipped by user" "SKIP"
        return
    }

    Write-Log "Installing Zebar..."
    try {
        & ".\scripts\install-zebar.ps1"
        Write-Log "Zebar installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Zebar: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-zebar.ps1" "INFO"
    }
}

# Function to install Docker
function Install-Docker {
    if (-not (Confirm-Action "Install Docker Desktop?" $false)) {
        Write-Log "Docker installation skipped by user" "SKIP"
        return
    }
    
    Write-Log "Installing Docker Desktop..."
    try {
        & ".\scripts\install-docker.ps1"
        Write-Log "Docker Desktop installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Docker: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-docker.ps1" "INFO"
    }
}

# Function to install useful packages via winget
function Install-WingetPackages {
    if (-not (Confirm-Action "Install additional useful packages (CLI tools, browsers, utilities)?" $true)) {
        Write-Log "Additional packages installation skipped by user" "SKIP"
        return
    }

    $ManifestPath = Join-Path $PSScriptRoot 'manifests\packages.json'
    if (-not (Test-Path $ManifestPath)) {
        Write-Log "Package manifest not found: $ManifestPath" "ERROR"
        return
    }

    Write-Log "Installing additional packages from manifest..."
    $Manifest = Get-Content -Path $ManifestPath -Raw | ConvertFrom-Json

    foreach ($Category in $Manifest.categories) {
        Write-Host ""
        $IsAdvanced = $Category.tier -eq 'advanced'

        if ($IsAdvanced) {
            Write-Host "  ----------------------------------------------------------------" -ForegroundColor Yellow
            Write-Host "  ADVANCED TOOLS - may violate your employer's IT/security policy"   -ForegroundColor Yellow
            Write-Host "  Network sniffers, remote access, bootable-media and encryption"     -ForegroundColor Yellow
            Write-Host "  tools can trigger EDR/DLP alerts. See SECURITY.md. You install"      -ForegroundColor Yellow
            Write-Host "  these at your own responsibility."                                   -ForegroundColor Yellow
            Write-Host "  ----------------------------------------------------------------" -ForegroundColor Yellow
        }

        $DefaultYes = -not $IsAdvanced
        if (Confirm-Action "Install '$($Category.name)' packages?" $DefaultYes) {
            foreach ($Package in $Category.packages) {
                [void](Install-WingetPackage -Id $Package.id -Name $Package.name)
            }
        }
        else {
            Write-Log "$($Category.name) packages skipped" "SKIP"
        }
    }

    Write-Log "Additional packages installation completed" "SUCCESS"
}

# Main function
function Main {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Windows Environment Setup Script" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "=== Starting Windows environment installation ==="
    
    try {
        # Check prerequisites
        Test-Prerequisites
        
        # Core installations
        Install-Winget
        Install-Git
        Install-GitHubCli
        Install-Terminal
        Install-NerdFonts
        
        # Window Manager installations
        Install-GlazeWM
        Install-Zebar
        
        # Optional installations
        Install-WSL
        Install-Docker
        
        # Additional packages
        Install-WingetPackages
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Log "=== Installation completed successfully ===" "SUCCESS"
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Log "Some changes may require a system restart to take effect" "INFO"
        Write-Host ""
        
        if (Confirm-Action "Do you want to restart now?" $false) {
            Write-Log "Restarting system..." "INFO"
            Restart-Computer -Force
        }
        else {
            Write-Log "Please restart your system manually when convenient" "INFO"
        }
    }
    catch {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Log "=== Installation encountered errors ===" "ERROR"
        Write-Host "========================================" -ForegroundColor Red
        Write-Log "Error: $($_.Exception.Message)" "ERROR"
        Write-Host ""
        Write-Log "Check the log file at: $LogDir\install.log" "INFO"
        exit 1
    }
}

# Execution
Main
