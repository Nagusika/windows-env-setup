# Komorebi Arrow Keys & Theme Switcher

## ✨ New Features Added

### 1. Arrow Key Navigation

You can now use **arrow keys** as an alternative to H/J/K/L for window navigation!

#### Focus Windows
| HJKL | Arrow Keys | Action |
|------|------------|--------|
| `Win+H` | `Win+Left` | Focus LEFT |
| `Win+J` | `Win+Down` | Focus DOWN |
| `Win+K` | `Win+Up` | Focus UP |
| `Win+L` | `Win+Right` | Focus RIGHT |

#### Move Windows
| HJKL | Arrow Keys | Action |
|------|------------|--------|
| `Win+Shift+H` | `Win+Shift+Left` | Move LEFT |
| `Win+Shift+J` | `Win+Shift+Down` | Move DOWN |
| `Win+Shift+K` | `Win+Shift+Up` | Move UP |
| `Win+Shift+L` | `Win+Shift+Right` | Move RIGHT |

#### Cycle Stacked Windows
| Shortcut | Action |
|----------|--------|
| `Win+Ctrl+Left` | Previous stacked window |
| `Win+Ctrl+Down/Up/Right` | Next stacked window |
| `Win+N` | Next (alternative) |
| `Win+Shift+N` | Previous (alternative) |

#### Why Both?

**HJKL (Vim-style)**:
- ✅ Faster - hands stay on home row
- ✅ No Ctrl modifier needed
- ✅ Standard in tiling WMs
- ✅ Better for power users

**Arrow Keys**:
- ✅ More intuitive for beginners
- ✅ Visual direction
- ✅ Familiar to everyone
- ✅ Good for one-handed use

**Use whichever you prefer!** Both work simultaneously.

### 2. Theme Switcher (Win+Shift+T)

Quick and easy theme switching with a GUI dialog!

#### How to Use

1. Press `Win+Shift+T`
2. A dialog appears showing:
   - Current theme
   - Three theme options (Gruvbox, Tokyo Night, Catppuccin)
3. Select your preferred theme
4. Click "Apply"
5. Komorebi automatically:
   - Regenerates config with new colors
   - Restarts Komorebi
   - Shows confirmation message

#### Theme Options

**Gruvbox** (warm, retro)
- Orange focused border (#d79921)
- Purple stack border (#b16286)
- Green monocle border (#689d6a)
- Dark brown background

**Tokyo Night** (cool, modern)
- Blue focused border (#7aa2f7)
- Purple stack border (#bb9af7)
- Green monocle border (#9ece6a)
- Dark blue background

**Catppuccin** (pastel, elegant)
- Blue focused border (#89b4fa)
- Purple stack border (#cba6f7)
- Green monocle border (#a6e3a1)
- Dark gray background

## 🎯 Quick Reference

### Navigation Options

```
Focus Window:
  Win+H/J/K/L          (Vim-style, faster)
  Win+Arrows           (Intuitive, visual)

Move Window:
  Win+Shift+H/J/K/L    (Vim-style, faster)
  Win+Shift+Arrows     (Intuitive, visual)

Cycle Stacked Windows:
  Win+Ctrl+Arrows      (Cycle through tabs)
  Win+N / Win+Shift+N  (Alternative)
```

### Theme Management

```
Quick Switch:
  Win+Shift+T          (GUI dialog)

Manual:
  .\scripts\install-komorebi.ps1 -Theme <name>
```

## 💡 Tips

### For Vim Users
Stick with HJKL - it's faster and keeps your hands on the home row.

### For Beginners
Start with arrow keys until you're comfortable, then try HJKL.

### For One-Handed Use
Arrow keys work great when using mouse with other hand.

### Theme Switching
- Try all three themes to find your favorite
- Switch based on time of day (Tokyo Night for evening)
- Match your terminal/editor theme

## 🔧 Technical Details

### Arrow Key Implementation

The AutoHotkey config uses a logical modifier system:

```autohotkey
; Focus with HJKL or Arrows (no extra modifier)
LWin & h::komorebic("focus left")
LWin & Left::komorebic("focus left")

; Move with Shift modifier
LWin & +Left::komorebic("move left")

; Cycle stack with Ctrl modifier
LWin & ^Left::komorebic("cycle-stack previous")
```

This creates a logical pattern:
- `Win+Arrow` = Focus windows (navigate)
- `Win+Shift+Arrow` = Move windows (relocate)
- `Win+Ctrl+Arrow` = Cycle stack (switch tabs)

### Theme Switcher Implementation

The theme switcher (`switch-theme.ps1`):
1. Reads current theme from `komorebi.json`
2. Shows Windows Forms dialog
3. Calls `install-komorebi.ps1` with new theme
4. Restarts Komorebi automatically
5. Updates all configs (Komorebi, Zebar, AHK)

## 🎓 Learning Recommendations

### Week 1: Arrow Keys
- Use `Win+Ctrl+Arrows` for focus
- Use `Win+Shift+Ctrl+Arrows` for move
- Get comfortable with the concept

### Week 2: Try HJKL
- Start using `Win+H/J/K/L` for focus
- Notice how much faster it is
- Hands stay on home row

### Week 3: Muscle Memory
- HJKL becomes natural
- Arrow keys as backup
- Both available when needed

## 📊 Comparison

| Feature | HJKL | Arrow Keys |
|---------|------|------------|
| **Speed** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Ergonomics** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Intuitiveness** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Learning Curve** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **One-Handed** | ⭐⭐ | ⭐⭐⭐⭐ |

## 🐛 Troubleshooting

### Arrow Keys Not Working

**Check Ctrl modifier**:
```
Wrong: Win+Left (this stacks)
Right: Win+Ctrl+Left (this focuses)
```

### Theme Switcher Not Opening

**Check script location**:
```powershell
# Should exist:
Test-Path "$env:USERPROFILE\.config\komorebi\switch-theme.ps1"
```

**Run manually**:
```powershell
powershell -File "$env:USERPROFILE\.config\komorebi\switch-theme.ps1"
```

### Theme Not Changing

**Check admin rights**: Theme switcher needs admin to restart Komorebi

**Manual theme change**:
```powershell
.\scripts\install-komorebi.ps1 -Theme tokyonight -Force
```

## 🎨 Customization

### Add More Arrow Key Shortcuts

Edit `~/.config/komorebi/komorebi.ahk`:

```autohotkey
; Resize with Ctrl+Alt+Arrows
LWin & ^!Left::komorebic("resize-axis horizontal decrease")
LWin & ^!Right::komorebic("resize-axis horizontal increase")
LWin & ^!Up::komorebic("resize-axis vertical increase")
LWin & ^!Down::komorebic("resize-axis vertical decrease")
```

### Customize Theme Switcher

Edit `~/.config/komorebi/switch-theme.ps1` to:
- Change dialog appearance
- Add custom themes
- Modify restart behavior

## ✅ Summary

**Arrow Keys**:
- ✅ Alternative to HJKL
- ✅ Use Ctrl modifier for focus
- ✅ Use Shift+Ctrl for move
- ✅ Both methods work simultaneously

**Theme Switcher**:
- ✅ Press `Win+Shift+T`
- ✅ GUI dialog with 3 themes
- ✅ Automatic config update
- ✅ Automatic Komorebi restart

**Best of Both Worlds**:
- Use HJKL for speed
- Use arrows when convenient
- Switch themes anytime
- No compromises!

---

See [KOMOREBI_SHORTCUTS.md](KOMOREBI_SHORTCUTS.md) for complete shortcuts reference.
