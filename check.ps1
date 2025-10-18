# Windows Environment Check Script
# Verifies that all components are correctly installed and configured

param(
    [switch]$Verbose,
    [switch]$Fix
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
    Add-Content -Path "$LogDir\check.log" -Value $LogMessage
}

# Function to check winget
function Test-WingetStatus {
    Write-Log "Checking winget..."
    
    try {
        $null = Get-Command winget -ErrorAction Stop
        $Version = winget --version
        Write-Log "[OK] winget installed - Version: $Version" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "[FAIL] winget not installed or not accessible" "ERROR"
        return $false
    }
}

# Function to check WSL
function Test-WSLStatus {
    Write-Log "Checking WSL..."
    
    try {
        $null = Get-Command wsl -ErrorAction Stop
        $WSLVersion = wsl --version
        $UbuntuInstalled = wsl --list --quiet | Where-Object { $_ -match "Ubuntu" }
        
        if ($UbuntuInstalled) {
            Write-Log "[OK] WSL installed with Ubuntu" "SUCCESS"
            Write-Log "  WSL Version: $WSLVersion" "INFO"
            return $true
        }
        else {
            Write-Log "[WARN] WSL installed but Ubuntu not found" "WARN"
            return $false
        }
    }
    catch {
        Write-Log "[FAIL] WSL not installed" "ERROR"
        return $false
    }
}

# Function to check Windows Terminal
function Test-WindowsTerminalStatus {
    Write-Log "Checking Windows Terminal..."
    
    try {
        $TerminalApp = Get-AppxPackage -Name "Microsoft.WindowsTerminal" -ErrorAction SilentlyContinue
        if ($TerminalApp) {
            Write-Log "[OK] Windows Terminal installed - Version: $($TerminalApp.Version)" "SUCCESS"
            return $true
        }
        else {
            Write-Log "[FAIL] Windows Terminal not installed" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "[FAIL] Error checking Windows Terminal" "ERROR"
        return $false
    }
}

# Function to check NerdFonts
function Test-NerdFontsStatus {
    Write-Log "Checking NerdFonts..."
    
    try {
        $NerdFonts = @("Cascadia Code", "Fira Code", "JetBrains Mono", "Source Code Pro")
        $InstalledFonts = @()
        
        foreach ($FontName in $NerdFonts) {
            $FontFiles = Get-ChildItem -Path "$env:WINDIR\Fonts" -Filter "*$FontName*" -ErrorAction SilentlyContinue
            if ($FontFiles) {
                $InstalledFonts += $FontName
            }
        }
        
        if ($InstalledFonts.Count -gt 0) {
            Write-Log "[OK] NerdFonts installed: $($InstalledFonts -join ', ')" "SUCCESS"
            return $true
        }
        else {
            Write-Log "[FAIL] No NerdFont found" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "[FAIL] Error checking NerdFonts" "ERROR"
        return $false
    }
}

# Function to check Docker
function Test-DockerStatus {
    Write-Log "Checking Docker..."
    
    try {
        $null = Get-Command docker -ErrorAction Stop
        $DockerVersion = docker version --format "{{.Server.Version}}"
        $DockerRunning = $true
        
        try {
            docker ps | Out-Null
        }
        catch {
            $DockerRunning = $false
        }
        
        if ($DockerRunning) {
            Write-Log "[OK] Docker installed and running - Version: $DockerVersion" "SUCCESS"
            return $true
        }
        else {
            Write-Log "[WARN] Docker installed but not started" "WARN"
            return $false
        }
    }
    catch {
        Write-Log "[FAIL] Docker not installed or not accessible" "ERROR"
        return $false
    }
}

# Function to check configuration files
function Test-ConfigurationFiles {
    Write-Log "Checking configuration files..."
    
    $ConfigFiles = @(
        "config\wsl.conf",
        "config\terminal-settings.json",
        "config\docker-settings.json",
        "config\wsl-font-config.sh"
    )
    
    $MissingFiles = @()
    
    foreach ($File in $ConfigFiles) {
        if (Test-Path $File) {
            Write-Log "[OK] Configuration file found: $File" "SUCCESS"
        }
        else {
            Write-Log "[FAIL] Configuration file missing: $File" "ERROR"
            $MissingFiles += $File
        }
    }
    
    return $MissingFiles.Count -eq 0
}

# Function to check logs
function Test-LogFiles {
    Write-Log "Checking log files..."
    
    $LogFiles = @(
        "logs\install.log",
        "logs\winget.log",
        "logs\wsl.log",
        "logs\terminal.log",
        "logs\nerdfonts.log",
        "logs\docker.log"
    )
    
    $LogCount = 0
    
    foreach ($File in $LogFiles) {
        if (Test-Path $File) {
            $LogCount++
            Write-Log "[OK] Log file found: $File" "SUCCESS"
        }
    }
    
    if ($LogCount -gt 0) {
        Write-Log "[OK] $LogCount log file(s) found" "SUCCESS"
        return $true
    }
    else {
        Write-Log "[WARN] No log files found" "WARN"
        return $false
    }
}

# Function to display summary
function Show-Summary {
    param($Results)
    
    Write-Log "=== VERIFICATION SUMMARY ===" "INFO"
    
    $Total = $Results.Count
    $Success = ($Results | Where-Object { $_ -eq $true }).Count
    $Failed = $Total - $Success
    
    Write-Log "Total checks: $Total" "INFO"
    Write-Log "Successful: $Success" "SUCCESS"
    Write-Log "Failed: $Failed" "ERROR"
    
    if ($Failed -eq 0) {
        Write-Log "[OK] All components are correctly installed and configured" "SUCCESS"
    }
    else {
        Write-Log "[FAIL] Some components require attention" "ERROR"
    }
}

# Main function
function Main {
    Write-Log "=== Windows Environment Verification ==="
    
    $Results = @()
    
    # Check each component
    $Results += Test-WingetStatus
    $Results += Test-WSLStatus
    $Results += Test-WindowsTerminalStatus
    $Results += Test-NerdFontsStatus
    $Results += Test-DockerStatus
    $Results += Test-ConfigurationFiles
    $Results += Test-LogFiles
    
    # Display summary
    Show-Summary $Results
    
    # Exit code
    $Failed = ($Results | Where-Object { $_ -eq $false }).Count
    if ($Failed -eq 0) {
        exit 0
    }
    else {
        exit 1
    }
}

# Execution
Main