# Installation and configuration of NerdFonts
# NerdFonts are fonts with icons for terminals and editors

param(
    [switch]$Force,
    [string[]]$Fonts = @("CascadiaCode", "FiraCode", "JetBrainsMono", "SourceCodePro")
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    $LogPath = Join-Path $PSScriptRoot "..\logs\nerdfonts.log"
    $LogMessage | Out-File -FilePath $LogPath -Append -Encoding utf8
}

function Test-FontInstalled {
    param($FontNamePattern)
    
    try {
        $FontProperties = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        $MatchingFonts = $FontProperties.PSObject.Properties.Name | Where-Object { $_ -like $FontNamePattern }
        return $MatchingFonts.Count -gt 0
    }
    catch {
        return $false
    }
}

function Get-NerdFontDownloadUrl {
    param($FontName)
    
    $FontUrls = @{
        "CascadiaCode" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
        "FiraCode" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
        "JetBrainsMono" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        "SourceCodePro" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SourceCodePro.zip"
        "Hack" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
        "Mononoki" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Mononoki.zip"
        "RobotoMono" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/RobotoMono.zip"
        "UbuntuMono" = "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/UbuntuMono.zip"
    }
    
    return $FontUrls[$FontName]
}

function Install-NerdFont {
    param($FontName)
    
    Write-Log "Installing NerdFont: $FontName"
    
    try {
        # Check if font is already installed
        if ((Test-FontInstalled "*Caskaydia*Cove*Nerd*Font*") -and (-not $Force)) {
            Write-Log "Font $FontName already installed" "INFO"
            return
        }
        
        # Get download URL
        $DownloadUrl = Get-NerdFontDownloadUrl $FontName
        if (-not $DownloadUrl) {
            throw "Download URL not found for $FontName"
        }
        
        # Create temporary directory
        $TempDir = "$env:TEMP\nerdfonts\$FontName"
        if (Test-Path $TempDir) {
            Remove-Item $TempDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $TempDir -Force
        
        # Download font
        $ZipPath = "$TempDir\$FontName.zip"
        Write-Log "Downloading $FontName..."
        Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath -UseBasicParsing
        
        # Extract font
        Write-Log "Extracting $FontName..."
        Expand-Archive -Path $ZipPath -DestinationPath $TempDir -Force
        
        # Install fonts
        $FontFiles = Get-ChildItem -Path $TempDir -Filter "*.ttf" -Recurse
        foreach ($FontFile in $FontFiles) {
            Write-Log "Installing $($FontFile.Name)..."
            
            # Copy to system fonts folder
            $FontPath = "$env:WINDIR\Fonts\$($FontFile.Name)"
            Copy-Item -Path $FontFile.FullName -Destination $FontPath -Force
            
            # Register font in registry
            $fontRegistryName = $FontFile.BaseName
            $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            Set-ItemProperty -Path $regPath -Name "$fontRegistryName (TrueType)" -Value $FontFile.Name
        }
        
        # Cleanup
        Remove-Item $TempDir -Recurse -Force
        
        Write-Log "Font $FontName installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing $FontName : $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-NerdFontsInWSL {
    Write-Log "Installing NerdFonts in WSL Ubuntu..."
    
    try {
        # Check if WSL is running
        try {
            $wslStatus = wsl --status
            if ($wslStatus -match "The Windows Subsystem for Linux optional component is not enabled") {
                Write-Log "WSL optional component not enabled. Skipping WSL font installation." "WARN"
                return
            }
        } catch {
            Write-Log "WSL is not ready. A restart may be required. Skipping WSL font installation." "WARN"
            return
        }
        
        # Script to install fonts in WSL
        $WSLScript = @"
#!/bin/bash
set -e

echo "Installing NerdFonts in WSL Ubuntu..."

# Update packages
sudo apt update

# Install dependencies
sudo apt install -y fontconfig unzip wget

# Create fonts directory
mkdir -p ~/.local/share/fonts

# Function to download and install a font
install_nerdfont() {
    local font_name=\$1
    local font_url=\$2
    
    echo "Installing \$font_name..."
    
    # Download font
    wget -O "/tmp/\$font_name.zip" "\$font_url"
    
    # Extract to fonts directory
    unzip -o "/tmp/\$font_name.zip" -d ~/.local/share/fonts/
    
    # Cleanup
    rm "/tmp/\$font_name.zip"
}

# Install fonts
install_nerdfont "CascadiaCode" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip"
install_nerdfont "FiraCode" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
install_nerdfont "JetBrainsMono" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
install_nerdfont "SourceCodePro" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/SourceCodePro.zip"

# Rebuild font cache
fc-cache -fv

echo "NerdFonts installed in WSL Ubuntu successfully"
"@
        
        # Save script temporarily
        $ScriptPath = "$env:TEMP\install_nerdfonts_wsl.sh"
        $WSLScript | Set-Content -Path $ScriptPath -Encoding UTF8
        
        # Execute script in WSL
        wsl -d Ubuntu -e bash $ScriptPath
        
        # Cleanup
        Remove-Item $ScriptPath -Force
        
        Write-Log "NerdFonts installed in WSL Ubuntu successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing NerdFonts in WSL: $($_.Exception.Message)" "ERROR"
    }
}

function Set-FontsInWindowsTerminal {
    Write-Log "Configuring fonts in Windows Terminal..."
    
    try {
        # Path to Windows Terminal configuration file
        $ConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        
        if (Test-Path $ConfigPath) {
            # Read current configuration
            $Config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
            
            # Update default font
            if ($Config.profiles.defaults) {
                $Config.profiles.defaults.fontFace = "Cascadia Code Nerd Font"
            }
            
            # Update individual profiles
            if ($Config.profiles.list) {
                foreach ($TerminalProfile in $Config.profiles.list) {
                    if (-not $TerminalProfile.fontFace) {
                        $TerminalProfile | Add-Member -NotePropertyName "fontFace" -NotePropertyValue "Cascadia Code Nerd Font"
                    }
                }
            }
            
            # Save configuration
            $Config | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
            
            Write-Log "Windows Terminal configuration updated with NerdFonts" "SUCCESS"
        }
        else {
            Write-Log "Windows Terminal configuration file not found" "WARN"
        }
    }
    catch {
        Write-Log "Error configuring fonts in Windows Terminal: $($_.Exception.Message)" "ERROR"
    }
}

function New-FontConfigForWSL {
    Write-Log "Creating font configuration for WSL..."
    
    try {
        # Font configuration script for WSL
        $WSLFontConfig = @"
# Font configuration for WSL Ubuntu
# This file configures default fonts for terminals

# Configuration for bash
if [ -f ~/.bashrc ]; then
    echo 'export TERM=xterm-256color' >> ~/.bashrc
    echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
fi

# Configuration for zsh (if installed)
if [ -f ~/.zshrc ]; then
    echo 'export TERM=xterm-256color' >> ~/.zshrc
    echo 'export LANG=en_US.UTF-8' >> ~/.zshrc
fi

# Configuration for vim
if [ -f ~/.vimrc ]; then
    echo 'set guifont=Cascadia\ Code\ Nerd\ Font:h12' >> ~/.vimrc
fi

# Configuration for neovim
if [ -d ~/.config/nvim ]; then
    mkdir -p ~/.config/nvim
    echo 'vim.opt.guifont = "Cascadia Code Nerd Font:h12"' > ~/.config/nvim/init.lua
fi

echo "WSL font configuration completed"
"@
        
        # Save configuration
        $ConfigPath = Join-Path $PSScriptRoot "..\config\wsl-font-config.sh"
        if (-not (Test-Path $ConfigPath) -or (Compare-Object ($WSLFontConfig -split '\r?\n') (Get-Content $ConfigPath))) {
            $WSLFontConfig | Set-Content -Path $ConfigPath -Encoding UTF8
            Write-Log "WSL font configuration saved in $ConfigPath" "SUCCESS"
        } else {
            Write-Log "WSL font configuration is already up to date." "INFO"
        }
    }
    catch {
        Write-Log "Error creating WSL font configuration: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "=== NerdFonts Installation ==="
    
    try {
        # Install fonts on Windows
        foreach ($FontName in $Fonts) {
            Install-NerdFont $FontName
        }
        
        # Install fonts in WSL
        Install-NerdFontsInWSL
        
        # Configure fonts in Windows Terminal
        Set-FontsInWindowsTerminal
        
        # Create font configuration for WSL
        New-FontConfigForWSL
        
        Write-Log "NerdFonts installed and configured successfully" "SUCCESS"
        Write-Log "Restart recommended to finalize font installation" "WARN"
        
    }
    catch {
        Write-Log "Error installing NerdFonts: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Execution
Main