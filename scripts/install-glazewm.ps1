#Requires -Version 5.1
# Installation and configuration of GlazeWM (tiling window manager for Windows).

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot '..\WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot '..\logs\glazewm.log')

function Set-GlazeWMConfiguration {
    Write-Log "Configuring GlazeWM..."

    try {
        $ConfigDir = "$env:USERPROFILE\.glzr\glazewm"
        if (!(Test-Path $ConfigDir)) {
            New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
            Write-Log "Created GlazeWM configuration directory: $ConfigDir" "SUCCESS"
        }

        $SourceConfigPath = Join-Path $PSScriptRoot "..\config\glazewm-config.yaml"
        $DestConfigPath = "$ConfigDir\config.yaml"

        if (Test-Path $SourceConfigPath) {
            Copy-Item -Path $SourceConfigPath -Destination $DestConfigPath -Force
            Write-Log "GlazeWM configuration copied to $DestConfigPath" "SUCCESS"
        }
        else {
            Write-Log "No custom configuration found, GlazeWM will use default settings" "INFO"
        }
    }
    catch {
        Write-Log "Error configuring GlazeWM: $($_.Exception.Message)" "ERROR"
    }
}

function Set-GlazeWMAutostart {
    Write-Log "Setting up GlazeWM autostart..."

    try {
        $StartupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        $ShortcutPath = "$StartupPath\GlazeWM.lnk"
        $GlazeWMPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\glzr-io.glazewm_Microsoft.Winget.Source_8wekyb3d8bbwe\glazewm.exe"

        if (Test-Path $GlazeWMPath) {
            $WshShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
            $Shortcut.TargetPath = $GlazeWMPath
            $Shortcut.WorkingDirectory = Split-Path $GlazeWMPath
            $Shortcut.Save()
            Write-Log "GlazeWM autostart configured" "SUCCESS"
        }
        else {
            Write-Log "GlazeWM executable not found at expected location, skipping autostart setup" "WARN"
        }
    }
    catch {
        Write-Log "Error setting up autostart: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "=== GlazeWM Installation ==="

    if ((Test-CommandExists 'glazewm') -and (-not $Force)) {
        Write-Log "GlazeWM is already installed" "INFO"
        Set-GlazeWMConfiguration
        return
    }

    if (-not (Install-WingetPackage -Id 'glzr-io.glazewm' -Name 'GlazeWM')) {
        throw "GlazeWM installation failed"
    }

    if (-not (Test-CommandExists 'glazewm')) {
        Write-Log "GlazeWM installed but not found in PATH. You may need to restart your terminal." "WARN"
    }

    Set-GlazeWMConfiguration
    Set-GlazeWMAutostart

    Write-Log "GlazeWM installed and configured successfully" "SUCCESS"
    Write-Log "You can start GlazeWM by running 'glazewm' or restarting your computer" "INFO"
}

Main
