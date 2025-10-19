# Quick Start Guide

## 🚀 5-Minute Setup

### Step 1: Open PowerShell as Administrator

**Windows 10/11:**
- Press `Win + X`
- Select "Windows PowerShell (Admin)" or "Terminal (Admin)"

### Step 2: Navigate to the Script Directory

```powershell
cd path\to\windows-env-setup
```

### Step 3: Allow Script Execution (First Time Only)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Step 4: Run the Installation Script

```powershell
.\install.ps1
```

### Step 5: Answer the Prompts

The script will ask you what to install. Just answer `y` or `n`:

```
Install Git? (Y/n): y
Install GitHub CLI? (Y/n): y
Install Windows Terminal? (Y/n): y
Install NerdFonts (CascadiaCode, FiraCode)? (Y/n): y
Install WSL2 with Ubuntu? (Y/n): y
Install Docker Desktop? (y/N): n
Install additional useful packages? (Y/n): y
```

### Step 6: Wait for Installation

The script will:
- ✅ Install selected components
- ✅ Show progress with color-coded messages
- ✅ Log everything to `logs\install.log`
- ✅ Continue even if some packages fail

### Step 7: Restart (if prompted)

Some components (WSL, Docker) require a restart:

```
Do you want to restart now? (y/N): y
```

---

## 🎯 Recommended Answers for Different Use Cases

### For Developers

```
Install Git? (Y/n): y
Install GitHub CLI? (Y/n): y
Install Windows Terminal? (Y/n): y
Install NerdFonts? (Y/n): y
Install WSL2 with Ubuntu? (Y/n): y
Install Docker Desktop? (y/N): y
Install additional packages? (Y/n): y
  Base Shell & UX? (Y/n): y
  CLI Toolbox? (Y/n): y
  Development Tools? (Y/n): y
  Storage/Sync? (Y/n): y
  (Skip others or choose as needed)
```

### For System Administrators

```
Install Git? (Y/n): y
Install GitHub CLI? (Y/n): n
Install Windows Terminal? (Y/n): y
Install NerdFonts? (Y/n): y
Install WSL2 with Ubuntu? (Y/n): y
Install Docker Desktop? (y/N): n
Install additional packages? (Y/n): y
  CLI Toolbox? (Y/n): y
  Network/Debug/Monitoring? (Y/n): y
  Storage/Sync? (Y/n): y
  Backups? (Y/n): y
  Security/Privacy? (Y/n): y
```

### For Power Users

```
Install Git? (Y/n): y
Install GitHub CLI? (Y/n): y
Install Windows Terminal? (Y/n): y
Install NerdFonts? (Y/n): y
Install WSL2 with Ubuntu? (Y/n): y
Install Docker Desktop? (y/N): y
Install additional packages? (Y/n): y
  (Answer 'y' to everything!)
```

### For Minimal Setup

```
Install Git? (Y/n): y
Install GitHub CLI? (Y/n): n
Install Windows Terminal? (Y/n): y
Install NerdFonts? (Y/n): y
Install WSL2 with Ubuntu? (Y/n): n
Install Docker Desktop? (y/N): n
Install additional packages? (Y/n): y
  CLI Toolbox? (Y/n): y
  (Skip everything else)
```

---

## ⚡ Pro Tips

### Tip 1: Default Values
- `(Y/n)` means pressing Enter = Yes
- `(y/N)` means pressing Enter = No

### Tip 2: Installation Time
- Minimal setup: ~5-10 minutes
- Full setup: ~30-60 minutes
- Depends on internet speed

### Tip 3: Disk Space
- Minimal setup: ~1-2 GB
- Full setup: ~5-10 GB

### Tip 4: Errors Are OK
If a package fails to install:
- The script continues with other packages
- Check `logs\install.log` for details
- Retry later with: `.\scripts\install-<component>.ps1`

### Tip 5: Update Everything Later
```powershell
winget upgrade --all
```

---

## 🔧 After Installation

### Configure Git
```powershell
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Configure PowerShell Profile
```powershell
# Open profile
notepad $PROFILE

# Add these lines:
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Set-Alias -Name cat -Value bat
Set-Alias -Name ls -Value eza
```

### Test WSL (if installed)
```powershell
wsl --list --verbose
wsl -d Ubuntu
```

### Test Docker (if installed)
```powershell
docker --version
docker run hello-world
```

---

## 🐛 Common Issues

### "Cannot run scripts" error
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Administrator rights required" error
- Close PowerShell
- Open PowerShell as Administrator (Win + X)
- Run the script again

### "winget not found" error
- The script auto-installs winget
- If it fails, restart and run again
- Or install manually from Microsoft Store

### WSL installation hangs
- Press Ctrl+C to cancel
- Restart your computer
- Run the script again

### Package installation fails
- Check internet connection
- Some packages may not be available in your region
- Skip the package and continue

---

## 📞 Need Help?

1. **Check the logs**: `logs\install.log`
2. **Read the docs**: 
   - [README.md](README.md) - Main documentation
   - [PACKAGES.md](PACKAGES.md) - Package reference
   - [SUMMARY.md](SUMMARY.md) - Quick overview
   - [IMPROVEMENTS.md](IMPROVEMENTS.md) - Detailed changes
3. **Try individual scripts**: `.\scripts\install-<component>.ps1`
4. **Search winget**: `winget search <package-name>`

---

## ✅ Success Checklist

After installation, verify:

```powershell
# Check Git
git --version

# Check GitHub CLI (if installed)
gh --version

# Check Windows Terminal (if installed)
wt --version

# Check WSL (if installed)
wsl --list --verbose

# Check Docker (if installed)
docker --version

# Check CLI tools (if installed)
rg --version
fd --version
bat --version
```

---

## 🎉 You're Done!

Your Windows development environment is now set up with:
- ✅ Modern terminal and shell
- ✅ Version control (Git)
- ✅ Linux subsystem (WSL) - optional
- ✅ Containerization (Docker) - optional
- ✅ 100+ useful tools - optional

**Enjoy your new setup!** 🚀
