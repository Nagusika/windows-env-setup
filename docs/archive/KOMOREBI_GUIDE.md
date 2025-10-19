# Komorebi Tiling Window Manager Guide

## 🪟 What is Komorebi?

Komorebi is a tiling window manager for Windows that automatically arranges your windows in a non-overlapping layout. It's inspired by Linux tiling window managers like i3, bspwm, and dwm.

## ✨ Features

- **Automatic Window Tiling** - Windows are automatically arranged
- **Multiple Workspaces** - Organize windows across 5 workspaces
- **Keyboard-Driven** - Control everything with keyboard shortcuts
- **Customizable Borders** - Visual indicators for focused windows
- **Stack Windows** - Group windows in tabs
- **Floating Windows** - Exceptions for dialogs and specific apps
- **Status Bar Integration** - Works with Zebar for system info
- **Theme Support** - Gruvbox, Tokyo Night, Catppuccin

## 🚀 Installation

### Automatic Installation

```powershell
# Run the main installer
.\install.ps1

# When prompted, choose to install Komorebi
Install Komorebi tiling window manager? (y/N): y

# Select your theme
Select theme for Komorebi:
  1. Gruvbox (warm, retro)
  2. Tokyo Night (cool, modern)
  3. Catppuccin (pastel, elegant)
Enter choice (1-3, default: 1): 1
```

### Manual Installation

```powershell
# Install with specific theme
.\scripts\install-komorebi.ps1 -Theme gruvbox
.\scripts\install-komorebi.ps1 -Theme tokyonight
.\scripts\install-komorebi.ps1 -Theme catppuccin
```

## 🎨 Themes

### Gruvbox (Default)
- **Style**: Warm, retro, high contrast
- **Colors**: Orange, purple, green accents on dark brown
- **Best for**: Long coding sessions, easy on the eyes

### Tokyo Night
- **Style**: Cool, modern, vibrant
- **Colors**: Blue, purple, green accents on dark blue
- **Best for**: Night owls, modern aesthetic

### Catppuccin
- **Style**: Pastel, elegant, soft
- **Colors**: Blue, purple, green accents on dark gray
- **Best for**: Gentle on eyes, aesthetic focus

## ⌨️ Keyboard Shortcuts

### Window Focus
| Shortcut | Action |
|----------|--------|
| `Alt+H` | Focus window to the left |
| `Alt+J` | Focus window below |
| `Alt+K` | Focus window above |
| `Alt+L` | Focus window to the right |

### Window Movement
| Shortcut | Action |
|----------|--------|
| `Alt+Shift+H` | Move window left |
| `Alt+Shift+J` | Move window down |
| `Alt+Shift+K` | Move window up |
| `Alt+Shift+L` | Move window right |

### Window Stacking
| Shortcut | Action |
|----------|--------|
| `Alt+Left` | Stack window to the left |
| `Alt+Down` | Stack window below |
| `Alt+Up` | Stack window above |
| `Alt+Right` | Stack window to the right |
| `Alt+U` | Unstack window |
| `Alt+N` | Cycle to next stacked window |
| `Alt+Shift+N` | Cycle to previous stacked window |

### Window Resizing
| Shortcut | Action |
|----------|--------|
| `Alt+=` | Increase horizontal size |
| `Alt+-` | Decrease horizontal size |
| `Alt+Shift+=` | Increase vertical size |
| `Alt+Shift+-` | Decrease vertical size |

### Window Manipulation
| Shortcut | Action |
|----------|--------|
| `Alt+T` | Toggle floating mode |
| `Alt+F` | Toggle monocle (fullscreen) |
| `Alt+Q` | Close window |
| `Alt+Shift+R` | Retile all windows |
| `Alt+P` | Pause/unpause Komorebi |

