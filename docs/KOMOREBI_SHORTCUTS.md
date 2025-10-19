# Komorebi Keyboard Shortcuts - Quick Reference

## ⚠️ Important: Using Windows Key

**The Windows key is used as the main modifier** instead of Alt.
**The Start Menu is disabled** when pressing Win alone.

## 🎯 Essential Shortcuts (Learn These First!)

| Shortcut | Action |
|----------|--------|
| `Win+H/J/K/L` or `Win+Arrows` | **Focus** window (←/↓/↑/→) |
| `Win+Shift+H/J/K/L` or `Win+Shift+Arrows` | **Move** window (←/↓/↑/→) |
| `Win+Ctrl+Arrows` | **Cycle** stacked windows |
| `Win+1/2/3/4/5` | **Switch** workspace |
| `Win+Enter` | **Open** Windows Terminal |
| `Win+Space` | **Open** Flow Launcher |
| `Win+Q` | **Close** window |
| `Win+T` | **Toggle** floating |
| `Win+F` | **Toggle** fullscreen |
| `Win+Shift+T` | **Theme switcher** (GUI) |
| `Win+Shift+H` or `Win+?` | **Help overlay** (show/hide shortcuts) |

---

## 📋 Complete Shortcuts Reference

### Window Focus (Navigation)
```
Win+H  →  Focus LEFT
Win+J  →  Focus DOWN
Win+K  →  Focus UP
Win+L  →  Focus RIGHT

Alternative (Arrow Keys):
Win+Left   →  Focus LEFT
Win+Down   →  Focus DOWN
Win+Up     →  Focus UP
Win+Right  →  Focus RIGHT
```

### Window Movement
```
Win+Shift+H  →  Move LEFT
Win+Shift+J  →  Move DOWN
Win+Shift+K  →  Move UP
Win+Shift+L  →  Move RIGHT

Alternative (Arrow Keys):
Win+Shift+Left   →  Move LEFT
Win+Shift+Down   →  Move DOWN
Win+Shift+Up     →  Move UP
Win+Shift+Right  →  Move RIGHT
```

### Cycle Stacked Windows
```
Win+Ctrl+Left   →  Previous stacked window
Win+Ctrl+Down   →  Next stacked window
Win+Ctrl+Up     →  Next stacked window
Win+Ctrl+Right  →  Next stacked window

Alternative:
Win+N           →  Next stacked window
Win+Shift+N     →  Previous stacked window
Win+U           →  Unstack window
```

### Window Resizing
```
Win+=       →  Increase HORIZONTAL size
Win+-       →  Decrease HORIZONTAL size
Win+Shift+= →  Increase VERTICAL size
Win+Shift+- →  Decrease VERTICAL size
```

### Window Manipulation
```
Win+T       →  Toggle FLOATING mode
Win+F       →  Toggle MONOCLE (fullscreen)
Win+Q       →  CLOSE window (Alt+F4)
Win+Shift+R →  RETILE all windows
Win+P       →  PAUSE/unpause Komorebi
```

### Workspaces (Virtual Desktops)
```
Win+1  →  Switch to workspace 1
Win+2  →  Switch to workspace 2
Win+3  →  Switch to workspace 3
Win+4  →  Switch to workspace 4
Win+5  →  Switch to workspace 5
```

### Move Window to Workspace
```
Win+Shift+1  →  Move to workspace 1
Win+Shift+2  →  Move to workspace 2
Win+Shift+3  →  Move to workspace 3
Win+Shift+4  →  Move to workspace 4
Win+Shift+5  →  Move to workspace 5
```

### Layout Management
```
Win+X           →  Flip layout HORIZONTALLY
Win+Y           →  Flip layout VERTICALLY
Win+Shift+Space →  Cycle to NEXT layout
```

### Application Launchers
```
Win+Enter  →  Open Windows TERMINAL
Win+Space  →  Open FLOW LAUNCHER
```

### Preserved Windows Shortcuts
```
Win+E      →  Open File EXPLORER
Win+D      →  Show DESKTOP
Win+Tab    →  TASK VIEW
Win+A      →  ACTION CENTER
Win+I/R    →  SETTINGS
```

### System
```
Win+Shift+C  →  RELOAD AHK configuration
Win+Shift+T  →  THEME SWITCHER (GUI)
Win+Shift+H or Win+?  →  HELP OVERLAY (show shortcuts)
```

---

## 🎓 Learning Path

### Day 1: Basic Navigation
1. `Win+H/J/K/L` - Focus windows
2. `Win+1/2/3` - Switch workspaces
3. `Win+Enter` - Open terminal
4. `Win+Q` - Close window

