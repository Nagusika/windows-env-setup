# Clean unnecessary scripts before commit

$scriptsToRemove = @(
    "scripts\clean-and-restart-komorebi.ps1",
    "scripts\consolidate-docs.ps1",
    "scripts\final-cleanup.ps1",
    "scripts\move-docs.ps1",
    "scripts\regenerate-komorebi-configs.ps1",
    "scripts\start-komorebi-complete.ps1",
    "scripts\start-komorebi-simple.ps1",
    "scripts\start-komorebi.ps1",
    "scripts\test-ahk.ps1"
)

Write-Host "Cleaning unnecessary scripts..." -ForegroundColor Cyan

foreach ($script in $scriptsToRemove) {
    if (Test-Path $script) {
        Remove-Item $script -Force
        Write-Host "  Removed: $script" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "✅ Cleanup done! Only essential scripts remain." -ForegroundColor Green
