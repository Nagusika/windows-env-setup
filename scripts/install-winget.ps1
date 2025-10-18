# Installation and configuration of winget
# winget is the official Microsoft package manager

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    $LogPath = Join-Path $PSScriptRoot "..\logs\winget.log"
    Add-Content -Path $LogPath -Value $LogMessage
}

function Test-WingetInstalled {
    try {
        $null = Get-Command winget -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Install-WingetFromStore {
    Write-Log "Installing winget from Microsoft Store..."
    
    try {
        # Check if Microsoft Store is available
        $StoreApp = Get-AppxPackage -Name "Microsoft.WindowsStore" -ErrorAction SilentlyContinue
        if (-not $StoreApp) {
            throw "Microsoft Store not available"
        }
        
        # Install winget via Microsoft Store
        Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1" -Wait
        
        # Wait for installation to complete
        $Timeout = 300 # 5 minutes
        $Elapsed = 0
        while (-not (Test-WingetInstalled) -and $Elapsed -lt $Timeout) {
            Start-Sleep -Seconds 10
            $Elapsed += 10
            Write-Log "Waiting for winget installation... ($Elapsed/$Timeout seconds)"
        }
        
        if (-not (Test-WingetInstalled)) {
            throw "Timeout during winget installation"
        }
        
        Write-Log "winget installed from Microsoft Store" "SUCCESS"
    }
    catch {
        Write-Log "Error installing from Store: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-WingetFromGitHub {
    Write-Log "Installing winget from GitHub..."
    
    try {
        # winget download URL
        $WingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $DownloadPath = "$env:TEMP\winget.msixbundle"
        
        # Download winget
        Write-Log "Downloading winget..."
        Invoke-WebRequest -Uri $WingetUrl -OutFile $DownloadPath -UseBasicParsing
        
        # Install winget
        Write-Log "Installing winget..."
        Add-AppxPackage -Path $DownloadPath
        
        # Cleanup
        Remove-Item $DownloadPath -Force
        
        Write-Log "winget installed from GitHub" "SUCCESS"
    }
    catch {
        Write-Log "Error installing from GitHub: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Update-Winget {
    Write-Log "Updating winget..."
    try {
        winget upgrade --all --silent --accept-package-agreements --accept-source-agreements
        Write-Log "winget updated" "SUCCESS"
    }
    catch {
        Write-Log "Error updating winget: $($_.Exception.Message)" "ERROR"
    }
}

function Set-WingetConfiguration {
    Write-Log "Configuring winget..."
    try {
        # Create winget configuration file
        $ConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        $ConfigDir = Split-Path $ConfigPath -Parent
        
        if (!(Test-Path $ConfigDir)) {
            New-Item -ItemType Directory -Path $ConfigDir -Force
        }
        
        $Config = @{
            "$schema" = "https://aka.ms/winget-settings.schema.json"
            "visual" = @{
                "progressBar" = "rainbow"
            }
            "experimentalFeatures" = @{
                "experimentalCmd" = $true
                "experimentalArg" = $true
            }
            "installBehavior" = @{
                "preferences" = @{
                    "scope" = "user"
                }
            }
        }
        
        $Config | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
        Write-Log "winget configuration saved" "SUCCESS"
    }
    catch {
        Write-Log "Error configuring winget: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "=== winget Installation ==="
    
    # Check if winget is already installed
    if ((Test-WingetInstalled) -and (-not $Force)) {
        Write-Log "winget is already installed" "INFO"
        Update-Winget
        Set-WingetConfiguration
        return
    }
    
    try {
        # Try to install from Microsoft Store first
        try {
            Install-WingetFromStore
        }
        catch {
            Write-Log "Failed to install from Store, trying GitHub..." "WARN"
            Install-WingetFromGitHub
        }
        
        # Verify installation
        if (-not (Test-WingetInstalled)) {
            throw "winget could not be installed"
        }
        
        # Configure winget
        Set-WingetConfiguration
        
        # Display installed version
        $Version = winget --version
        Write-Log "winget installed successfully - Version: $Version" "SUCCESS"
        
    }
    catch {
        Write-Log "Error installing winget: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Execution
Main