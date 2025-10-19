# Komorebi with Windows Key Configuration

## ✅ What Changed

The Komorebi configuration now uses the **Windows key** (Win) as the main modifier instead of Alt.

### Key Changes

1. **Windows Key as Modifier**: All shortcuts now use `Win+Key` instead of `Alt+Key`
2. **Start Menu Disabled**: Pressing Win alone no longer opens the Start Menu
3. **Preserved Windows Shortcuts**: Essential Windows shortcuts still work (Win+E, Win+D, Win+Tab)

## 🎯 Why Use Windows Key?

### Advantages
- ✅ **No Conflicts**: Doesn't interfere with application shortcuts (Alt+F4, Alt+Tab, etc.)
- ✅ **More Ergonomic**: Windows key is easier to reach on most keyboards
- ✅ **Standard Practice**: Common in Linux tiling window managers (i3, bspwm)
- ✅ **Dedicated Key**: Windows key is rarely used for other purposes

### Disadvantages
- ⚠️ **Start Menu Disabled**: Can't use Win alone to open Start Menu
- ⚠️ **Some Windows Shortcuts Overridden**: Win+1-5, Win+H/J/K/L, etc.

## ⌨️ Keyboard Shortcuts

### Core Komorebi Shortcuts

| Action | Shortcut | Old (Alt) |
|--------|----------|-----------|
| Focus window | `Win+H/J/K/L` | `Alt+H/J/K/L` |
| Move window | `Win+Shift+H/J/K/L` | `Alt+Shift+H/J/K/L` |
| Switch workspace | `Win+1/2/3/4/5` | `Alt+1/2/3/4/5` |
| Stack window | `Win+Arrow Keys` | `Alt+Arrow Keys` |
| Toggle float | `Win+T` | `Alt+T` |
| Toggle fullscreen | `Win+F` | `Alt+F` |
| Close window | `Win+Q` | `Alt+Q` |
| Open terminal | `Win+Enter` | `Alt+Enter` |
| Open launcher | `Win+Space` | `Alt+Space` |

### Preserved Windows Shortcuts

These Windows shortcuts still work:

| Shortcut | Action |
|----------|--------|
| `Win+E` | Open File Explorer |
| `Win+D` | Show Desktop |
| `Win+Tab` | Task View |
| `Win+A` | Action Center |
| `Win+I` | Settings |
| `Win+R` | Settings (replaces Run dialog) |

## 🔧 Technical Implementation

### AutoHotkey Configuration

The configuration uses these techniques:

```autohotkey
#Requires AutoHotkey v2.0
#SingleInstance Force

; Disable Windows key from opening Start Menu
LWin::return

; Use Windows key as modifier
LWin & h::komorebic("focus left")
LWin & j::komorebic("focus down")
; ... etc

; Preserve some Windows shortcuts
LWin & e::Run("explorer.exe")
LWin & d::Send("#d")
LWin & Tab::Send("#Tab")
```

### How It Works

1. **`LWin::return`** - Disables the Start Menu when pressing Win alone
2. **`LWin & key::`** - Creates Win+Key combinations
3. **`Send("#key")`** - Passes through original Windows shortcuts

## 🔄 Switching Back to Alt

If you prefer Alt instead of Windows key:

### Option 1: Reinstall with Modified Script

Edit `scripts/install-komorebi.ps1` and change:
```autohotkey
; Change from:
LWin & h::komorebic("focus left")

; To:
!h::komorebic("focus left")
```

Then remove the `LWin::return` line.

### Option 2: Manual Edit

Edit `~/.config/komorebi/komorebi.ahk`:

```autohotkey
; Remove this line:
LWin::return

; Replace all "LWin &" with "!"
; Example:
; Before: LWin & h::komorebic("focus left")
; After:  !h::komorebic("focus left")
```

Then reload: `Win+Shift+C` (or `Alt+Shift+C` after changes)

## 💡 Tips & Tricks

### Accessing Start Menu

Since Win alone is disabled, use these alternatives:

1. **Win+R** → Opens Settings (configured in script)
2. **Win+Space** → Opens Flow Launcher (better than Start Menu!)
3. **Ctrl+Esc** → Opens Start Menu (Windows default)
4. **Click Start Button** → Still works normally

### Quick App Launching

Use Flow Launcher (`Win+Space`) instead of Start Menu:
- Faster search
- More features
- Better for keyboard-driven workflow

### Custom Shortcuts

Add your own shortcuts in `~/.config/komorebi/komorebi.ahk`:

```autohotkey
; Open Firefox
LWin & b::Run("firefox.exe")

; Open VSCode
LWin & c::Run("code.exe")

; Screenshot
LWin & s::Send("#+s")

; Calculator
LWin & =::Run("calc.exe")
```

## 🐛 Troubleshooting

### Start Menu Opens Unexpectedly

**Cause**: AutoHotkey script not running

**Solution**:
```powershell
autohotkey.exe "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

### Windows Shortcuts Not Working

**Cause**: Shortcuts not preserved in AHK config

**Solution**: Add to `komorebi.ahk`:
```autohotkey
LWin & YourKey::Send("#YourKey")
```

### Want to Use Both Alt and Win

**Solution**: Duplicate shortcuts in `komorebi.ahk`:
```autohotkey
; Windows key version
LWin & h::komorebic("focus left")

; Alt key version (for muscle memory)
!h::komorebic("focus left")
```

### Accidentally Disabled Important Shortcut

**Solution**: Add passthrough in `komorebi.ahk`:
```autohotkey
; Example: Re-enable Win+L (Lock screen)
LWin & l::Send("#l")
```

## 📊 Comparison: Alt vs Windows Key

| Aspect | Alt Key | Windows Key |
|--------|---------|-------------|
| **Conflicts** | Many app shortcuts | Few conflicts |
| **Ergonomics** | Varies by keyboard | Usually good |
| **Start Menu** | Works normally | Disabled |
| **Alt+Tab** | Conflicts | No conflict |
| **Alt+F4** | Conflicts | No conflict |
| **Learning Curve** | Familiar | Slight adjustment |
| **Standard** | Uncommon | Common in Linux WMs |

## 🎓 Learning the New Shortcuts

### Week 1: Basic Muscle Memory

Focus on these essential shortcuts:
- `Win+H/J/K/L` - Focus windows
- `Win+1/2/3` - Switch workspaces
- `Win+Enter` - Open terminal
- `Win+Space` - Open launcher

### Week 2: Advanced Features

Add these to your workflow:
- `Win+Shift+H/J/K/L` - Move windows
- `Win+Arrow Keys` - Stack windows
- `Win+T` - Toggle floating
- `Win+F` - Toggle fullscreen

### Tips for Transition

1. **Print the cheat sheet** - Keep it visible
2. **Use Flow Launcher** - Better than Start Menu
3. **Practice daily** - Muscle memory takes time
4. **Customize gradually** - Add shortcuts as needed

## 🔐 Security Note

Disabling the Windows key doesn't affect:
- **Ctrl+Alt+Del** - Still works for security
- **Win+L** - Can be re-enabled if needed
- **Power button** - Still works normally

## 📚 Additional Resources

- **[KOMOREBI_SHORTCUTS.md](KOMOREBI_SHORTCUTS.md)** - Complete shortcuts reference
- **[KOMOREBI_GUIDE.md](KOMOREBI_GUIDE.md)** - Full Komorebi guide
- **AutoHotkey Docs**: https://www.autohotkey.com/docs/v2/

## ✨ Summary

The Windows key configuration provides:
- ✅ **Better ergonomics** - Dedicated modifier key
- ✅ **Fewer conflicts** - No interference with app shortcuts
- ✅ **Standard practice** - Common in tiling WMs
- ✅ **Preserved essentials** - Win+E, Win+D, Win+Tab still work
- ✅ **Easy customization** - Add your own shortcuts
- ✅ **Flow Launcher integration** - Better than Start Menu

**Enjoy your optimized Komorebi experience!** 🚀
