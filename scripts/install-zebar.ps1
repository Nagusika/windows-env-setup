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
        
        # Paths to source config files
        $SourceConfigPath = Join-Path $PSScriptRoot "..\config\zebar-config.yaml"
        $SourceScriptPath = Join-Path $PSScriptRoot "..\config\zebar-script.js"
        
        $DestConfigPath = "$ConfigDir\config.yaml"
        $DestScriptPath = "$ConfigDir\script.js"
        
        # Copy configuration file if it exists in the repo
        if (Test-Path $SourceConfigPath) {
            Copy-Item -Path $SourceConfigPath -Destination $DestConfigPath -Force
            Write-Log "Zebar configuration copied to $DestConfigPath" "SUCCESS"
        }
        else {
            Write-Log "No custom configuration found for config.yaml" "INFO"
        }
        
        # Copy script file if it exists in the repo
        if (Test-Path $SourceScriptPath) {
            Copy-Item -Path $SourceScriptPath -Destination $DestScriptPath -Force
            Write-Log "Zebar script copied to $DestScriptPath" "SUCCESS"
        }
        else {
            Write-Log "No custom script found for script.js" "INFO"
        }
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

