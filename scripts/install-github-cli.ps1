#Requires -Version 5.1
# Installation of GitHub CLI (command-line tool for GitHub).

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot '..\WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot '..\logs\github-cli.log')

function Main {
    Write-Log "=== GitHub CLI Installation ==="

    if ((Test-CommandExists 'gh') -and (-not $Force)) {
        Write-Log "GitHub CLI is already installed" "INFO"
        return
    }

    if (Install-WingetPackage -Id 'GitHub.cli' -Name 'GitHub CLI') {
        Write-Log "GitHub CLI installed successfully" "SUCCESS"
    }
    else {
        throw "GitHub CLI installation failed"
    }
}

Main
