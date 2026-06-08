#Requires -Version 5.1
# Windows Environment Check - verifies the key components are actually installed.
# The verdict is based on real system state (binaries / Appx / font registry),
# not on the presence of repo-local files.

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot 'WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot 'logs\check.log')

function Test-WingetStatus {
    Write-Log "Checking winget..."
    if (Test-CommandExists 'winget') {
        $version = (winget --version) 2>$null
        Write-Log "[OK] winget installed - $version" "SUCCESS"
        return $true
    }
    Write-Log "[FAIL] winget not installed or not accessible" "ERROR"
    return $false
}

function Test-GitStatus {
    Write-Log "Checking Git..."
    if (Test-CommandExists 'git') {
        Write-Log "[OK] Git installed - $((git --version) 2>$null)" "SUCCESS"
        return $true
    }
    Write-Log "[FAIL] Git not installed" "ERROR"
    return $false
}

function Test-WSLStatus {
    Write-Log "Checking WSL..."
    if (-not (Test-CommandExists 'wsl')) {
        Write-Log "[FAIL] WSL not installed" "ERROR"
        return $false
    }
    $ubuntu = wsl --list --quiet 2>$null | Where-Object { $_ -match "Ubuntu" }
    if ($ubuntu) {
        Write-Log "[OK] WSL installed with Ubuntu" "SUCCESS"
        return $true
    }
    Write-Log "[WARN] WSL installed but Ubuntu not found" "WARN"
    return $false
}

function Test-WindowsTerminalStatus {
    Write-Log "Checking Windows Terminal..."
    $app = Get-AppxPackage -Name "Microsoft.WindowsTerminal" -ErrorAction SilentlyContinue
    if ($app) {
        Write-Log "[OK] Windows Terminal installed - Version: $($app.Version)" "SUCCESS"
        return $true
    }
    Write-Log "[FAIL] Windows Terminal not installed" "ERROR"
    return $false
}

function Test-NerdFontsStatus {
    Write-Log "Checking NerdFonts..."
    try {
        # Nerd Fonts installed by this project register under a name containing
        # "NerdFont" (e.g. CaskaydiaCoveNerdFont-Regular), in HKLM (machine) or HKCU (user).
        $scopes = @(
            'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts',
            'HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts'
        )
        $installed = @()
        foreach ($scope in $scopes) {
            if (Test-Path $scope) {
                $installed += (Get-ItemProperty -Path $scope).PSObject.Properties |
                    Where-Object { $_.Name -like '*NerdFont*' } | ForEach-Object { $_.Name }
            }
        }

        if ($installed.Count -gt 0) {
            Write-Log "[OK] Nerd Fonts installed: $($installed.Count) registered" "SUCCESS"
            return $true
        }
        Write-Log "[FAIL] No Nerd Font found" "ERROR"
        return $false
    }
    catch {
        Write-Log "[FAIL] Error checking NerdFonts: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-DockerStatus {
    Write-Log "Checking Docker..."
    if (-not (Test-CommandExists 'docker')) {
        Write-Log "[FAIL] Docker not installed or not accessible" "ERROR"
        return $false
    }
    docker info 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Log "[OK] Docker installed and running" "SUCCESS"
        return $true
    }
    Write-Log "[WARN] Docker installed but not running" "WARN"
    return $false
}

function Show-Summary {
    param($Results)

    Write-Log "=== VERIFICATION SUMMARY ===" "INFO"
    $total = $Results.Count
    $success = ($Results | Where-Object { $_ -eq $true }).Count
    $failed = $total - $success

    Write-Log "Total checks: $total" "INFO"
    Write-Log "Successful: $success" "SUCCESS"
    Write-Log "Failed: $failed" "ERROR"

    if ($failed -eq 0) {
        Write-Log "[OK] All checked components are installed" "SUCCESS"
    }
    else {
        Write-Log "[FAIL] Some components require attention" "ERROR"
    }
}

function Main {
    Write-Log "=== Windows Environment Verification ==="

    $Results = @()
    $Results += Test-WingetStatus
    $Results += Test-GitStatus
    $Results += Test-WSLStatus
    $Results += Test-WindowsTerminalStatus
    $Results += Test-NerdFontsStatus
    $Results += Test-DockerStatus

    Show-Summary $Results

    if (($Results | Where-Object { $_ -eq $false }).Count -eq 0) { exit 0 } else { exit 1 }
}

Main
