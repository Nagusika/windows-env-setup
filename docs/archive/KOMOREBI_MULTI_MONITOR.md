# Komorebi Multi-Monitor & Workspace Configuration

## 🖥️ Multi-Monitor Support (1-3 Screens)

Komorebi automatically adapts to your monitor setup:

### Single Monitor (1 Screen)
- **9 workspaces** available
- All workspaces on one screen
- Navigate with `Win+1` through `Win+9`

### Dual Monitor (2 Screens)
- **6 workspaces** (3 per monitor)
- Screen 1: Workspaces 1-3
- Screen 2: Workspaces 4-6
- Workspaces 7-9 available but on screen 2

### Triple Monitor (3 Screens)
- **9 workspaces** (3 per monitor)
- Screen 1: Workspaces 1-3 (HOME, TOOLS, MEDIA)
- Screen 2: Workspaces 4-6 (CODE, TERM, DOCS)
- Screen 3: Workspaces 7-9 (WEB, FILES, NOTES)

## 📋 Workspace Organization

### Screen 1: HOME & Communication
```
1:  HOME    - Default workspace, unassigned apps
2:  TOOLS   - Outlook, Teams, Slack, Discord
3:  MEDIA   - Spotify, VLC, mpv
```

### Screen 2: Development
```
4:  CODE    - VSCode, Windsurf, Cursor
5:  TERM    - Windows Terminal, shells
6:  DOCS    - Word, Notepad, Notepad++
```

### Screen 3: Navigation & Notes
```
7:  WEB     - Firefox, Chrome, Brave, LibreWolf
8:  FILES   - Windows Explorer
9:  NOTES   - Joplin, Obsidian
```

## 🎯 Workspace Icons (Nerd Fonts)

Each workspace has a unique icon in Zebar:

| Workspace | Icon | Meaning |
|-----------|------|---------|
| 1: HOME |  | House (home base) |
| 2: TOOLS |  | Tools (communication) |
| 3: MEDIA |  | Music note (media) |
| 4: CODE |  | Code brackets (development) |
| 5: TERM |  | Terminal prompt (shell) |
| 6: DOCS |  | Document (writing) |
| 7: WEB |  | Globe (web browsing) |
| 8: FILES |  | Folder (file management) |
| 9: NOTES |  | Notebook (note-taking) |

## 🚀 Application Auto-Assignment

Applications automatically open in their designated workspace:

### Communication (Workspace 2: TOOLS)
- Outlook.exe
- Teams.exe
- Slack.exe
- Discord.exe

### Media (Workspace 3: MEDIA)
- Spotify.exe
- vlc.exe
- mpv.exe

### Development (Workspace 4: CODE)
- Code.exe (VSCode)
- Windsurf.exe
- Cursor.exe

### Terminal (Workspace 5: TERM)
- WindowsTerminal.exe
- wt.exe

### Documents (Workspace 6: DOCS)
- WINWORD.EXE (Microsoft Word)
- notepad.exe
- notepad++.exe

### Web Browsers (Workspace 7: WEB)
- firefox.exe
- chrome.exe
- brave.exe
- librewolf.exe

### File Management (Workspace 8: FILES)
- explorer.exe

### Notes (Workspace 9: NOTES)
- Joplin.exe
- obsidian.exe

## ⌨️ Keyboard Shortcuts

### Workspace Navigation
```
Win+1  →  Go to workspace 1 (HOME)
Win+2  →  Go to workspace 2 (TOOLS)
Win+3  →  Go to workspace 3 (MEDIA)
Win+4  →  Go to workspace 4 (CODE)
Win+5  →  Go to workspace 5 (TERM)
Win+6  →  Go to workspace 6 (DOCS)
Win+7  →  Go to workspace 7 (WEB)
Win+8  →  Go to workspace 8 (FILES)
Win+9  →  Go to workspace 9 (NOTES)
```

### Move Window to Workspace
```
Win+Shift+1-9  →  Move current window to workspace 1-9
```

### Focus or Launch Applications (Win+Alt+Key)
```
Win+Alt+V  →  VSCode (focus if open, launch if not)
Win+Alt+W  →  Windsurf
Win+Alt+C  →  Cursor
Win+Alt+T  →  Terminal
Win+Alt+F  →  Firefox
Win+Alt+B  →  Brave
Win+Alt+L  →  LibreWolf
Win+Alt+E  →  Explorer
Win+Alt+N  →  Joplin
Win+Alt+O  →  Obsidian
Win+Alt+S  →  Spotify
Win+Alt+M  →  Outlook
```

## 🔄 Focus-or-Launch Behavior

The `Win+Alt+Key` shortcuts are intelligent:

1. **If app is already open**: Focuses the existing window
2. **If app is not open**: Launches the application
3. **Works across workspaces**: Finds the app anywhere

**Example**:
- Press `Win+Alt+F` → Opens Firefox if not running
- Press `Win+Alt+F` again → Switches to Firefox window
- Works even if Firefox is on a different workspace!

## 📊 Zebar Status Bar

The status bar shows:

### Left Side
- 🪟 Komorebi icon
- Workspace indicators with icons (e.g., "1: ")
- Current workspace highlighted
- Window list (up to 5 windows with icons)