### Workspaces
| Shortcut | Action |
|----------|--------|
| `Alt+1` | Switch to workspace 1 |
| `Alt+2` | Switch to workspace 2 |
| `Alt+3` | Switch to workspace 3 |
| `Alt+4` | Switch to workspace 4 |
| `Alt+5` | Switch to workspace 5 |
| `Alt+Shift+1` | Move window to workspace 1 |
| `Alt+Shift+2` | Move window to workspace 2 |
| `Alt+Shift+3` | Move window to workspace 3 |
| `Alt+Shift+4` | Move window to workspace 4 |
| `Alt+Shift+5` | Move window to workspace 5 |

### Layouts
| Shortcut | Action |
|----------|--------|
| `Alt+X` | Flip layout horizontally |
| `Alt+Y` | Flip layout vertically |
| `Alt+Shift+Space` | Cycle to next layout |

### Application Launchers
| Shortcut | Action |
|----------|--------|
| `Alt+Enter` | Open Windows Terminal |
| `Alt+Space` | Open Flow Launcher |

### System
| Shortcut | Action |
|----------|--------|
| `Alt+Shift+C` | Reload AHK configuration |

## 📁 Configuration Files

### Komorebi Configuration
**Location**: `~/.config/komorebi/komorebi.json`

```json
{
  "default_workspace_padding": 10,
  "default_container_padding": 10,
  "border": true,
  "border_width": 3,
  "monitors": [
    {
      "workspaces": [
        { "name": "I", "layout": "BSP" },
        { "name": "II", "layout": "BSP" },
        { "name": "III", "layout": "BSP" },
        { "name": "IV", "layout": "BSP" },
        { "name": "V", "layout": "BSP" }
      ]
    }
  ]
}
```

### AutoHotkey Configuration
**Location**: `~/.config/komorebi/komorebi.ahk`

Contains all keyboard shortcuts and custom bindings.

### Application Rules
**Location**: `~/.config/komorebi/applications.yaml`

Define app-specific behavior (floating, tiling, etc.).

### Zebar Configuration
**Location**: `~/.config/zebar/config.json`

Status bar configuration with theme colors.

## 🔧 Usage

### Starting Komorebi

**Automatic (on login)**:
- Komorebi starts automatically via startup shortcut

**Manual start**:
```powershell
autohotkey.exe "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

**Command line**:
```powershell
komorebic start
```

### Stopping Komorebi

```powershell
komorebic stop
```

Or press `Alt+P` to pause temporarily.

### Checking Status

```powershell
komorebic state
```

## 🎯 Common Workflows

### Workflow 1: Code + Browser + Terminal

1. Open VSCode → `Alt+1` (workspace 1)
2. Open Browser → `Alt+2` (workspace 2)
3. Open Terminal → `Alt+Enter` then `Alt+3` (workspace 3)
4. Switch between them with `Alt+1/2/3`

### Workflow 2: Stacked Terminals

1. Open first terminal → `Alt+Enter`
2. Open second terminal → `Alt+Enter`
3. Stack them → `Alt+Down` (stack below)
4. Cycle through → `Alt+N`

### Workflow 3: Floating Dialog

1. Open a dialog (Settings, Task Manager)
2. It automatically floats (configured in applications.yaml)
3. Or manually toggle → `Alt+T`

### Workflow 4: Focus Mode

1. Open your main app
2. Press `Alt+F` for monocle (fullscreen)
3. Press `Alt+F` again to exit

## 🛠️ Customization

### Change Theme

```powershell
.\scripts\install-komorebi.ps1 -Theme tokyonight
```

### Modify Keyboard Shortcuts

Edit `~/.config/komorebi/komorebi.ahk`:

```autohotkey
; Change Alt+H to Ctrl+H
^h::komorebic("focus left")
```

Then reload: `Alt+Shift+C`

### Add Floating Rules

Edit `~/.config/komorebi/applications.yaml`:

```yaml
- name: "My App"
  identifier:
    kind: Exe
    id: myapp.exe
  options:
    - Float
