# Komorebi Startup Fix Guide

## 🐛 Problem: Komorebi Doesn't Start on Login

If Komorebi, AutoHotkey, and Zebar don't start automatically when you log in to Windows, this guide will help you fix it.

## 🔍 Common Causes

1. **AutoHotkey path not found** - Shortcut uses "autohotkey.exe" without full path
2. **Startup script missing** - `komorebi-startup.ahk` not created
3. **Shortcut not created** - Startup folder shortcut missing or broken
4. **PATH not updated** - Executables not in system PATH

## ✅ Quick Fix

Run the automatic fix script:

```powershell
.\scripts\fix-komorebi-startup.ps1
```

This script will:
- ✅ Find Komorebi installation
- ✅ Find AutoHotkey installation
- ✅ Verify startup script exists
- ✅ Create/update startup shortcut with full paths
- ✅ Test the startup configuration
- ✅ Optionally restart Komorebi to verify

## 🔧 Manual Fix

### Step 1: Verify Installations

**Check Komorebi:**
```powershell
# Try to find komorebic
Get-Command komorebic

# Or search manually
Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Recurse -Filter "komorebic.exe"
```

**Check AutoHotkey:**
```powershell
# Try to find autohotkey
Get-Command autohotkey

# Or search manually
Get-ChildItem "$env:LOCALAPPDATA\Programs\AutoHotkey" -Recurse -Filter "AutoHotkey*.exe"
```

**Check Zebar:**
```powershell
Test-Path "$env:LOCALAPPDATA\Programs\Zebar\Zebar.exe"
```

### Step 2: Verify Startup Script

```powershell
# Check if startup script exists
Test-Path "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"

# View the script
Get-Content "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

If missing, reinstall Komorebi:
```powershell
.\scripts\install-komorebi.ps1 -Theme tokyonight -Force
```

### Step 3: Create Startup Shortcut Manually

**Option A: Using PowerShell**
```powershell
# Set paths
$ahkPath = "C:\Users\YourUsername\AppData\Local\Programs\AutoHotkey\v2\AutoHotkey.exe"
$startupScript = "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk"

# Create shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $ahkPath
$Shortcut.Arguments = "`"$startupScript`""
$Shortcut.WorkingDirectory = "$env:USERPROFILE\.config\komorebi"
$Shortcut.Description = "Komorebi Tiling Window Manager"
$Shortcut.Save()
```

**Option B: Using Windows GUI**

1. Open File Explorer
2. Navigate to: `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`
3. Right-click → New → Shortcut
4. Target: `"C:\Users\YourUsername\AppData\Local\Programs\AutoHotkey\v2\AutoHotkey.exe" "C:\Users\YourUsername\.config\komorebi\komorebi-startup.ahk"`
5. Name: `Komorebi`
6. Click Finish

### Step 4: Test Startup

**Start manually:**
```powershell
# Find AutoHotkey path
$ahk = Get-Command autohotkey | Select-Object -ExpandProperty Source

# Start Komorebi
& $ahk "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

**Wait 5-10 seconds**, then check if running:
```powershell
Get-Process komorebi,autohotkey,zebar
```

## 🔍 Troubleshooting

### Shortcut Exists But Doesn't Work

**Check shortcut properties:**
```powershell
$shortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk"
$shell = New-Object -ComObject WScript.Shell
$lnk = $shell.CreateShortcut($shortcut)
Write-Host "Target: $($lnk.TargetPath)"
Write-Host "Arguments: $($lnk.Arguments)"
```

**Common issues:**
- Target path is just "autohotkey.exe" (not full path)
- Arguments path has wrong slashes or quotes
- Working directory is incorrect

**Fix:**
```powershell
.\scripts\fix-komorebi-startup.ps1
```

### AutoHotkey Not Found

**Install AutoHotkey v2:**
```powershell
winget install -e --id AutoHotkey.AutoHotkey
```

**Verify installation:**
```powershell
Get-Command autohotkey
```

### Startup Script Has Errors

**View errors:**
```powershell
# Try to run the script manually
& autohotkey "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

**Check script syntax:**
```powershell
Get-Content "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk" | Select-Object -First 20
```

**Regenerate script:**
```powershell
.\scripts\install-komorebi.ps1 -Theme tokyonight -Force
```

### Komorebi Starts But Zebar Doesn't

**Check Zebar path in startup script:**
```powershell
Select-String -Path "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk" -Pattern "Zebar"
```

**Verify Zebar installation:**
```powershell
$zebarPath = "$env:LOCALAPPDATA\Programs\Zebar\Zebar.exe"
if (Test-Path $zebarPath) {
    Write-Host "Zebar found: $zebarPath" -ForegroundColor Green
    # Start manually to test
    Start-Process $zebarPath
} else {
    Write-Host "Zebar not found" -ForegroundColor Red
    # Install Zebar
    winget install -e --id glzr-io.zebar
}
```

