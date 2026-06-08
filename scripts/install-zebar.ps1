#Requires -Version 5.1
# Installation and configuration of Zebar (customizable status bar for Windows).

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot '..\WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot '..\logs\zebar.log')

function Set-ZebarConfiguration {
    Write-Log "Configuring Zebar..."

    try {
        $ConfigDir = "$env:USERPROFILE\.glzr\zebar"
        if (!(Test-Path $ConfigDir)) {
            New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
            Write-Log "Created Zebar configuration directory: $ConfigDir" "SUCCESS"
        }

        $SourceHtmlPath = Join-Path $PSScriptRoot "..\config\zebar-with-glazewm.html"
        $SourceCssPath = Join-Path $PSScriptRoot "..\config\styles_gruvbox.css"
        $DestHtmlPath = "$ConfigDir\with-glazewm.html"
        $DestCssPath = "$ConfigDir\styles_gruvbox.css"

        if (Test-Path $SourceHtmlPath) {
            Copy-Item -Path $SourceHtmlPath -Destination $DestHtmlPath -Force
            Write-Log "Zebar HTML configuration copied to $DestHtmlPath" "SUCCESS"
        }
        else {
            Write-Log "No custom HTML configuration found" "WARN"
        }

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

    if ((Test-CommandExists 'zebar') -and (-not $Force)) {
        Write-Log "Zebar is already installed" "INFO"
        Set-ZebarConfiguration
        return
    }

    if (-not (Install-WingetPackage -Id 'glzr-io.zebar' -Name 'Zebar')) {
        throw "Zebar installation failed"
    }

    if (-not (Test-CommandExists 'zebar')) {
        Write-Log "Zebar installed but not found in PATH. You may need to restart your terminal." "WARN"
    }

    Set-ZebarConfiguration

    Write-Log "Zebar installed and configured successfully" "SUCCESS"
    Write-Log "Zebar will be automatically started by GlazeWM" "INFO"
}

Main
