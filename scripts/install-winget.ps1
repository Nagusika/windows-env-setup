#Requires -Version 5.1
# Installation and configuration of winget (the official Microsoft package manager).

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot '..\WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot '..\logs\winget.log')

function Install-WingetFromStore {
    Write-Log "Installing winget from Microsoft Store..."

    $StoreApp = Get-AppxPackage -Name "Microsoft.WindowsStore" -ErrorAction SilentlyContinue
    if (-not $StoreApp) { throw "Microsoft Store not available" }

    Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1" -Wait

    $timeout = 300; $elapsed = 0
    while (-not (Test-CommandExists 'winget') -and $elapsed -lt $timeout) {
        Start-Sleep -Seconds 10
        $elapsed += 10
        Write-Log "Waiting for winget installation... ($elapsed/$timeout seconds)"
    }
    if (-not (Test-CommandExists 'winget')) { throw "Timeout during winget installation" }
    Write-Log "winget installed from Microsoft Store" "SUCCESS"
}

function Install-WingetFromGitHub {
    Write-Log "Installing winget from GitHub..."

    $WingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
    $DownloadPath = "$env:TEMP\winget.msixbundle"

    Write-Log "Downloading winget..."
    Invoke-WebRequest -Uri $WingetUrl -OutFile $DownloadPath -UseBasicParsing

    Write-Log "Installing winget..."
    Add-AppxPackage -Path $DownloadPath   # Add-AppxPackage throws on failure
    Remove-Item $DownloadPath -Force

    Write-Log "winget installed from GitHub" "SUCCESS"
}

function Set-WingetConfiguration {
    Write-Log "Configuring winget (prefer user scope)..."
    try {
        $ConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json"
        $ConfigDir = Split-Path $ConfigPath -Parent
        if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null }

        # NB: the key is the literal string "$schema" - the backtick prevents PowerShell
        # from expanding it as a variable (the previous version produced an empty "" key).
        $Config = @{
            "`$schema"        = "https://aka.ms/winget-settings.schema.json"
            "visual"          = @{ "progressBar" = "rainbow" }
            "installBehavior" = @{ "preferences" = @{ "scope" = "user" } }
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

    if ((Test-CommandExists 'winget') -and (-not $Force)) {
        Write-Log "winget is already installed" "INFO"
        Set-WingetConfiguration
        return
    }

    try {
        try {
            Install-WingetFromStore
        }
        catch {
            Write-Log "Failed to install from Store, trying GitHub..." "WARN"
            Install-WingetFromGitHub
        }

        if (-not (Test-CommandExists 'winget')) { throw "winget could not be installed" }

        Set-WingetConfiguration
        Write-Log "winget installed successfully - $((winget --version) 2>$null)" "SUCCESS"
    }
    catch {
        Write-Log "Error installing winget: $($_.Exception.Message)" "ERROR"
        throw
    }
}

Main
