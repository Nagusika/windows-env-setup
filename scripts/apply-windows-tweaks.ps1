#Requires -Version 5.1
# Apply declarative Windows personalization tweaks: dark mode and a minimal,
# left-aligned taskbar (Windows icon + pinned apps + clock, no search/widgets).
#
# Every tweak is under HKCU, so NO administrator rights are required.
# Idempotent: safe to re-run. Use -DryRun to preview without changing anything.

param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot '..\WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot '..\logs\windows-tweaks.log')

function Main {
    Write-Log "=== Windows personalization tweaks ==="

    $manifestPath = Join-Path $PSScriptRoot '..\config\windows-tweaks.json'
    if (-not (Test-Path $manifestPath)) { throw "Tweaks manifest not found: $manifestPath" }
    $tweaks = (Get-Content -Path $manifestPath -Raw | ConvertFrom-Json).tweaks

    $applied = 0
    foreach ($t in $tweaks) {
        if ($DryRun) {
            Write-Log "[dry-run] $($t.desc): $($t.path)\$($t.name) = $($t.value)" "INFO"
            continue
        }
        try {
            if (-not (Test-Path $t.path)) { New-Item -Path $t.path -Force | Out-Null }
            Set-ItemProperty -Path $t.path -Name $t.name -Type $t.type -Value $t.value -Force
            Write-Log "$($t.desc)" "SUCCESS"
            $applied++
        }
        catch {
            Write-Log "Failed: $($t.desc) - $($_.Exception.Message)" "WARN"
        }
    }

    if ($DryRun) {
        Write-Log "Dry run complete - no changes made" "INFO"
        return
    }

    Write-Log "Restarting Explorer to apply taskbar changes..."
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    # Windows automatically restarts explorer.exe.

    Write-Log "$applied Windows tweak(s) applied" "SUCCESS"
    Write-Log "Some changes (e.g. dark mode in older apps) may need a sign-out to fully apply" "INFO"
}

Main
