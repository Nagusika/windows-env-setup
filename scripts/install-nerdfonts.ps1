#Requires -Version 5.1
#Requires -RunAsAdministrator
# Installation of Nerd Fonts (patched fonts with icons) on Windows, and optionally in WSL.

param(
    [switch]$Force,
    [string[]]$Fonts = @("CascadiaCode", "FiraCode", "JetBrainsMono", "SourceCodePro")
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot '..\WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot '..\logs\nerdfonts.log')

# Map each downloaded family to the registry name pattern its Nerd Font variant uses,
# so the "already installed" check is per-font instead of always testing CaskaydiaCove.
$FontInstalledPattern = @{
    CascadiaCode  = '*CaskaydiaCove*Nerd*'
    FiraCode      = '*FiraCode*Nerd*'
    JetBrainsMono = '*JetBrainsMono*Nerd*'
    SourceCodePro = '*SauceCodePro*Nerd*'
}

function Test-FontInstalled {
    param([string]$FontNamePattern)
    try {
        $names = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts").PSObject.Properties.Name
        return [bool]($names | Where-Object { $_ -like $FontNamePattern })
    }
    catch { return $false }
}

function Get-NerdFontDownloadUrl {
    param([string]$FontName)
    return "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FontName.zip"
}

function Install-NerdFont {
    param([string]$FontName)

    Write-Log "Installing Nerd Font: $FontName"
    try {
        $pattern = $FontInstalledPattern[$FontName]
        if (-not $pattern) { $pattern = "*$FontName*Nerd*" }
        if ((Test-FontInstalled $pattern) -and (-not $Force)) {
            Write-Log "$FontName Nerd Font already installed" "INFO"
            return
        }

        $url = Get-NerdFontDownloadUrl $FontName
        $tempDir = Join-Path $env:TEMP "nerdfonts\$FontName"
        if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

        $zipPath = Join-Path $tempDir "$FontName.zip"
        Write-Log "Downloading $FontName..."
        Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $tempDir -Force

        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        foreach ($fontFile in (Get-ChildItem -Path $tempDir -Filter "*.ttf" -Recurse)) {
            Copy-Item -Path $fontFile.FullName -Destination "$env:WINDIR\Fonts\$($fontFile.Name)" -Force
            Set-ItemProperty -Path $regPath -Name "$($fontFile.BaseName) (TrueType)" -Value $fontFile.Name
        }

        Remove-Item $tempDir -Recurse -Force
        Write-Log "$FontName Nerd Font installed" "SUCCESS"
    }
    catch {
        Write-Log "Error installing $FontName : $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-NerdFontsInWSL {
    $distro = Get-WslDistro
    if (-not $distro) {
        Write-Log "WSL/Ubuntu not available; skipping WSL font installation" "WARN"
        return
    }

    Write-Log "Installing Nerd Fonts in WSL ($distro)..."
    $wslScript = @'
#!/bin/bash
set -e
echo "Installing Nerd Fonts in WSL..."
sudo apt update
sudo apt install -y fontconfig unzip wget
mkdir -p ~/.local/share/fonts
for f in CascadiaCode FiraCode JetBrainsMono SourceCodePro; do
    wget -O "/tmp/$f.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$f.zip"
    unzip -o "/tmp/$f.zip" -d ~/.local/share/fonts/
    rm "/tmp/$f.zip"
done
fc-cache -fv
echo "Nerd Fonts installed in WSL"
'@ -replace "`r`n", "`n"

    try {
        # Write the script as UTF-8 without a BOM and with LF endings; a BOM on the first
        # line would make bash fail with "bad interpreter".
        $scriptPath = Join-Path $env:TEMP 'install_nerdfonts_wsl.sh'
        [System.IO.File]::WriteAllText($scriptPath, $wslScript)

        $wslScriptPath = ((wsl -d $distro -e wslpath -u $scriptPath 2>$null) -replace "`0", "").Trim()
        wsl -d $distro -e bash $wslScriptPath
        if ($LASTEXITCODE -ne 0) { Write-Log "WSL font install returned exit $LASTEXITCODE" "WARN" }
        else { Write-Log "Nerd Fonts installed in WSL" "SUCCESS" }

        Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Log "Error installing Nerd Fonts in WSL: $($_.Exception.Message)" "ERROR"
    }
}

function Set-FontsInWindowsTerminal {
    Write-Log "Configuring fonts in Windows Terminal..."
    try {
        $configPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        if (-not (Test-Path $configPath)) {
            Write-Log "Windows Terminal configuration file not found" "WARN"
            return
        }

        $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json
        if ($config.profiles.defaults) {
            $config.profiles.defaults.fontFace = "CaskaydiaCove Nerd Font"
        }
        $config | ConvertTo-Json -Depth 10 | Set-Content -Path $configPath -Encoding UTF8
        Write-Log "Windows Terminal default font set to a Nerd Font" "SUCCESS"
    }
    catch {
        Write-Log "Error configuring fonts in Windows Terminal: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "=== Nerd Fonts Installation ==="
    try {
        foreach ($fontName in $Fonts) {
            Install-NerdFont $fontName
        }
        Install-NerdFontsInWSL
        Set-FontsInWindowsTerminal

        Write-Log "Nerd Fonts installed and configured" "SUCCESS"
        Write-Log "Restart terminals/apps to pick up the new fonts" "WARN"
    }
    catch {
        Write-Log "Error installing Nerd Fonts: $($_.Exception.Message)" "ERROR"
        throw
    }
}

Main