### Right Side
- CPU usage
- Memory usage
- Clock (HH:MM  DD/MM/YYYY)

### Workspace Display
```
[1: ] [2: ] [3: ] | Firefox | VSCode | Terminal
```

Focused workspace has colored background, others are dimmed.

## 🎨 Window List in Zebar

Shows open windows in current workspace:
- Maximum 5 windows displayed
- Application icons shown
- Focused window highlighted
- Click to focus window (if Zebar supports it)

## 💡 Usage Tips

### Organizing Your Workflow

**Morning Setup**:
1. `Win+2` → Open Outlook/Teams (TOOLS)
2. `Win+4` → Open VSCode (CODE)
3. `Win+5` → Open Terminal (TERM)
4. `Win+7` → Open Firefox (WEB)

**Quick App Access**:
- `Win+Alt+V` → Jump to VSCode
- `Win+Alt+F` → Jump to Firefox
- `Win+Alt+T` → Jump to Terminal

**Moving Windows**:
- Open app in wrong workspace?
- `Win+Shift+4` → Move to CODE workspace
- `Win+Shift+7` → Move to WEB workspace

### Multi-Monitor Workflows

**3-Monitor Setup** (Recommended):
- **Left**: Communication & Media (WS 1-3)
- **Center**: Development (WS 4-6)
- **Right**: Web & Notes (WS 7-9)

**2-Monitor Setup**:
- **Left**: Home & Tools (WS 1-3)
- **Right**: Code & Web (WS 4-7)

**1-Monitor Setup**:
- Use all 9 workspaces
- Group by task type
- Switch frequently with `Win+1-9`

## 🔧 Customization

### Add More Apps to Auto-Assignment

Edit `~/.config/komorebi/komorebi.json`:

```json
"workspace_rules": [
  { "kind": "Exe", "id": "YourApp.exe", "matching_strategy": "Legacy", "workspace": "CODE" }
]
```

### Add More App Launchers

Edit `~/.config/komorebi/komorebi.ahk`:

```autohotkey
; Add your app
LWin & !y::FocusOrLaunch("YourApp.exe")
```

### Change Workspace Icons

Edit `~/.config/zebar/config.json`:

```json
"workspace_labels": {
  "CODE": "4:  ",
  "WEB": "7:  "
}
```

## 🎯 Workspace Strategies

### By Project
- WS 1: Project A (Code + Terminal)
- WS 2: Project B (Code + Terminal)
- WS 3: Documentation

### By Activity
- WS 1: Coding
- WS 2: Testing
- WS 3: Documentation
- WS 4: Communication

### By Time
- WS 1: Morning tasks
- WS 2: Afternoon tasks
- WS 3: Evening tasks

## 📈 Productivity Benefits

### Context Switching
- ✅ Dedicated workspace per task
- ✅ No window hunting
- ✅ Quick app access with `Win+Alt+Key`

### Focus
- ✅ One task per workspace
- ✅ No distractions from other apps
- ✅ Clear visual separation

### Organization
- ✅ Apps auto-open in correct workspace
- ✅ Consistent layout
- ✅ Easy to remember (`Win+4` = CODE)

## 🐛 Troubleshooting

### App Opens in Wrong Workspace

**Check workspace rules**:
```powershell
notepad "$env:USERPROFILE\.config\komorebi\komorebi.json"
```

Look for `workspace_rules` section and verify app name.

### Workspace Icons Not Showing

**Install Nerd Font**:
- CaskaydiaCove Nerd Font required
- Should be installed by main script
- Restart Zebar after font installation

### Focus-or-Launch Not Working

**Check app executable name**:
```powershell
Get-Process | Where-Object {$_.ProcessName -like "*code*"}
```

Update AHK config with correct exe name.

### Zebar Not Showing Windows

**Restart Zebar**:
```powershell
Stop-Process -Name zebar -Force
# Komorebi will restart it automatically
```

## 📚 Related Documentation

- **[KOMOREBI_SHORTCUTS.md](KOMOREBI_SHORTCUTS.md)** - All keyboard shortcuts
- **[KOMOREBI_GUIDE.md](KOMOREBI_GUIDE.md)** - Complete Komorebi guide
- **[KOMOREBI_ARROW_KEYS.md](KOMOREBI_ARROW_KEYS.md)** - Navigation options

## ✨ Summary

**Multi-Monitor Support**:
- ✅ 1-3 screens automatically detected
- ✅ 9 workspaces with meaningful names
- ✅ Icons for visual identification

**Auto-Assignment**:
- ✅ Apps open in designated workspace
- ✅ Organized by category
- ✅ Customizable rules

**Quick Launch**:
- ✅ `Win+Alt+Key` for common apps
- ✅ Focus if open, launch if not
- ✅ Works across workspaces

**Zebar Integration**:
- ✅ Workspace names with icons
- ✅ Window list display
- ✅ Visual feedback

**Perfect for**:
- 👨‍💻 Developers with multiple projects
- 🎨 Designers with many tools
- 📊 Analysts with various apps
- 🖥️ Multi-monitor power users

---

**Enjoy your organized, multi-monitor Komorebi setup!** 🚀
