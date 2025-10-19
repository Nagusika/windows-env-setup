# Cleanup Komorebi - Remove test files and keep only final config

Write-Host "Cleaning up Komorebi test files..." -ForegroundColor Cyan

$komorebiDir = "$env:USERPROFILE\.config\komorebi"

# Files to keep
$keepFiles = @(
    "komorebi.json",
    "komorebi-ultimate.ahk",
    "komorebi-startup.ahk",
    "applications.yaml",
    "show-help.ps1",
    "switch-theme.ps1"
)

# Get all .ahk files
$allFiles = Get-ChildItem $komorebiDir -Filter "*.ahk"

foreach ($file in $allFiles) {
    if ($keepFiles -notcontains $file.Name) {
        Write-Host "  Removing: $($file.Name)" -ForegroundColor Yellow
        Remove-Item $file.FullName -Force
    }
}

# Remove temp repo
if (Test-Path "C:\Users\nagusi\temp-ahk-winkey") {
    Write-Host "  Removing temp repo..." -ForegroundColor Yellow
    Remove-Item "C:\Users\nagusi\temp-ahk-winkey" -Recurse -Force
}

Write-Host ""
Write-Host "✓ Cleanup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Kept files:" -ForegroundColor Cyan
Get-ChildItem $komorebiDir | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