### Day 2: Window Management
1. `Win+Shift+H/J/K/L` - Move windows
2. `Win+T` - Toggle floating
3. `Win+F` - Toggle fullscreen
4. `Win+Shift+1/2/3` - Move to workspace

### Day 3: Advanced Features
1. `Win+Arrow` - Stack windows
2. `Win+N` - Cycle stacked windows
3. `Win+=/−` - Resize windows
4. `Win+Shift+R` - Retile

---

## 💡 Common Workflows

### Workflow 1: Split Screen Coding
```
1. Win+Enter      (Open terminal)
2. Win+Enter      (Open another terminal)
3. Win+L          (Focus right window)
4. Open VSCode
5. Win+H          (Back to terminal)
```

### Workflow 2: Browser + Notes
```
1. Open Browser
2. Win+2          (Move to workspace 2)
3. Open Obsidian/Joplin
4. Win+1          (Back to workspace 1)
5. Win+2          (Switch to notes)
```

### Workflow 3: Tabbed Terminals
```
1. Win+Enter      (Terminal 1)
2. Win+Enter      (Terminal 2)
3. Win+Down       (Stack terminal 2 below)
4. Win+N          (Cycle between tabs)
```

### Workflow 4: Focus Mode
```
1. Open your app
2. Win+F          (Fullscreen monocle)
3. Work without distractions
4. Win+F          (Exit monocle)
```

---

## 🎨 Theme-Specific Colors

### Gruvbox (Default)
- **Focused Border**: Orange (#d79921)
- **Stack Border**: Purple (#b16286)
- **Monocle Border**: Green (#689d6a)
- **Unfocused Border**: Gray (#504945)

### Tokyo Night
- **Focused Border**: Blue (#7aa2f7)
- **Stack Border**: Purple (#bb9af7)
- **Monocle Border**: Green (#9ece6a)
- **Unfocused Border**: Dark Blue (#3b4261)

### Catppuccin
- **Focused Border**: Blue (#89b4fa)
- **Stack Border**: Purple (#cba6f7)
- **Monocle Border**: Green (#a6e3a1)
- **Unfocused Border**: Gray (#45475a)

---

## 🔧 Customization

### Change Shortcuts
Edit: `~/.config/komorebi/komorebi.ahk`

Example - Change focus to Ctrl instead of Alt:
```autohotkey
; Current (Windows key)
LWin & h::komorebic("focus left")

; Change to Ctrl
^h::komorebic("focus left")

; Change back to Alt
!h::komorebic("focus left")
```

### Add Custom Shortcuts
```autohotkey
; Open Firefox
LWin & b::Run("firefox.exe")

; Open VSCode
LWin & c::Run("code.exe")

; Screenshot
LWin & s::Send("#+s")
```

---

## 📱 Printable Cheat Sheet

```
┌─────────────────────────────────────────────────────┐
│           KOMOREBI KEYBOARD SHORTCUTS               │
│              (Using Windows Key)                    │
├─────────────────────────────────────────────────────┤
│ FOCUS         Win+H/J/K/L    (←/↓/↑/→)            │
│ MOVE          Win+Shift+H/J/K/L                    │
│ STACK         Win+Arrow Keys                       │
│ UNSTACK       Win+U                                │
│ CYCLE STACK   Win+N / Win+Shift+N                 │
├─────────────────────────────────────────────────────┤
│ RESIZE        Win+= / Win+- (horizontal)           │
│               Win+Shift+= / Win+Shift+- (vertical) │
├─────────────────────────────────────────────────────┤
│ FLOAT         Win+T                                │
│ FULLSCREEN    Win+F                                │
│ CLOSE         Win+Q                                │
│ RETILE        Win+Shift+R                          │
│ PAUSE         Win+P                                │
├─────────────────────────────────────────────────────┤
│ WORKSPACE     Win+1/2/3/4/5                        │
│ MOVE TO WS    Win+Shift+1/2/3/4/5                  │
├─────────────────────────────────────────────────────┤
│ TERMINAL      Win+Enter                            │
│ LAUNCHER      Win+Space                            │
│ RELOAD        Win+Shift+C                          │
├─────────────────────────────────────────────────────┤
│ EXPLORER      Win+E                                │
│ DESKTOP       Win+D                                │
│ TASK VIEW     Win+Tab                              │
└─────────────────────────────────────────────────────┘

Note: Start Menu disabled when pressing Win alone
```

---

## 🆘 Emergency Commands

```powershell
# Stop Komorebi
komorebic stop

# Restart Komorebi
komorebic stop
komorebic start

# Pause temporarily
Alt+P

# Retile everything
Win+Shift+R
```

---

## 📖 More Information

See [KOMOREBI_GUIDE.md](KOMOREBI_GUIDE.md) for complete documentation.
