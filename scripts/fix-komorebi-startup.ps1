# Fix Komorebi Startup Configuration
# This script ensures Komorebi starts automatically on Windows login

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Color = switch ($Level) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "INFO" { "Cyan" }
        default { "White" }
    }
    Write-Host "[$Level] $Message" -ForegroundColor $Color
}

Write-Host ""
Write-Host "=== Komorebi Startup Fix ===" -ForegroundColor Cyan
Write-Host ""

# Check if Komorebi is installed
Write-Log "Checking Komorebi installation..." "INFO"
$komorebicPath = $null

# Try to find komorebic
try {
    $komorebicCmd = Get-Command komorebic -ErrorAction Stop
    $komorebicPath = $komorebicCmd.Source
    Write-Log "Found komorebic at: $komorebicPath" "SUCCESS"
}
catch {
    # Search in common locations
    $searchPaths = @(
        "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\LGUG2Z.komorebi*",
        "$env:LOCALAPPDATA\Programs\komorebi",
        "$env:ProgramFiles\komorebi"
    )
    
    foreach ($searchPath in $searchPaths) {
        $found = Get-ChildItem -Path $searchPath -Filter "komorebic.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($found) {
            $komorebicPath = $found.FullName
            Write-Log "Found komorebic at: $komorebicPath" "SUCCESS"
            break
        }
    }
}

if (-not $komorebicPath) {
    Write-Log "Komorebi not found! Please install it first." "ERROR"
    exit 1
}

# Check AutoHotkey
Write-Log "Checking AutoHotkey installation..." "INFO"
$ahkPath = $null

# Try Get-Command first
try {
    $ahkCmd = Get-Command autohotkey -ErrorAction Stop
    $ahkPath = $ahkCmd.Source
    Write-Log "Found AutoHotkey in PATH: $ahkPath" "SUCCESS"
}
catch {
    Write-Log "AutoHotkey not in PATH, searching common locations..." "INFO"
}

# If not found in PATH, search common locations
if (-not $ahkPath) {
    $searchPaths = @(
        "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey.exe",
        "$env:LOCALAPPDATA\Programs\AutoHotkey\AutoHotkey.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe",
        "$env:ProgramFiles\AutoHotkey\AutoHotkey.exe",
        "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey64.exe",
        "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey.exe",
        "${env:ProgramFiles(x86)}\AutoHotkey\AutoHotkey.exe"
    )
    
    foreach ($searchPath in $searchPaths) {
        if (Test-Path $searchPath) {
            $ahkPath = $searchPath
            Write-Log "Found AutoHotkey at: $ahkPath" "SUCCESS"
            break
        }
    }
    
    # If still not found, try wildcard search
    if (-not $ahkPath) {
        $searchDirs = @(
            "$env:LOCALAPPDATA\Programs\AutoHotkey",
            "$env:ProgramFiles\AutoHotkey",
            "${env:ProgramFiles(x86)}\AutoHotkey"
        )
        
        foreach ($dir in $searchDirs) {
            if (Test-Path $dir) {
                $found = Get-ChildItem -Path $dir -Filter "AutoHotkey*.exe" -Recurse -ErrorAction SilentlyContinue | 
                         Where-Object { $_.Name -match "AutoHotkey(64)?\.exe$" } | 
                         Select-Object -First 1
                if ($found) {
                    $ahkPath = $found.FullName
                    Write-Log "Found AutoHotkey at: $ahkPath" "SUCCESS"
                    break
                }
            }
        }
    }
}

# If still not found, try to install
if (-not $ahkPath) {
    Write-Log "AutoHotkey not found! Installing..." "WARN"
    $installResult = winget install -e --id AutoHotkey.AutoHotkey --silent --accept-package-agreements --accept-source-agreements 2>&1
    
    # Wait for installation
    Start-Sleep -Seconds 5
    
    # Search again after installation
    $searchPaths = @(
        "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe"
    )
    
    foreach ($searchPath in $searchPaths) {
        if (Test-Path $searchPath) {
            $ahkPath = $searchPath
            Write-Log "AutoHotkey installed at: $ahkPath" "SUCCESS"
            break
        }
    }
    
    if (-not $ahkPath) {
        Write-Log "Failed to find AutoHotkey after installation" "ERROR"
        Write-Log "Please install AutoHotkey manually from: https://www.autohotkey.com/" "ERROR"
        exit 1
    }
}

