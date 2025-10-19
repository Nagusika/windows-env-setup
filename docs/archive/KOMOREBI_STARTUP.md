# Komorebi Startup Configuration

## ✅ Automatic Startup

Komorebi is configured to start automatically when you log in to Windows.

### What Starts Automatically

1. **Komorebi** - Tiling window manager
2. **AutoHotkey** - Keyboard shortcuts handler
3. **Zebar** - Status bar (if installed)
4. **komorebi-loading** - Loading screen (if installed)

### Startup Sequence

```
1. Windows Login
   ↓
2. Wait 3 seconds (system ready)
   ↓
3. Check if Komorebi already running
   ↓
4. Start Komorebi (komorebic start)
   ↓
5. Wait 3 seconds (Komorebi ready)
   ↓
6. Load AutoHotkey config (keyboard shortcuts)
   ↓
7. Start Zebar status bar
   ↓
8. Show notification "Komorebi Started"
```

## 📁 Startup Files

### Shortcut Location
```
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk
```

**Full Path**:
```
C:\Users\YourUsername\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk
```

### Startup Script
```
%USERPROFILE%\.config\komorebi\komorebi-startup.ahk
```

**What it does**:
- Starts Komorebi process
- Loads keyboard shortcuts
- Starts Zebar
- Shows notification
- Handles errors gracefully

### Configuration Files
```
%USERPROFILE%\.config\komorebi\
├── komorebi.json           # Main Komorebi config
├── komorebi.ahk           # Keyboard shortcuts
├── komorebi-startup.ahk   # Startup script
├── applications.yaml      # App-specific rules
├── switch-theme.ps1       # Theme switcher
└── show-help.ps1          # Help overlay
```

## 🚀 Manual Start

If you want to start Komorebi without rebooting:

### Option 1: Run Startup Script
```powershell
autohotkey.exe "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

### Option 2: Start Komorebi Only
```powershell
komorebic start
```

### Option 3: Double-click Shortcut
Navigate to:
```
%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\
```
Double-click `Komorebi.lnk`

## 🛑 Stop Komorebi

### Temporary Stop
```powershell
komorebic stop
```

### Pause (without stopping)
```
Win+P
```

### Kill Process
```powershell
Stop-Process -Name komorebi -Force
Stop-Process -Name autohotkey -Force
```

## 🔄 Restart Komorebi

### Full Restart
```powershell
komorebic stop
Start-Sleep -Seconds 2
autohotkey.exe "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

### Reload Configuration Only
```
Win+Shift+C  (reloads AHK config)
```

Or:
```powershell
komorebic reload-configuration
```

## ✅ Verify Startup

### Check if Running
```powershell
# Check Komorebi process
Get-Process komorebi -ErrorAction SilentlyContinue

# Check AutoHotkey process
Get-Process autohotkey -ErrorAction SilentlyContinue

# Check Zebar process
Get-Process zebar -ErrorAction SilentlyContinue
```

### Check Startup Shortcut
```powershell
Test-Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk"
```

### Check Configuration Files
```powershell
Test-Path "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
Test-Path "$env:USERPROFILE\.config\komorebi\komorebi.json"
Test-Path "$env:USERPROFILE\.config\komorebi\komorebi.ahk"
```

## 🐛 Troubleshooting

### Komorebi Doesn't Start on Login

**Check 1: Shortcut exists**
```powershell
Get-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk"
```

**Check 2: AutoHotkey installed**
```powershell
Get-Command autohotkey -ErrorAction SilentlyContinue
```

**Check 3: Startup script exists**
```powershell
Get-Content "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

**Fix: Recreate shortcut**
```powershell
.\scripts\install-komorebi.ps1 -Force
```

### Komorebi Starts but Shortcuts Don't Work

**Cause**: AutoHotkey config not loaded

**Check**:
```powershell
Get-Process autohotkey
```

**Fix**:
```powershell
autohotkey.exe "$env:USERPROFILE\.config\komorebi\komorebi.ahk"
```

### Zebar Doesn't Start

**Check if installed**:
```powershell
Test-Path "$env:LOCALAPPDATA\Programs\Zebar\Zebar.exe"
```

**Start manually**:
```powershell
Start-Process "$env:LOCALAPPDATA\Programs\Zebar\Zebar.exe"
```

### Error Message on Startup

**Check logs**:
```powershell
# Komorebi logs
Get-Content "$env:USERPROFILE\.config\komorebi\komorebi.log" -Tail 50

# Installation logs
Get-Content ".\logs\komorebi.log" -Tail 50
```

### Komorebi Crashes on Startup

**Safe mode start**:
```powershell
# Start without configuration
komorebic start

