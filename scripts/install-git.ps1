# Installation and configuration of Git
# Git is a distributed version control system

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    $LogPath = Join-Path $PSScriptRoot "..\logs\git.log"
    Add-Content -Path $LogPath -Value $LogMessage
}

function Test-GitInstalled {
    try {
        $null = Get-Command git -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-GitViaWinget {
    Write-Log "Installing Git via winget..."
    
    try {
        $null = Get-Command winget -ErrorAction Stop
        winget install --id Git.Git --silent --accept-package-agreements --accept-source-agreements
        Write-Log "Git installed via winget" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Git via winget: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Main {
    Write-Log "=== Git Installation ==="
    
    if ((Test-GitInstalled) -and (-not $Force)) {
        Write-Log "Git is already installed" "INFO"
        return
    }
    
    try {
        Install-GitViaWinget
        Write-Log "Git installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Git: $($_.Exception.Message)" "ERROR"
        throw
    }
}

Main
