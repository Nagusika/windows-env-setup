# Installation and configuration of Windows Terminal
# Windows Terminal is Microsoft's modern and customizable terminal

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    $LogPath = Join-Path $PSScriptRoot "..\logs\terminal.log"
    Add-Content -Path $LogPath -Value $LogMessage
}

function Test-WindowsTerminalInstalled {
    try {
        $TerminalApp = Get-AppxPackage -Name "Microsoft.WindowsTerminal" -ErrorAction SilentlyContinue
        return $null -ne $TerminalApp
    }
    catch {
        return $false
    }
}

function Install-WindowsTerminalViaWinget {
    Write-Log "Installing Windows Terminal via winget..."
    
    try {
        # Check if winget is available
        $null = Get-Command winget -ErrorAction Stop
        
        # Install Windows Terminal
        winget install --id Microsoft.WindowsTerminal --silent --accept-package-agreements --accept-source-agreements
        
        Write-Log "Windows Terminal installed via winget" "SUCCESS"
    }
    catch {
        Write-Log "Error installing via winget: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-WindowsTerminalViaStore {
    Write-Log "Installing Windows Terminal via Microsoft Store..."
    
    try {
        # Check if Microsoft Store is available
        $StoreApp = Get-AppxPackage -Name "Microsoft.WindowsStore" -ErrorAction SilentlyContinue
        if (-not $StoreApp) {
            throw "Microsoft Store not available"
        }
        
        # Install Windows Terminal via Microsoft Store
        Start-Process "ms-windows-store://pdp/?ProductId=9N0DX20HK701" -Wait
        
        Write-Log "Windows Terminal installed via Microsoft Store" "SUCCESS"
    }
    catch {
        Write-Log "Error installing via Store: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-WindowsTerminalViaGitHub {
    Write-Log "Installing Windows Terminal via GitHub..."
    
    try {
        # Windows Terminal download URL
        $TerminalUrl = "https://github.com/microsoft/terminal/releases/latest/download/Microsoft.WindowsTerminal_8wekyb3d8bbwe.msixbundle"
        $DownloadPath = "$env:TEMP\WindowsTerminal.msixbundle"
        
        # Download Windows Terminal
        Write-Log "Downloading Windows Terminal..."
        Invoke-WebRequest -Uri $TerminalUrl -OutFile $DownloadPath -UseBasicParsing
        
        # Install Windows Terminal
        Write-Log "Installing Windows Terminal..."
        Add-AppxPackage -Path $DownloadPath
        
        # Cleanup
        Remove-Item $DownloadPath -Force
        
        Write-Log "Windows Terminal installed via GitHub" "SUCCESS"
    }
    catch {
        Write-Log "Error installing via GitHub: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Set-WindowsTerminalConfiguration {
    Write-Log "Configuring Windows Terminal..."
    
    try {
        # Path to configuration file
        $ConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        $ConfigDir = Split-Path $ConfigPath -Parent
        
        # Create configuration directory if it doesn't exist
        if (!(Test-Path $ConfigDir)) {
            New-Item -ItemType Directory -Path $ConfigDir -Force
        }
        
        # Default Windows Terminal configuration
        $TerminalConfig = @{
            "$schema" = "https://aka.ms/terminal-profiles-schema"
            "defaultProfile" = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
            "profiles" = @{
                "defaults" = @{
                    "fontFace" = "Cascadia Code"
                    "fontSize" = 12
                    "colorScheme" = "Campbell"
                    "cursorShape" = "bar"
                    "cursorHeight" = 1
                    "snapOnInput" = $true
                    "historySize" = 9001
                    "scrollbarState" = "hidden"
                }
                "list" = @(
                    @{
                        "guid" = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
                        "name" = "Windows PowerShell"
                        "commandline" = "powershell.exe"
                        "hidden" = $false
                        "startingDirectory" = "~"
                    },
                    @{
                        "guid" = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}"
                        "name" = "Command Prompt"
                        "commandline" = "cmd.exe"
                        "hidden" = $false
                        "startingDirectory" = "~"
                    },
                    @{
                        "guid" = "{2c4de342-38b7-51cf-b940-2309a097f518}"
                        "name" = "Ubuntu"
                        "commandline" = "wsl.exe -d Ubuntu"
                        "hidden" = $false
                        "startingDirectory" = "~"
                        "icon" = "ms-appx:///ProfileIcons/{9acb9455-ca41-5af7-950f-6bca1bc9722f}.png"
                    }
                )
            }
            "schemes" = @(
                @{
                    "name" = "Campbell"
                    "foreground" = "#F2F2F2"
                    "background" = "#0C0C0C"
                    "cursorColor" = "#F2F2F2"
                    "selectionBackground" = "#FFFFFF"
                    "black" = "#0C0C0C"
                    "red" = "#C50F1F"
                    "green" = "#13A10E"
                    "yellow" = "#C19C00"
                    "blue" = "#0037DA"
                    "purple" = "#881798"
                    "cyan" = "#3A96DD"
                    "white" = "#CCCCCC"
                    "brightBlack" = "#767676"
                    "brightRed" = "#E74856"
                    "brightGreen" = "#16C60C"
                    "brightYellow" = "#F9F1A5"
                    "brightBlue" = "#3B78FF"
                    "brightPurple" = "#B4009E"
                    "brightCyan" = "#61D6D6"
                    "brightWhite" = "#F2F2F2"
                }
            )
            "keybindings" = @(
                @{
                    "command" = "closeTab"
                    "keys" = @("ctrl+shift+w")
                },
                @{
                    "command" = "newTab"
                    "keys" = @("ctrl+shift+t")
                },
                @{
                    "command" = "newWindow"
                    "keys" = @("ctrl+shift+n")
                },
                @{
                    "command" = "nextTab"
                    "keys" = @("ctrl+tab")
                },
                @{
                    "command" = "prevTab"
                    "keys" = @("ctrl+shift+tab")
                },
                @{
                    "command" = "splitHorizontal"
                    "keys" = @("alt+shift+-")
                },
                @{
                    "command" = "splitVertical"
                    "keys" = @("alt+shift+plus")
                }
            )
        }
        
        # Save configuration
        $TerminalConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
        
        Write-Log "Windows Terminal configuration saved in $ConfigPath" "SUCCESS"
        
        # Create configuration backup in config folder
        $BackupConfigPath = Join-Path $PSScriptRoot "..\config\terminal-settings.json"
        if (-not (Test-Path $BackupConfigPath) -or (Compare-Object (Get-Content $ConfigPath) (Get-Content $BackupConfigPath))) {
            Copy-Item -Path $ConfigPath -Destination $BackupConfigPath -Force
            Write-Log "Configuration backed up in $BackupConfigPath" "SUCCESS"
        } else {
            Write-Log "Configuration backup is already up to date." "INFO"
        }
        
    }
    catch {
        Write-Log "Error configuring Windows Terminal: $($_.Exception.Message)" "ERROR"
    }
}

function Set-WindowsTerminalAsDefault {
    Write-Log "Setting Windows Terminal as default terminal..."
    
    try {
        # Set Windows Terminal as default terminal
        $RegPath = "HKCU:\Console"
        if (!(Test-Path $RegPath)) {
            New-Item -Path $RegPath -Force
        }
        
        Set-ItemProperty -Path $RegPath -Name "DelegationConsole" -Value "{2EACA947-7F5F-4CFA-B222-0004BFF319B1}"
        Set-ItemProperty -Path $RegPath -Name "DelegationTerminal" -Value "{2EACA947-7F5F-4CFA-B222-0004BFF319B1}"
        
        Write-Log "Windows Terminal set as default terminal" "SUCCESS"
    }
    catch {
        Write-Log "Error setting default terminal: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "=== Windows Terminal Installation ==="
    
    # Check if Windows Terminal is already installed
    if ((Test-WindowsTerminalInstalled) -and (-not $Force)) {
        Write-Log "Windows Terminal is already installed" "INFO"
        Set-WindowsTerminalConfiguration
        Set-WindowsTerminalAsDefault
        return
    }
    
    try {
        # Try to install via winget first
        try {
            Install-WindowsTerminalViaWinget
        }
        catch {
            Write-Log "Failed to install via winget, trying Store..." "WARN"
            try {
                Install-WindowsTerminalViaStore
            }
            catch {
                Write-Log "Failed to install via Store, trying GitHub..." "WARN"
                Install-WindowsTerminalViaGitHub
            }
        }
        
        # Verify installation
        if (-not (Test-WindowsTerminalInstalled)) {
            throw "Windows Terminal could not be installed"
        }
        
        # Configure Windows Terminal
        Set-WindowsTerminalConfiguration
        
        # Set as default terminal
        Set-WindowsTerminalAsDefault
        
        Write-Log "Windows Terminal installed and configured successfully" "SUCCESS"
        
    }
    catch {
        Write-Log "Error installing Windows Terminal: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Execution
Main