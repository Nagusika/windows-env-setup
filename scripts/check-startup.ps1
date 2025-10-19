# Check Startup Configuration

Write-Host ""
Write-Host "=== Komorebi Startup Configuration ===" -ForegroundColor Cyan
Write-Host ""

$startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$shortcutPath = Join-Path $startupFolder "Komorebi.lnk"

if (Test-Path $shortcutPath) {
    Write-Host "✅ Startup shortcut exists" -ForegroundColor Green
    Write-Host "   Location: $shortcutPath" -ForegroundColor Gray
    
    # Read shortcut details
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    
    Write-Host ""
    Write-Host "Shortcut Details:" -ForegroundColor Cyan
    Write-Host "  Target: $($shortcut.TargetPath)" -ForegroundColor White
    Write-Host "  Arguments: $($shortcut.Arguments)" -ForegroundColor White
    Write-Host "  Working Dir: $($shortcut.WorkingDirectory)" -ForegroundColor White
    
    # Check if files exist
    Write-Host ""
    Write-Host "File Checks:" -ForegroundColor Cyan
    
    if (Test-Path $shortcut.TargetPath) {
        Write-Host "  ✅ AutoHotkey found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ AutoHotkey NOT found" -ForegroundColor Red
    }
    
    $ahkScript = $shortcut.Arguments.Trim('"')
    if (Test-Path $ahkScript) {
        Write-Host "  ✅ Startup script found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Startup script NOT found" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "✅ Komorebi will start automatically on Windows login!" -ForegroundColor Green
    
} else {
    Write-Host "❌ Startup shortcut NOT found" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run this to create it:" -ForegroundColor Yellow
    Write-Host "  .\scripts\fix-komorebi-startup.ps1" -ForegroundColor White
}

Write-Host ""