```

Then retile: `Alt+Shift+R`

### Adjust Padding

Edit `~/.config/komorebi/komorebi.json`:

```json
{
  "default_workspace_padding": 20,
  "default_container_padding": 15
}
```

### Change Border Width

Edit `~/.config/komorebi/komorebi.json`:

```json
{
  "border_width": 5
}
```

## 🔌 Additional Tools

### Zebar (Status Bar)
- **What**: Customizable status bar
- **Shows**: Workspaces, window title, CPU, memory, time
- **Config**: `~/.config/zebar/config.json`

### Komoflow (Flow Launcher Plugin)
- **What**: Control Komorebi from Flow Launcher
- **Install**: Open Flow Launcher → `pm install komoflow`
- **Usage**: `Alt+Space` → type "komo"

### Komorebi-loading
- **What**: Cute loading screen when starting Komorebi
- **Location**: `~/.config/komorebi-loading`
- **Runs**: Automatically on startup

## 🐛 Troubleshooting

### Komorebi doesn't start
```powershell
# Check if running
komorebic state

# Start manually
komorebic start

# Check logs
Get-Content "$env:USERPROFILE\.config\komorebi\komorebi.log"
```

### Windows not tiling
```powershell
# Retile all windows
komorebic retile

# Or press Alt+Shift+R
```

### Keyboard shortcuts not working
```powershell
# Check if AutoHotkey is running
Get-Process autohotkey

# Restart AHK
autohotkey.exe "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
```

### Wrong windows floating
Edit `~/.config/komorebi/applications.yaml` and add/remove float rules.

### Borders not showing
```powershell
# Check border settings
komorebic state | Select-String "border"

# Enable borders
komorebic toggle-border
```

## 📚 Advanced Usage

### Multiple Monitors

Komorebi automatically detects multiple monitors. Each monitor has its own workspaces.

```powershell
# Move window to next monitor
komorebic move-to-monitor-workspace 1 0
```

### Custom Layouts

Available layouts:
- **BSP** (Binary Space Partitioning) - Default, balanced
- **Columns** - Vertical columns
- **Rows** - Horizontal rows
- **VerticalStack** - Master + stack
- **HorizontalStack** - Master + stack horizontal

Change layout:
```powershell
komorebic workspace-layout 0 Columns
```

### Window Rules by Title

```yaml
- name: "Settings Window"
  identifier:
    kind: Title
    id: "Settings"
  options:
    - Float
```

### Workspace-Specific Layouts

Edit `komorebi.json`:
```json
{
  "workspaces": [
    { "name": "Code", "layout": "BSP" },
    { "name": "Browser", "layout": "Columns" },
    { "name": "Terminal", "layout": "VerticalStack" }
  ]
}
```

## 🎓 Learning Resources

- **Official Docs**: https://lgug2z.github.io/komorebi/
- **GitHub**: https://github.com/LGUG2Z/komorebi
- **Awesome Komorebi**: https://github.com/LGUG2Z/awesome-komorebi
- **Discord**: Join the Komorebi Discord for support

## 💡 Tips & Tricks

1. **Start Small**: Use 2-3 workspaces initially
2. **Learn Gradually**: Master focus/move shortcuts first
3. **Customize Later**: Use defaults for a week before customizing
4. **Use Stacking**: Great for multiple terminals or browsers
5. **Floating Exceptions**: Add apps that don't tile well to float rules
6. **Monocle Mode**: Perfect for presentations or focus work
7. **Flow Launcher**: Combine with `Alt+Space` for quick app launching
8. **Multiple Monitors**: Each monitor is independent

## 🔄 Updating

### Update Komorebi
```powershell
winget upgrade LGUG2Z.komorebi
```

### Update Configuration
```powershell
.\scripts\install-komorebi.ps1 -Force -Theme <your-theme>
```

## 🗑️ Uninstalling

```powershell
# Stop Komorebi
komorebic stop

# Uninstall
winget uninstall LGUG2Z.komorebi

# Remove configurations
Remove-Item -Recurse "$env:USERPROFILE\.config\komorebi"
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk"
```

---

**Enjoy your tiling window manager experience on Windows!** 🚀
