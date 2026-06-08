#Requires -Version 5.1
# Installation of Git (distributed version control system).

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot '..\WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot '..\logs\git.log')

function Main {
    Write-Log "=== Git Installation ==="

    if ((Test-CommandExists 'git') -and (-not $Force)) {
        Write-Log "Git is already installed" "INFO"
        return
    }

    if (Install-WingetPackage -Id 'Git.Git' -Name 'Git') {
        Write-Log "Git installed successfully" "SUCCESS"
    }
    else {
        throw "Git installation failed"
    }
}

Main
