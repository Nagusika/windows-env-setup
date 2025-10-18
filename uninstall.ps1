# Windows Environment Uninstall Script
# Allows clean uninstallation of all installed components

param(
    [switch]$KeepWSL,
    [switch]$KeepDocker,
    [switch]$KeepFonts,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"
$LogDir = "logs"

# Create logs directory if it doesn't exist
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force }

# Logging function
function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    Write-Host $LogMessage
    Add-Content -Path "$LogDir\uninstall.log" -Value $LogMessage
}

# Function to uninstall winget
function Uninstall-Winget {
    Write-Log "Uninstalling winget..."
    try {
        # Uninstall winget via PowerShell
        Get-AppxPackage -Name "Microsoft.DesktopAppInstaller" | Remove-AppxPackage
        Write-Log "winget uninstalled successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error uninstalling winget: $($_.Exception.Message)" "ERROR"
    }
}

# Function to uninstall WSL
function Uninstall-WSL {
    if ($KeepWSL) {
        Write-Log "WSL uninstallation skipped" "SKIP"
        return
    }
    
    Write-Log "Uninstalling WSL..."
    try {
        # Uninstall all WSL distributions
        wsl --list --quiet | ForEach-Object {
            if ($_ -match "Ubuntu") {
                Write-Log "Uninstalling distribution: $_"
                wsl --unregister $_
            }
        }
        
        # Disable WSL features
        Disable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart
        Disable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -NoRestart
        
        Write-Log "WSL uninstalled successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error uninstalling WSL: $($_.Exception.Message)" "ERROR"
    }
}

# Function to uninstall Windows Terminal
function Uninstall-WindowsTerminal {
    Write-Log "Uninstalling Windows Terminal..."
    try {
        # Uninstall Windows Terminal
        Get-AppxPackage -Name "Microsoft.WindowsTerminal" | Remove-AppxPackage
        
        # Remove configuration files
        $ConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe"
        if (Test-Path $ConfigPath) {
            Remove-Item $ConfigPath -Recurse -Force
        }
        
        Write-Log "Windows Terminal uninstalled successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error uninstalling Windows Terminal: $($_.Exception.Message)" "ERROR"
    }
}

# Function to uninstall NerdFonts
function Uninstall-NerdFonts {
    if ($KeepFonts) {
        Write-Log "NerdFonts uninstallation skipped" "SKIP"
        return
    }
    
    Write-Log "Uninstalling NerdFonts..."
    try {
        # List of NerdFonts to uninstall
        $NerdFonts = @(
            "Cascadia Code",
            "Fira Code",
            "JetBrains Mono",
            "Source Code Pro",
            "Hack",
            "Mononoki",
            "Roboto Mono",
            "Ubuntu Mono"
        )
        
        foreach ($FontName in $NerdFonts) {
            # Remove font files
            $FontFiles = Get-ChildItem -Path "$env:WINDIR\Fonts" -Filter "*$FontName*" -ErrorAction SilentlyContinue
            foreach ($FontFile in $FontFiles) {
                Write-Log "Removing font: $($FontFile.Name)"
                Remove-Item $FontFile.FullName -Force
            }
            
            # Remove registry entries
            $RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
            $RegEntries = Get-ItemProperty -Path $RegPath | Get-Member -MemberType NoteProperty | Where-Object { $_.Name -like "*$FontName*" }
            foreach ($Entry in $RegEntries) {
                Write-Log "Removing registry entry: $($Entry.Name)"
                Remove-ItemProperty -Path $RegPath -Name $Entry.Name -Force
            }
        }
        
        Write-Log "NerdFonts uninstalled successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error uninstalling NerdFonts: $($_.Exception.Message)" "ERROR"
    }
}

# Function to uninstall Docker Desktop
function Uninstall-DockerDesktop {
    if ($KeepDocker) {
        Write-Log "Docker Desktop uninstallation skipped" "SKIP"
        return
    }
    
    Write-Log "Uninstalling Docker Desktop..."
    try {
        # Stop Docker Desktop
        Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue | Stop-Process -Force
        
        # Uninstall Docker Desktop
        $DockerUninstaller = Get-ChildItem -Path "C:\Program Files\Docker\Docker" -Filter "uninstall.exe" -ErrorAction SilentlyContinue
        if ($DockerUninstaller) {
            Start-Process -FilePath $DockerUninstaller.FullName -ArgumentList "/S" -Wait
        }
        
        # Remove configuration files
        $ConfigPath = "$env:APPDATA\Docker"
        if (Test-Path $ConfigPath) {
            Remove-Item $ConfigPath -Recurse -Force
        }
        
        # Remove data files
        $DataPath = "$env:LOCALAPPDATA\Docker"
        if (Test-Path $DataPath) {
            Remove-Item $DataPath -Recurse -Force
        }
        
        Write-Log "Docker Desktop uninstalled successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error uninstalling Docker Desktop: $($_.Exception.Message)" "ERROR"
    }
}

# Function to clean configuration files
function Remove-ConfigurationFiles {
    Write-Log "Removing configuration files..."
    try {
        # Remove configuration directory
        if (Test-Path "config") {
            Remove-Item "config" -Recurse -Force
        }
        
        # Remove logs directory
        if (Test-Path "logs") {
            Remove-Item "logs" -Recurse -Force
        }
        
        # Remove WSL configuration files
        $WSLConfigPath = "$env:USERPROFILE\.wslconfig"
        if (Test-Path $WSLConfigPath) {
            Remove-Item $WSLConfigPath -Force
        }
        
        Write-Log "Configuration files removed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error removing configuration files: $($_.Exception.Message)" "ERROR"
    }
}

# Main function
function Main {
    Write-Log "=== Starting Windows Environment Uninstallation ==="
    
    try {
        Uninstall-DockerDesktop
        Uninstall-NerdFonts
        Uninstall-WSL
        Uninstall-WindowsTerminal
        Uninstall-Winget
        Remove-ConfigurationFiles
        
        Write-Log "=== Uninstallation completed successfully ===" "SUCCESS"
        Write-Log "Restart recommended to finalize uninstallation"
        
        $Restart = Read-Host "Do you want to restart now? (y/N)"
        if ($Restart -eq "y" -or $Restart -eq "Y") {
            Restart-Computer -Force
        }
    }
    catch {
        Write-Log "=== Uninstallation failed ===" "ERROR"
        Write-Log "Error: $($_.Exception.Message)" "ERROR"
        exit 1
    }
}

# Execution
Main