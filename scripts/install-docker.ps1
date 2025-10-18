# Installation and configuration of Docker Desktop
# Docker Desktop allows running containers on Windows

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    $LogPath = Join-Path $PSScriptRoot "..\logs\docker.log"
    Add-Content -Path $LogPath -Value $LogMessage
}

function Test-DockerInstalled {
    try {
        $null = Get-Command docker -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Test-DockerDesktopInstalled {
    try {
        $DockerApp = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | Where-Object { $_.DisplayName -like "*Docker Desktop*" }
        return $null -ne $DockerApp
    }
    catch {
        return $false
    }
}

function Test-WSL2Available {
    try {
        $null = Get-Command wsl -ErrorAction Stop
        $WSLVersion = wsl --status
        return $WSLVersion -match "WSL 2"
    }
    catch {
        return $false
    }
}

function Install-DockerDesktopViaWinget {
    Write-Log "Installing Docker Desktop via winget..."
    
    try {
        # Check if winget is available
        $null = Get-Command winget -ErrorAction Stop
        
        # Install Docker Desktop
        winget install --id Docker.DockerDesktop --silent --accept-package-agreements --accept-source-agreements
        
        Write-Log "Docker Desktop installed via winget" "SUCCESS"
    }
    catch {
        Write-Log "Error installing via winget: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-DockerDesktopViaDownload {
    Write-Log "Installing Docker Desktop via direct download..."
    
    try {
        # Docker Desktop download URL
        $DockerUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
        $DownloadPath = "$env:TEMP\DockerDesktopInstaller.exe"
        
        # Download Docker Desktop
        Write-Log "Downloading Docker Desktop..."
        Invoke-WebRequest -Uri $DockerUrl -OutFile $DownloadPath -UseBasicParsing
        
        # Install Docker Desktop
        Write-Log "Installing Docker Desktop..."
        Start-Process -FilePath $DownloadPath -ArgumentList "install", "--quiet", "--accept-license" -Wait
        
        # Cleanup
        Remove-Item $DownloadPath -Force
        
        Write-Log "Docker Desktop installed via direct download" "SUCCESS"
    }
    catch {
        Write-Log "Error installing via download: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Enable-DockerFeatures {
    Write-Log "Enabling Docker features..."
    
    try {
        # Enable Hyper-V if available
        $HyperVFeature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -ErrorAction SilentlyContinue
        if ($HyperVFeature -and $HyperVFeature.State -ne "Enabled") {
            Write-Log "Enabling Hyper-V..."
            Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V" -NoRestart
        }
        
        # Enable Virtual Machine Platform
        $VMPFeature = Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -ErrorAction SilentlyContinue
        if ($VMPFeature -and $VMPFeature.State -ne "Enabled") {
            Write-Log "Enabling VirtualMachinePlatform..."
            Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -NoRestart
        }
        
        # Enable WSL
        $WSLFeature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -ErrorAction SilentlyContinue
        if ($WSLFeature -and $WSLFeature.State -ne "Enabled") {
            Write-Log "Enabling WSL..."
            Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart
        }
        
        Write-Log "Docker features enabled" "SUCCESS"
    }
    catch {
        Write-Log "Error enabling Docker features: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Set-DockerDesktopConfiguration {
    Write-Log "Configuring Docker Desktop..."
    
    try {
        # Path to Docker Desktop configuration file
        $ConfigPath = "$env:APPDATA\Docker\settings.json"
        $ConfigDir = Split-Path $ConfigPath -Parent
        
        # Create configuration directory if it doesn't exist
        if (!(Test-Path $ConfigDir)) {
            New-Item -ItemType Directory -Path $ConfigDir -Force
        }
        
        # Default Docker Desktop configuration
        $DockerConfig = @{
            "auths" = @{}
            "credsStore" = "desktop"
            "experimental" = $false
            "stackOrchestrator" = "swarm"
            "builder" = @{
                "gc" = @{
                    "enabled" = $true
                    "policy" = @(
                        @{
                            "all" = $true
                            "filter" = @(
                                "unused-for=24h"
                            )
                            "keepStorage" = "10GB"
                        }
                    )
                }
            }
            "dockerPath" = ""
            "contexts" = @(
                @{
                    "name" = "desktop-linux"
                    "type" = "docker"
                    "description" = "Docker Desktop"
                    "dockerHost" = "npipe:////./pipe/dockerDesktopLinuxEngine"
                }
            )
            "currentContext" = "desktop-linux"
            "proxies" = @{}
            "registryMirrors" = @()
            "insecureRegistries" = @()
            "debug" = $false
            "metricsEnabled" = $true
            "contextStore" = "desktop"
            "cliPluginsExtraDirs" = @()
            "credentialStore" = "desktop"
        }
        
        # Save configuration
        $DockerConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
        
        Write-Log "Docker Desktop configuration saved in $ConfigPath" "SUCCESS"
        
        # Create configuration backup in config folder
        $BackupConfigPath = Join-Path $PSScriptRoot "..\config\docker-settings.json"
        if (-not (Test-Path $BackupConfigPath) -or (Compare-Object (Get-Content $ConfigPath) (Get-Content $BackupConfigPath))) {
            Copy-Item -Path $ConfigPath -Destination $BackupConfigPath -Force
            Write-Log "Configuration backed up in $BackupConfigPath" "SUCCESS"
        } else {
            Write-Log "Configuration backup is already up to date." "INFO"
        }
        
    }
    catch {
        Write-Log "Error configuring Docker Desktop: $($_.Exception.Message)" "ERROR"
    }
}

function Start-DockerDesktop {
    Write-Log "Starting Docker Desktop..."
    
    try {
        # Start Docker Desktop
        Start-Process -FilePath "C:\Program Files\Docker\Docker\Docker Desktop.exe" -WindowStyle Hidden
        
        # Wait for Docker to be ready
        $Timeout = 300 # 5 minutes
        $Elapsed = 0
        $DockerReady = $false
        
        while (-not $DockerReady -and $Elapsed -lt $Timeout) {
            Start-Sleep -Seconds 10
            $Elapsed += 10
            
            try {
                $null = docker version --format "{{.Server.Version}}" 2>$null
                $DockerReady = $true
            }
            catch {
                Write-Log "Waiting for Docker to start... ($Elapsed/$Timeout seconds)"
            }
        }
        
        if ($DockerReady) {
            Write-Log "Docker Desktop started successfully" "SUCCESS"
        }
        else {
            Write-Log "Timeout during Docker Desktop startup" "WARN"
        }
    }
    catch {
        Write-Log "Error starting Docker Desktop: $($_.Exception.Message)" "ERROR"
    }
}

function Test-DockerInstallation {
    Write-Log "Testing Docker installation..."
    
    try {
        # Test Docker
        $DockerVersion = docker version --format "{{.Server.Version}}"
        Write-Log "Docker version: $DockerVersion" "SUCCESS"
        
        # Test Docker Compose
        $ComposeVersion = docker-compose version --short
        Write-Log "Docker Compose version: $ComposeVersion" "SUCCESS"
        
        # Test with simple container
        Write-Log "Testing with hello-world container..."
        docker run --rm hello-world
        
        Write-Log "Docker test successful" "SUCCESS"
    }
    catch {
        Write-Log "Error testing Docker: $($_.Exception.Message)" "ERROR"
    }
}

function Install-DockerInWSL {
    Write-Log "Installing Docker in WSL Ubuntu..."
    
    try {
        # Check if WSL is available
        $null = Get-Command wsl -ErrorAction Stop
        
        # Script to install Docker in WSL
        $WSLScript = @"
#!/bin/bash
set -e

echo "Installing Docker in WSL Ubuntu..."

# Update packages
sudo apt update

# Install dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update packages
sudo apt update

# Install Docker
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker \$USER

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

echo "Docker installed in WSL Ubuntu successfully"
echo "Note: Restart your WSL session for group changes to take effect"
"@
        
        # Save script temporarily
        $ScriptPath = "$env:TEMP\install_docker_wsl.sh"
        $WSLScript | Set-Content -Path $ScriptPath -Encoding UTF8
        
        # Execute script in WSL
        wsl -d Ubuntu -e bash $ScriptPath
        
        # Cleanup
        Remove-Item $ScriptPath -Force
        
        Write-Log "Docker installed in WSL Ubuntu successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Docker in WSL: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "=== Docker Desktop Installation ==="
    
    # Check if Docker is already installed
    if ((Test-DockerInstalled) -and (-not $Force)) {
        Write-Log "Docker is already installed" "INFO"
        Test-DockerInstallation
        return
    }
    
    try {
        # Check WSL2
        if (-not (Test-WSL2Available)) {
            Write-Log "WSL2 required for Docker Desktop" "WARN"
            Write-Log "Installing WSL2..."
            Enable-DockerFeatures
        }
        
        # Try to install via winget first
        try {
            Install-DockerDesktopViaWinget
        }
        catch {
            Write-Log "Failed to install via winget, trying direct download..." "WARN"
            Install-DockerDesktopViaDownload
        }
        
        # Verify installation
        if (-not (Test-DockerDesktopInstalled)) {
            throw "Docker Desktop could not be installed"
        }
        
        # Configure Docker Desktop
        Set-DockerDesktopConfiguration
        
        # Start Docker Desktop
        Start-DockerDesktop
        
        # Test installation
        Test-DockerInstallation
        
        # Install Docker in WSL
        Install-DockerInWSL
        
        Write-Log "Docker Desktop installed and configured successfully" "SUCCESS"
        Write-Log "Restart required to finalize installation" "WARN"
        
    }
    catch {
        Write-Log "Error installing Docker Desktop: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Execution
Main