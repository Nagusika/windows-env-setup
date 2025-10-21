# Installation and configuration of GlazeWM
# GlazeWM is a tiling window manager for Windows

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    $LogPath = Join-Path $PSScriptRoot "..\logs\glazewm.log"
    Add-Content -Path $LogPath -Value $LogMessage
}

function Test-GlazeWMInstalled {
    try {
        $null = Get-Command glazewm -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-GlazeWMViaWinget {
    Write-Log "Installing GlazeWM via winget..."
    
    try {
        $null = Get-Command winget -ErrorAction Stop
        winget install --id glzr-io.glazewm --silent --accept-package-agreements --accept-source-agreements
        Write-Log "GlazeWM installed via winget" "SUCCESS"
    }
    catch {
        Write-Log "Error installing GlazeWM via winget: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Set-GlazeWMConfiguration {
    Write-Log "Configuring GlazeWM..."
    
    try {
        # Path to GlazeWM configuration directory
        $ConfigDir = "$env:USERPROFILE\.glzr\glazewm"
        
        # Create configuration directory if it doesn't exist
        if (!(Test-Path $ConfigDir)) {
            New-Item -ItemType Directory -Path $ConfigDir -Force
            Write-Log "Created GlazeWM configuration directory: $ConfigDir" "SUCCESS"
        }
        
        # Path to source config file
        $SourceConfigPath = Join-Path $PSScriptRoot "..\config\glazewm-config.yaml"
        $DestConfigPath = "$ConfigDir\config.yaml"
        
        # Copy configuration file if it exists in the repo
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
        # Create shortcut in startup folder
        $StartupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        $ShortcutPath = "$StartupPath\GlazeWM.lnk"
        
        # GlazeWM executable path (after winget installation)
        $GlazeWMPath = "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\glzr-io.glazewm_Microsoft.Winget.Source_8wekyb3d8bbwe\glazewm.exe"
        
        # Check if the executable exists
        if (Test-Path $GlazeWMPath) {
            # Create shortcut
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
    
    if ((Test-GlazeWMInstalled) -and (-not $Force)) {
        Write-Log "GlazeWM is already installed" "INFO"
        Set-GlazeWMConfiguration
        return
    }
    
    try {
        Install-GlazeWMViaWinget
        
        # Verify installation
        if (-not (Test-GlazeWMInstalled)) {
            Write-Log "GlazeWM installed but not found in PATH. You may need to restart your terminal." "WARN"
        }
        
        Set-GlazeWMConfiguration
        Set-GlazeWMAutostart
        
        Write-Log "GlazeWM installed and configured successfully" "SUCCESS"
        Write-Log "You can start GlazeWM by running 'glazewm' or restarting your computer" "INFO"
    }
    catch {
        Write-Log "Error installing GlazeWM: $($_.Exception.Message)" "ERROR"
        throw
    }
}

Main