# Then load config manually
komorebic reload-configuration
```

## 🔧 Disable Automatic Startup

### Temporary (one session)
Just close Komorebi:
```powershell
komorebic stop
```

### Permanent
Delete the startup shortcut:
```powershell
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk"
```

### Re-enable Later
Run the installer again:
```powershell
.\scripts\install-komorebi.ps1 -Force
```

## ⚙️ Startup Options

### Delay Startup

Edit `komorebi-startup.ahk` and change:
```autohotkey
; Wait for system to be ready
Sleep(3000)  ; Change to 5000 for 5 seconds
```

### Skip Zebar

Edit `komorebi-startup.ahk` and comment out:
```autohotkey
; Start Zebar status bar (if installed)
; zebarPath := A_AppData . "\..\Local\Programs\Zebar\Zebar.exe"
; if FileExist(zebarPath) {
;     Sleep(1000)
;     try {
;         Run(zebarPath, , "Hide")
;     } catch as err {
;         ; Zebar is optional, just log the error
;     }
; }
```

### Custom Startup Actions

Add to `komorebi-startup.ahk` before the `return` statement:
```autohotkey
; Your custom startup actions
Run("firefox.exe")  ; Auto-open Firefox
Sleep(1000)
Run("code.exe")     ; Auto-open VSCode
```

## 📊 Startup Performance

### Typical Startup Time
- **Komorebi**: 2-3 seconds
- **AutoHotkey**: < 1 second
- **Zebar**: 1-2 seconds
- **Total**: ~5 seconds

### Optimize Startup

1. **Reduce initial delay**:
   - Change `Sleep(3000)` to `Sleep(1000)` in startup script

2. **Skip optional tools**:
   - Comment out komorebi-loading
   - Comment out Zebar if not needed

3. **Use SSD**:
   - Faster disk = faster startup

## 🎯 Best Practices

### After Installation
1. **Test startup script manually** before rebooting
2. **Verify all processes start** correctly
3. **Check keyboard shortcuts** work

### Regular Maintenance
1. **Update Komorebi** regularly: `winget upgrade LGUG2Z.komorebi`
2. **Backup configs** before major changes
3. **Test after Windows updates**

### Multiple Monitors
- Komorebi detects monitors automatically
- No special startup configuration needed
- Workspaces adapt to monitor count

## 📝 Startup Checklist

After installation, verify:

- [ ] Shortcut exists in Startup folder
- [ ] Startup script exists in `.config\komorebi`
- [ ] Komorebi config file exists
- [ ] AutoHotkey config file exists
- [ ] Manual start works correctly
- [ ] Keyboard shortcuts respond
- [ ] Zebar appears in taskbar
- [ ] Notification shows on start

## 🆘 Emergency Recovery

If Komorebi causes issues on startup:

### Boot into Safe Mode
1. Hold Shift while clicking Restart
2. Troubleshoot → Advanced → Startup Settings
3. Press 4 for Safe Mode

### Remove Startup Entry
```powershell
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk" -Force
```

### Reinstall Clean
```powershell
# Stop everything
komorebic stop
Stop-Process -Name autohotkey -Force -ErrorAction SilentlyContinue

# Remove configs
Remove-Item "$env:USERPROFILE\.config\komorebi" -Recurse -Force

# Reinstall
.\scripts\install-komorebi.ps1
```

## 📚 Related Documentation

- **[KOMOREBI_GUIDE.md](KOMOREBI_GUIDE.md)** - Complete guide
- **[KOMOREBI_SHORTCUTS.md](KOMOREBI_SHORTCUTS.md)** - Keyboard shortcuts
- **[KOMOREBI_MULTI_MONITOR.md](KOMOREBI_MULTI_MONITOR.md)** - Multi-monitor setup

## ✨ Summary

**Automatic Startup**:
- ✅ Configured during installation
- ✅ Starts on Windows login
- ✅ Loads all components (Komorebi, AHK, Zebar)
- ✅ Shows notification when ready
- ✅ Handles errors gracefully

**Manual Control**:
- Start: `autohotkey.exe "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"`
- Stop: `komorebic stop`
- Restart: Stop then start
- Disable: Delete startup shortcut

**Verification**:
- Check processes: `Get-Process komorebi,autohotkey,zebar`
- Check shortcut: `Test-Path "$env:APPDATA\...\Startup\Komorebi.lnk"`
- Test shortcuts: Press `Win+Shift+H` for help

---

**Your Komorebi setup will start automatically on every login!** 🚀
