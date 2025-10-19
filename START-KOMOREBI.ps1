# START KOMOREBI - Quick Launch Script
# Run this to start Komorebi with all features

Write-Host ""
Write-Host "🚀 Starting Komorebi..." -ForegroundColor Cyan
Write-Host ""

# Stop old processes
Stop-Process -Name komorebi,autohotkey,zebar -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Start Komorebi
Write-Host "[1/3] Starting Komorebi..." -ForegroundColor Yellow
Start-Process -FilePath "komorebic.exe" -ArgumentList "start" -WindowStyle Hidden
Start-Sleep -Seconds 5

# Load configuration
Write-Host "[2/3] Loading configuration..." -ForegroundColor Yellow
$configPath = Join-Path $env:USERPROFILE ".config\komorebi\komorebi.json"
& komorebic configuration $configPath
Start-Sleep -Seconds 2

# Load AutoHotkey shortcuts
Write-Host "[3/3] Loading shortcuts..." -ForegroundColor Yellow
$ahkPath = "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
$shortcutsPath = Join-Path $env:USERPROFILE ".config\komorebi\komorebi.ahk"
Start-Process -FilePath $ahkPath -ArgumentList "`"$shortcutsPath`"" -WindowStyle Hidden
Start-Sleep -Seconds 2

# Check status
Write-Host ""
Write-Host "✅ Komorebi is ready!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Quick Reference:" -ForegroundColor Yellow
Write-Host "  Win+H/J/K/L        - Navigate windows (hold Win for multiple)" -ForegroundColor White
Write-Host "  Shift+Win+H/J/K/L  - Move windows" -ForegroundColor White
Write-Host "  Win+1/2/3/4/5      - Switch workspace" -ForegroundColor White
Write-Host "  Win+Enter          - Open terminal" -ForegroundColor White
Write-Host "  Win+Q              - Close window" -ForegroundColor White
Write-Host "  Win+T              - Toggle float" -ForegroundColor White
Write-Host "  Win+F              - Toggle fullscreen" -ForegroundColor White
Write-Host ""
Write-Host "💡 Win key alone does NOT open Start Menu!" -ForegroundColor Cyan
Write-Host ""