# Check startup script
$startupScriptPath = "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
Write-Log "Checking startup script..." "INFO"

if (-not (Test-Path $startupScriptPath)) {
    Write-Log "Startup script not found at: $startupScriptPath" "ERROR"
    Write-Log "Please run the full Komorebi installation first" "ERROR"
    exit 1
}

Write-Log "Startup script found" "SUCCESS"

# Create/Update startup shortcut
$startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$shortcutPath = Join-Path $startupFolder "Komorebi.lnk"

Write-Log "Creating startup shortcut..." "INFO"

try {
    # Remove old shortcut if exists
    if (Test-Path $shortcutPath) {
        Remove-Item $shortcutPath -Force
        Write-Log "Removed old shortcut" "INFO"
    }
    
    # Create new shortcut
    $WshShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $ahkPath
    $Shortcut.Arguments = "`"$startupScriptPath`""
    $Shortcut.WorkingDirectory = "$env:USERPROFILE\.config\komorebi"
    $Shortcut.Description = "Komorebi Tiling Window Manager"
    $Shortcut.IconLocation = "$komorebicPath,0"
    $Shortcut.Save()
    
    Write-Log "Startup shortcut created successfully" "SUCCESS"
    Write-Log "Location: $shortcutPath" "INFO"
}
catch {
    Write-Log "Error creating shortcut: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Verify shortcut
if (Test-Path $shortcutPath) {
    Write-Log "Shortcut verified" "SUCCESS"
}
else {
    Write-Log "Shortcut verification failed" "ERROR"
    exit 1
}

# Test startup script
Write-Log "Testing startup script..." "INFO"
Write-Log "Checking if Komorebi is already running..." "INFO"

$komorebiProcess = Get-Process -Name komorebi -ErrorAction SilentlyContinue
if ($komorebiProcess) {
    Write-Log "Komorebi is already running (PID: $($komorebiProcess.Id))" "INFO"
    $response = Read-Host "Do you want to restart Komorebi now to test? (y/N)"
    
    if ($response -eq 'y' -or $response -eq 'Y') {
        Write-Log "Stopping Komorebi..." "INFO"
        Stop-Process -Name komorebi -Force -ErrorAction SilentlyContinue
        Stop-Process -Name autohotkey -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        
        Write-Log "Starting Komorebi..." "INFO"
        Start-Process -FilePath $ahkPath -ArgumentList "`"$startupScriptPath`"" -WindowStyle Hidden
        Start-Sleep -Seconds 5
        
        $newProcess = Get-Process -Name komorebi -ErrorAction SilentlyContinue
        if ($newProcess) {
            Write-Log "Komorebi started successfully!" "SUCCESS"
        }
        else {
            Write-Log "Failed to start Komorebi" "ERROR"
        }
    }
}
else {
    Write-Log "Komorebi is not running. Starting now..." "INFO"
    Start-Process -FilePath $ahkPath -ArgumentList "`"$startupScriptPath`"" -WindowStyle Hidden
    Start-Sleep -Seconds 5
    
    $newProcess = Get-Process -Name komorebi -ErrorAction SilentlyContinue
    if ($newProcess) {
        Write-Log "Komorebi started successfully!" "SUCCESS"
    }
    else {
        Write-Log "Failed to start Komorebi" "ERROR"
        Write-Log "Check the startup script for errors" "WARN"
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "✓ Komorebi: " -NoNewline -ForegroundColor Green
Write-Host $komorebicPath
Write-Host "✓ AutoHotkey: " -NoNewline -ForegroundColor Green
Write-Host $ahkPath
Write-Host "✓ Startup Script: " -NoNewline -ForegroundColor Green
Write-Host $startupScriptPath
Write-Host "✓ Startup Shortcut: " -NoNewline -ForegroundColor Green
Write-Host $shortcutPath
Write-Host ""
Write-Host "Komorebi will now start automatically on Windows login!" -ForegroundColor Green
Write-Host ""
Write-Host "To manually start Komorebi:" -ForegroundColor Yellow
Write-Host "  & '$ahkPath' '$startupScriptPath'" -ForegroundColor White
Write-Host ""
Write-Host "To stop Komorebi:" -ForegroundColor Yellow
Write-Host "  komorebic stop" -ForegroundColor White
Write-Host "  Stop-Process -Name komorebi,autohotkey -Force" -ForegroundColor White
Write-Host ""
