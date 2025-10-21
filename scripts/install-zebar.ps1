# Installation and configuration of Zebar
# Zebar is a customizable status bar for Windows

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    $LogPath = Join-Path $PSScriptRoot "..\logs\zebar.log"
    Add-Content -Path $LogPath -Value $LogMessage
}

function Test-ZebarInstalled {
    try {
        $null = Get-Command zebar -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-ZebarViaWinget {
    Write-Log "Installing Zebar via winget..."
    
    try {
        $null = Get-Command winget -ErrorAction Stop
        winget install --id glzr-io.zebar --silent --accept-package-agreements --accept-source-agreements
        Write-Log "Zebar installed via winget" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Zebar via winget: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Set-ZebarConfiguration {
    Write-Log "Configuring Zebar..."
    
    try {
        # Path to Zebar configuration directory
        $ConfigDir = "$env:USERPROFILE\.glzr\zebar"
        
        # Create configuration directory if it doesn't exist
        if (!(Test-Path $ConfigDir)) {
            New-Item -ItemType Directory -Path $ConfigDir -Force
            Write-Log "Created Zebar configuration directory: $ConfigDir" "SUCCESS"
        }
        
        # Paths to source config files (Gruvbox theme with React)
        $SourceHtmlPath = Join-Path $PSScriptRoot "..\config\zebar-with-glazewm.html"
        $SourceCssPath = Join-Path $PSScriptRoot "..\config\styles_gruvbox.css"
        
        $DestHtmlPath = "$ConfigDir\with-glazewm.html"
        $DestCssPath = "$ConfigDir\styles_gruvbox.css"
        
        # Copy HTML file if it exists in the repo
        if (Test-Path $SourceHtmlPath) {
            Copy-Item -Path $SourceHtmlPath -Destination $DestHtmlPath -Force
            Write-Log "Zebar HTML configuration copied to $DestHtmlPath" "SUCCESS"
        }
        else {
            Write-Log "No custom HTML configuration found" "WARN"
        }
        
        # Copy CSS file if it exists in the repo
        if (Test-Path $SourceCssPath) {
            Copy-Item -Path $SourceCssPath -Destination $DestCssPath -Force
            Write-Log "Zebar CSS styles copied to $DestCssPath" "SUCCESS"
        }
        else {
            Write-Log "No custom CSS styles found" "WARN"
        }
        
        Write-Log "Zebar configured with Gruvbox-Enhanced theme (React-based with interactive stats)" "SUCCESS"
    }
    catch {
        Write-Log "Error configuring Zebar: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "=== Zebar Installation ==="
    
    if ((Test-ZebarInstalled) -and (-not $Force)) {
        Write-Log "Zebar is already installed" "INFO"
        Set-ZebarConfiguration
        return
    }
    
    try {
        Install-ZebarViaWinget
        
        # Verify installation
        if (-not (Test-ZebarInstalled)) {
            Write-Log "Zebar installed but not found in PATH. You may need to restart your terminal." "WARN"
        }
        
        Set-ZebarConfiguration
        
        Write-Log "Zebar installed and configured successfully" "SUCCESS"
        Write-Log "Zebar will be automatically started by GlazeWM" "INFO"
    }
    catch {
        Write-Log "Error installing Zebar: $($_.Exception.Message)" "ERROR"
        throw
    }
}

Main

