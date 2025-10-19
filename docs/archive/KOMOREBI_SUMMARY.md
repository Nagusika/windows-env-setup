# Komorebi Installation Summary

## ✅ What Was Added

### Core Installation Script
**File**: `scripts/install-komorebi.ps1`

Installs and configures:
- ✅ **Komorebi** - Tiling window manager via winget
- ✅ **AutoHotkey v2** - Hotkey daemon for keyboard shortcuts
- ✅ **Zebar** - Customizable status bar
- ✅ **komorebi-loading** - Loading screen (requires Node.js)
- ✅ **komoflow** - Flow Launcher plugin (if Flow Launcher installed)

### Configuration Files Created

#### 1. Komorebi Configuration
**Location**: `~/.config/komorebi/komorebi.json`
- Window padding and borders
- Workspace definitions (5 workspaces)
- Border colors (theme-specific)
- Float rules for common apps
- Stackbar configuration

#### 2. AutoHotkey Configuration
**Location**: `~/.config/komorebi/komorebi.ahk`
- Complete keyboard shortcuts
- Window focus/move/stack/resize
- Workspace switching
- Application launchers
- Layout management

#### 3. Startup Script
**Location**: `~/.config/komorebi/komorebi-startup.ahk`
- Starts Komorebi automatically
- Loads main AHK configuration
- Starts Zebar if installed
- Shows notification

#### 4. Application Rules
**Location**: `~/.config/komorebi/applications.yaml`
- App-specific tiling behavior
- Float rules for dialogs
- ObjectNameChange for common apps

#### 5. Zebar Configuration
**Location**: `~/.config/zebar/config.json`
- Status bar layout
- Theme colors
- Widgets (workspaces, title, system info, clock)

### Startup Integration
- ✅ Shortcut added to Windows Startup folder
- ✅ Komorebi starts automatically on login

## 🎨 Theme Support

Three beautiful themes included:

### 1. Gruvbox (Default)
```
Style: Warm, retro, high contrast
Colors: Orange/Purple/Green on dark brown
Best for: Long coding sessions
```

### 2. Tokyo Night
```
Style: Cool, modern, vibrant
Colors: Blue/Purple/Green on dark blue
Best for: Night work, modern aesthetic
```

### 3. Catppuccin
```
Style: Pastel, elegant, soft
Colors: Blue/Purple/Green on dark gray
Best for: Gentle on eyes, aesthetic
```

## 🚀 Usage

### Start Komorebi
```powershell
# Automatic on login (via startup shortcut)
# Or manually:
autohotkey.exe "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

### Change Theme
```powershell
.\scripts\install-komorebi.ps1 -Theme tokyonight
.\scripts\install-komorebi.ps1 -Theme catppuccin
.\scripts\install-komorebi.ps1 -Theme gruvbox
```

### Essential Shortcuts
```
Alt+H/J/K/L         Focus window (←/↓/↑/→)
Alt+Shift+H/J/K/L   Move window
Alt+1/2/3/4/5       Switch workspace
Alt+Enter           Open terminal
Alt+Space           Open Flow Launcher
Alt+Q               Close window
Alt+T               Toggle floating
Alt+F               Toggle fullscreen
```

## 📚 Documentation

### Complete Guides
- **[KOMOREBI_GUIDE.md](KOMOREBI_GUIDE.md)** - Full documentation (usage, customization, troubleshooting)
- **[KOMOREBI_SHORTCUTS.md](KOMOREBI_SHORTCUTS.md)** - Quick reference for all shortcuts

### Quick Reference
```
┌─────────────────────────────────────┐
│  FOCUS    Alt+H/J/K/L              │
│  MOVE     Alt+Shift+H/J/K/L        │
│  STACK    Alt+Arrow Keys            │
│  RESIZE   Alt+= / Alt+-             │
│  FLOAT    Alt+T                     │
│  FULL     Alt+F                     │
│  CLOSE    Alt+Q                     │
│  WS       Alt+1/2/3/4/5             │
└─────────────────────────────────────┘
```

## 🔧 Integration with Main Script

### In `install.ps1`
```powershell
# Added function: Install-Komorebi
# Prompts user: "Install Komorebi tiling window manager? (y/N)"
# Theme selection: Interactive menu (1-3)
# Execution: Calls install-komorebi.ps1 with selected theme
```

### Installation Flow
```
1. User runs install.ps1
2. Prompted for Komorebi installation
3. If yes, choose theme (1-3)
4. Script installs:
   - Komorebi
   - AutoHotkey v2
   - Zebar
   - komorebi-loading
5. Creates all configuration files
6. Adds to startup
7. Shows post-install info
```

## 🎯 Features

### Window Management
- ✅ Automatic tiling (BSP layout)
- ✅ Window stacking (tabbed windows)
- ✅ Floating mode for dialogs
- ✅ Monocle mode (fullscreen)
- ✅ Multiple layouts (BSP, Columns, Rows, etc.)

### Workspace Management
- ✅ 5 workspaces per monitor
- ✅ Quick workspace switching
- ✅ Move windows between workspaces
- ✅ Per-workspace layouts

### Visual Feedback
- ✅ Colored borders (theme-based)
- ✅ Different colors for focused/stack/monocle
- ✅ Stackbar for tabbed windows
- ✅ Status bar (Zebar) with system info

### Customization
- ✅ 3 pre-configured themes
- ✅ Adjustable padding and borders
- ✅ Custom keyboard shortcuts
- ✅ App-specific rules
- ✅ Multiple layout options

## 🛠️ Additional Tools

### Zebar (Status Bar)
- Shows current workspace
- Window title
- CPU/Memory usage
- Network info
- Clock
- Theme-colored

### komoflow (Flow Launcher Plugin)
- Control Komorebi from Flow Launcher
- Quick workspace switching
- Window management commands
- Install: `pm install komoflow` in Flow Launcher

### komorebi-loading
- Cute loading screen on startup
- Shows while Komorebi initializes
- Electron-based app
- Located: `~/.config/komorebi-loading`

## 📋 File Structure

```
~/.config/komorebi/
├── komorebi.json           # Main config
├── applications.yaml       # App rules
├── komorebi.ahk           # Keyboard shortcuts
└── komorebi-startup.ahk   # Startup script

