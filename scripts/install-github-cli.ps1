# Installation and configuration of GitHub CLI
# GitHub CLI is a command-line tool for GitHub

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    $LogPath = Join-Path $PSScriptRoot "..\logs\github-cli.log"
    Add-Content -Path $LogPath -Value $LogMessage
}

function Test-GitHubCliInstalled {
    try {
        $null = Get-Command gh -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-GitHubCliViaWinget {
    Write-Log "Installing GitHub CLI via winget..."
    
    try {
        $null = Get-Command winget -ErrorAction Stop
        winget install --id GitHub.cli --silent --accept-package-agreements --accept-source-agreements
        Write-Log "GitHub CLI installed via winget" "SUCCESS"
    }
    catch {
        Write-Log "Error installing GitHub CLI via winget: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Main {
    Write-Log "=== GitHub CLI Installation ==="
    
    if ((Test-GitHubCliInstalled) -and (-not $Force)) {
        Write-Log "GitHub CLI is already installed" "INFO"
        return
    }
    
    try {
        Install-GitHubCliViaWinget
        Write-Log "GitHub CLI installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing GitHub CLI: $($_.Exception.Message)" "ERROR"
        throw
    }
}

Main
