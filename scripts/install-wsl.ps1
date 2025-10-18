# Installation and configuration of WSL with Ubuntu Latest
# WSL (Windows Subsystem for Linux) allows running Linux environment on Windows

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    $LogPath = Join-Path $PSScriptRoot "..\logs\wsl.log"
    Add-Content -Path $LogPath -Value $LogMessage
}

function Test-WSLInstalled {
    try {
        $null = Get-Command wsl -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Test-WSLFeatureEnabled {
    $Feature = Get-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -ErrorAction SilentlyContinue
    return $Feature.State -eq "Enabled"
}

function Test-VirtualMachinePlatformEnabled {
    $Feature = Get-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -ErrorAction SilentlyContinue
    return $Feature.State -eq "Enabled"
}

function Enable-WSLFeatures {
    Write-Log "Enabling WSL features..."
    
    try {
        # Enable WSL
        if (-not (Test-WSLFeatureEnabled)) {
            Write-Log "Enabling Microsoft-Windows-Subsystem-Linux..."
            Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart
        }
        
        # Enable Virtual Machine Platform for WSL2
        if (-not (Test-VirtualMachinePlatformEnabled)) {
            Write-Log "Enabling VirtualMachinePlatform..."
            Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -NoRestart
        }
        
        Write-Log "WSL features enabled" "SUCCESS"
    }
    catch {
        Write-Log "Error enabling WSL features: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-WSLKernelUpdate {
    Write-Log "Installing WSL kernel update..."
    
    try {
        $KernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
        $DownloadPath = "$env:TEMP\wsl_update.msi"
        
        # Download kernel update
        Write-Log "Downloading WSL kernel update..."
        Invoke-WebRequest -Uri $KernelUrl -OutFile $DownloadPath -UseBasicParsing
        
        # Install update
        Write-Log "Installing kernel update..."
        Start-Process msiexec.exe -ArgumentList "/i `"$DownloadPath`" /quiet" -Wait
        
        # Cleanup
        Remove-Item $DownloadPath -Force
        
        Write-Log "WSL kernel update installed" "SUCCESS"
    }
    catch {
        Write-Log "Error installing kernel update: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Set-WSL2AsDefault {
    Write-Log "Setting WSL2 as default version..."
    
    try {
        wsl --set-default-version 2
        Write-Log "WSL2 set as default version" "SUCCESS"
    }
    catch {
        Write-Log "Error setting WSL2 as default: $($_.Exception.Message)" "ERROR"
    }
}

function Install-UbuntuLatest {
    Write-Log "Installing Ubuntu Latest..."
    
    try {
        # List available Ubuntu distributions
        Write-Log "Fetching available Ubuntu distributions..."
        $UbuntuDistros = wsl --list --online | Where-Object { $_ -match "Ubuntu" }
        Start-Sleep -Seconds 5 # Add a small delay to ensure the command completes
        
        if ($UbuntuDistros.Count -eq 0) {
            throw "No Ubuntu distribution found"
        }
        
        # Take the first Ubuntu distribution (usually the latest)
        $UbuntuDistro = ($UbuntuDistros[0] -split '\s+')[0]
        Write-Log "Installing distribution: $UbuntuDistro"
        
        # Install Ubuntu
        wsl --install -d $UbuntuDistro --no-launch
        
        Write-Log "Ubuntu installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Ubuntu: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Set-UbuntuConfiguration {
    Write-Log "Configuring Ubuntu..."
    
    try {
        # Get Ubuntu distribution name
        $UbuntuDistro = (wsl --list --quiet | Where-Object { $_ -match "Ubuntu" })[0]
        
        if (-not $UbuntuDistro) {
            Write-Log "No Ubuntu distribution found for configuration" "WARN"
            return
        }
        
        # Create WSL configuration file
        $WSLConfigPath = "$env:USERPROFILE\.wslconfig"
        $WSLConfig = @"
[wsl2]
memory=4GB
processors=2
swap=2GB
localhostForwarding=true
"@
        
        if (-not (Test-Path $WSLConfigPath) -or (Compare-Object ($WSLConfig -split '\r?\n') (Get-Content $WSLConfigPath))) {
            $WSLConfig | Set-Content -Path $WSLConfigPath -Encoding UTF8
            Write-Log "WSL configuration saved in $WSLConfigPath" "SUCCESS"
        } else {
            Write-Log "WSL configuration is already up to date." "INFO"
        }
        
        # Create Ubuntu configuration file
        $UbuntuConfigPath = "..\config\wsl.conf"
        $UbuntuConfig = @"
[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true

[user]
default = $env:USERNAME
"@
        
        if (-not (Test-Path $UbuntuConfigPath) -or (Compare-Object ($UbuntuConfig -split '\r?\n') (Get-Content $UbuntuConfigPath))) {
            $UbuntuConfig | Set-Content -Path $UbuntuConfigPath -Encoding UTF8
            Write-Log "Ubuntu configuration saved in $UbuntuConfigPath" "SUCCESS"
        } else {
            Write-Log "Ubuntu configuration is already up to date." "INFO"
        }
        
    }
    catch {
        Write-Log "Error configuring Ubuntu: $($_.Exception.Message)" "ERROR"
    }
}

function Update-UbuntuPackages {
    Write-Log "Updating Ubuntu packages..."
    
    try {
        # Update packages
        wsl -d Ubuntu -e bash -c "sudo apt update && sudo apt upgrade -y"
        
        # Install essential packages
        $EssentialPackages = @(
            "curl",
            "wget",
            "git",
            "vim",
            "htop",
            "tree",
            "unzip",
            "zip"
        )
        
        $PackagesString = $EssentialPackages -join " "
        wsl -d Ubuntu -e bash -c "sudo apt install -y $PackagesString"
        
        Write-Log "Ubuntu packages updated and installed" "SUCCESS"
    }
    catch {
        Write-Log "Error updating Ubuntu packages: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "=== WSL Ubuntu Latest Installation ==="
    
    # Check if WSL is already installed
    if ((Test-WSLInstalled) -and (-not $Force)) {
        Write-Log "WSL is already installed" "INFO"
        
        # Check if Ubuntu is installed
        $UbuntuInstalled = wsl --list --quiet | Where-Object { $_ -match "Ubuntu" }
        if ($UbuntuInstalled) {
            Write-Log "Ubuntu is already installed" "INFO"
            Set-UbuntuConfiguration
            Update-UbuntuPackages
            return
        }
    }
    
    try {
        # Enable WSL features
        Enable-WSLFeatures

        # Check if a restart is required for WSL to function
        try {
            wsl --status > $null
        } catch {
            Write-Log "A system restart is required to enable WSL. Please restart your computer and run the script again." "WARN"
            throw "Restart required for WSL."
        }
        
        # Install WSL kernel update
        Install-WSLKernelUpdate
        
        # Set WSL2 as default version
        Set-WSL2AsDefault
        
        # Install Ubuntu
        Install-UbuntuLatest
        
        # Configure Ubuntu
        Set-UbuntuConfiguration
        
        # Update Ubuntu packages
        Update-UbuntuPackages
        
        Write-Log "WSL Ubuntu installed and configured successfully" "SUCCESS"
        Write-Log "Restart required to finalize installation" "WARN"
        
    }
    catch {
        Write-Log "Error installing WSL: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Execution
Main