~/.config/zebar/
└── config.json            # Status bar config

~/.config/komorebi-loading/
└── (electron app files)

~/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/
└── Komorebi.lnk           # Startup shortcut
```

## 🎓 Learning Curve

### Day 1 (30 minutes)
- Learn basic focus: `Alt+H/J/K/L`
- Learn workspace switching: `Alt+1/2/3`
- Learn close: `Alt+Q`
- Learn float toggle: `Alt+T`

### Day 2 (30 minutes)
- Learn window moving: `Alt+Shift+H/J/K/L`
- Learn moving to workspace: `Alt+Shift+1/2/3`
- Learn fullscreen: `Alt+F`

### Day 3 (30 minutes)
- Learn stacking: `Alt+Arrow Keys`
- Learn cycle stack: `Alt+N`
- Learn resize: `Alt+=/-`

### Week 2+
- Customize shortcuts
- Add app-specific rules
- Experiment with layouts
- Fine-tune theme colors

## 🐛 Common Issues & Solutions

### Issue: Komorebi doesn't start
```powershell
# Solution 1: Start manually
komorebic start

# Solution 2: Check if running
Get-Process komorebi

# Solution 3: Restart
komorebic stop
autohotkey.exe "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

### Issue: Shortcuts not working
```powershell
# Check if AutoHotkey is running
Get-Process autohotkey

# Restart AutoHotkey
autohotkey.exe "$env:USERPROFILE\.config\komorebi\komorebi.ahk"
```

### Issue: Wrong windows floating
```powershell
# Edit float rules
notepad "$env:USERPROFILE\.config\komorebi\applications.yaml"

# Then retile
komorebic retile
# Or press Alt+Shift+R
```

### Issue: Don't like the theme
```powershell
# Change theme
.\scripts\install-komorebi.ps1 -Theme tokyonight
```

## 🔄 Updating

### Update Komorebi
```powershell
winget upgrade LGUG2Z.komorebi
```

### Update Configuration
```powershell
# Reinstall with new theme
.\scripts\install-komorebi.ps1 -Force -Theme catppuccin

# Or manually edit
notepad "$env:USERPROFILE\.config\komorebi\komorebi.json"
```

## 🗑️ Uninstalling

```powershell
# Stop Komorebi
komorebic stop

# Uninstall
winget uninstall LGUG2Z.komorebi
winget uninstall glzr-io.zebar

# Remove configs
Remove-Item -Recurse "$env:USERPROFILE\.config\komorebi"
Remove-Item -Recurse "$env:USERPROFILE\.config\zebar"
Remove-Item -Recurse "$env:USERPROFILE\.config\komorebi-loading"

# Remove startup shortcut
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk"
```

## 💡 Pro Tips

1. **Start with defaults** - Use for a week before customizing
2. **Learn gradually** - Master 3-4 shortcuts per day
3. **Use workspaces** - Organize by task (code, browser, terminal, etc.)
4. **Stack terminals** - Great for multiple shells
5. **Float dialogs** - Settings, Task Manager auto-float
6. **Monocle for focus** - `Alt+F` for distraction-free work
7. **Flow Launcher** - Combine with `Alt+Space` for quick launching
8. **Customize later** - Get comfortable first, then tweak

## 🌟 Why Komorebi?

### Benefits
- ✅ **Productivity** - Keyboard-driven workflow
- ✅ **Organization** - Multiple workspaces
- ✅ **Screen real estate** - No wasted space
- ✅ **Focus** - Less window management distraction
- ✅ **Aesthetics** - Beautiful themed borders
- ✅ **Free & Open Source** - Community-driven

### Perfect For
- 👨‍💻 Developers
- 🎨 Designers with multiple apps
- 📊 Data analysts with many windows
- 🎮 Power users
- 🖥️ Multi-monitor setups
- ⌨️ Keyboard enthusiasts

## 📞 Support & Resources

- **Official Docs**: https://lgug2z.github.io/komorebi/
- **GitHub**: https://github.com/LGUG2Z/komorebi
- **Awesome List**: https://github.com/LGUG2Z/awesome-komorebi
- **Discord**: Join for community support
- **Local Docs**: [KOMOREBI_GUIDE.md](KOMOREBI_GUIDE.md)

## ✨ What Makes This Installation Special

1. **Fully Automated** - One command installs everything
2. **Theme Support** - 3 beautiful themes out of the box
3. **Complete Configuration** - All configs pre-made
4. **Additional Tools** - Zebar, komoflow, loading screen
5. **Startup Integration** - Starts automatically
6. **Comprehensive Docs** - Full guides and shortcuts
7. **Easy Theme Switching** - Change anytime
8. **Beginner Friendly** - Clear instructions and examples

---

**Enjoy your new tiling window manager experience!** 🚀

For complete documentation, see:
- [KOMOREBI_GUIDE.md](KOMOREBI_GUIDE.md) - Full guide
- [KOMOREBI_SHORTCUTS.md](KOMOREBI_SHORTCUTS.md) - Shortcuts reference