### Processes Start But Keyboard Shortcuts Don't Work

**Check if AHK config is loaded:**
```powershell
# Should see two AutoHotkey processes:
# 1. komorebi-startup.ahk
# 2. komorebi.ahk (keyboard shortcuts)
Get-Process autohotkey | Select-Object Id, ProcessName, Path
```

**Manually load keyboard shortcuts:**
```powershell
& autohotkey "$env:USERPROFILE\.config\komorebi\komorebi.ahk"
```

## 📋 Verification Checklist

After fixing, verify everything works:

- [ ] Shortcut exists in Startup folder
- [ ] Shortcut has correct full path to AutoHotkey
- [ ] Startup script exists and is valid
- [ ] Manual start works: `autohotkey komorebi-startup.ahk`
- [ ] Komorebi process starts
- [ ] AutoHotkey process starts (2 instances)
- [ ] Zebar appears in system tray
- [ ] Keyboard shortcuts work (Win+H/J/K/L)
- [ ] Theme switcher works (Win+Shift+T)
- [ ] Help overlay works (Win+Shift+H)

## 🚀 Test Startup

**Option 1: Reboot**
```powershell
Restart-Computer
```

**Option 2: Simulate Login**
```powershell
# Stop all processes
Stop-Process -Name komorebi,autohotkey,zebar -Force -ErrorAction SilentlyContinue

# Wait a moment
Start-Sleep -Seconds 2

# Start via shortcut (simulates login)
$shortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk"
Start-Process $shortcut

# Wait for startup
Start-Sleep -Seconds 10

# Check if running
Get-Process komorebi,autohotkey,zebar
```

## 📝 Expected Startup Sequence

When Windows starts:

```
1. Windows Login
   ↓
2. Windows runs all shortcuts in Startup folder
   ↓
3. Komorebi.lnk executes:
   AutoHotkey.exe "komorebi-startup.ahk"
   ↓
4. komorebi-startup.ahk runs:
   - Wait 3 seconds (system ready)
   - Check if Komorebi already running (kill if yes)
   - Start: komorebic.exe start --await-configuration
   - Wait 3 seconds (Komorebi ready)
   - Load: komorebi.ahk (keyboard shortcuts)
   - Start: Zebar.exe (status bar)
   - Show notification: "Komorebi Started"
   ↓
5. You see:
   - Zebar in system tray
   - Notification popup
   - Windows start tiling automatically
   - Keyboard shortcuts work
```

## 🎯 Prevention

To avoid startup issues in the future:

1. **Always use the fix script after reinstalling:**
   ```powershell
   .\scripts\fix-komorebi-startup.ps1
   ```

2. **Don't move AutoHotkey** after creating the shortcut

3. **Don't rename or move** `.config\komorebi` folder

4. **After Windows updates**, verify startup still works

5. **Keep backups** of working configuration:
   ```powershell
   Copy-Item "$env:USERPROFILE\.config\komorebi" "$env:USERPROFILE\.config\komorebi.backup" -Recurse
   ```

## 🆘 Still Not Working?

If nothing works:

1. **Check Windows Event Viewer:**
   - Windows Logs → Application
   - Look for AutoHotkey or Komorebi errors

2. **Enable startup logging:**
   Edit `komorebi-startup.ahk` and add at the top:
   ```autohotkey
   FileAppend("Startup script started`n", A_Temp "\komorebi-startup.log")
   ```

3. **Use Task Scheduler instead:**
   ```powershell
   # Create scheduled task
   $action = New-ScheduledTaskAction -Execute "autohotkey.exe" -Argument "`"$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk`""
   $trigger = New-ScheduledTaskTrigger -AtLogon
   Register-ScheduledTask -TaskName "Komorebi" -Action $action -Trigger $trigger -RunLevel Highest
   ```

4. **Ask for help:**
   - Komorebi Discord: https://discord.gg/komorebi
   - GitHub Issues: https://github.com/LGUG2Z/komorebi/issues

## 📚 Related Documentation

- **[KOMOREBI_STARTUP.md](KOMOREBI_STARTUP.md)** - Complete startup guide
- **[KOMOREBI_GUIDE.md](KOMOREBI_GUIDE.md)** - Complete Komorebi guide
- **[KOMOREBI_SHORTCUTS.md](KOMOREBI_SHORTCUTS.md)** - Keyboard shortcuts

---

**Remember: Run `.\scripts\fix-komorebi-startup.ps1` to automatically fix most startup issues!** 🚀
