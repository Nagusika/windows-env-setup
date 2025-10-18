# Main Windows environment installation script
# Run as administrator

param(
    [switch]$SkipWSL,
    [switch]$SkipDocker,
    [switch]$SkipFonts,
    [switch]$SkipGit,
    [switch]$SkipGitHubCli,
    [switch]$Verbose
)

# Configuration
$ErrorActionPreference = "Stop"
$LogDir = "logs"
$ConfigDir = "config"

# Create necessary directories
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force }
if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir -Force }

# Logging function
function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    Add-Content -Path "$LogDir\install.log" -Value $LogMessage
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Log "Checking prerequisites..."
    
    # Check Windows version
    $OSVersion = [System.Environment]::OSVersion.Version
    if ($OSVersion.Major -lt 10) {
        throw "Windows 10 or higher required"
    }
    
    # Check PowerShell
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        throw "PowerShell 5.1 or higher required"
    }
    
    # Check administrator rights
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
    if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Administrator rights required"
    }
    
    Write-Log "Prerequisites validated" "SUCCESS"
}

# Function to install winget
function Install-Winget {
    Write-Log "Installing winget..."
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
    if ($SkipWSL) {
        Write-Log "WSL installation skipped" "SKIP"
        return
    }
    
    Write-Log "Installing WSL Ubuntu..."
    try {
        & ".\scripts\install-wsl.ps1"
        Write-Log "WSL Ubuntu installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing WSL: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to install Windows Terminal
function Install-Terminal {
    Write-Log "Installing Windows Terminal..."
    try {
        & ".\scripts\install-terminal.ps1"
        Write-Log "Windows Terminal installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Windows Terminal: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to install NerdFonts
function Install-NerdFonts {
    if ($SkipFonts) {
        Write-Log "NerdFonts installation skipped" "SKIP"
        return
    }
    
    Write-Log "Installing NerdFonts..."
    try {
        & ".\scripts\install-nerdfonts.ps1"
        Write-Log "NerdFonts installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing NerdFonts: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to install Docker
# Function to install Git
function Install-Git {
    if ($SkipGit) {
        Write-Log "Git installation skipped" "SKIP"
        return
    }

    Write-Log "Installing Git..."
    try {
        & ".\scripts\install-git.ps1"
        Write-Log "Git installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Git: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to install GitHub CLI
function Install-GitHubCli {
    if ($SkipGitHubCli) {
        Write-Log "GitHub CLI installation skipped" "SKIP"
        return
    }

    Write-Log "Installing GitHub CLI..."
    try {
        & ".\scripts\install-github-cli.ps1"
        Write-Log "GitHub CLI installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing GitHub CLI: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-Docker {
    if ($SkipDocker) {
        Write-Log "Docker installation skipped" "SKIP"
        return
    }
    
    Write-Log "Installing Docker Desktop..."
    try {
        & ".\scripts\install-docker.ps1"
        Write-Log "Docker Desktop installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Docker: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Main function
function Main {
    Write-Log "=== Starting Windows environment installation ==="
    
    try {
        Test-Prerequisites
        Install-Winget
        Install-Git
        Install-GitHubCli
        Install-Terminal
        Install-NerdFonts
        Install-WSL
        Install-Docker
        
        Write-Log "=== Installation completed successfully ===" "SUCCESS"
        Write-Log "Restart recommended to finalize configuration"
        
        $Restart = Read-Host "Do you want to restart now? (y/N)"
        if ($Restart -eq "y" -or $Restart -eq "Y") {
            Restart-Computer -Force
        }
    }
    catch {
        Write-Log "=== Installation failed ===" "ERROR"
        Write-Log "Error: $($_.Exception.Message)" "ERROR"
        exit 1
    }
}

# Execution
Main
