# GlazeWM + Zebar Configuration Guide

## 📖 Overview

**GlazeWM** is a tiling window manager for Windows inspired by i3wm and bspwm. It provides keyboard-driven window management and workspace organization.

**Zebar** is a customizable status bar that integrates seamlessly with GlazeWM, providing system information and workspace indicators.

## 🎯 Features

### GlazeWM Features
- ⌨️ **Keyboard-Driven**: Manage windows entirely with keyboard shortcuts
- 🪟 **Tiling Layout**: Automatic window arrangement in various layouts
- 🖥️ **Multi-Monitor Support**: Bind workspaces to specific monitors
- 🎨 **Window Effects**: Borders, rounded corners, transparency
- 🔧 **Highly Configurable**: YAML-based configuration

### Zebar Features
- 📊 **System Monitoring**: CPU, Memory, Battery, Network status
- 🌦️ **Weather Widget**: Real-time weather information
- 🏢 **Workspace Indicators**: Visual workspace navigation
- 🎨 **Gruvbox Theme**: Beautiful dark theme with accent colors
- ⚡ **Real-time Updates**: Live system information

## 🚀 Quick Start

### Starting GlazeWM
After installation, GlazeWM is configured to start automatically on system boot. You can also start it manually:

```powershell
glazewm
```

### Starting Zebar
Zebar is automatically started by GlazeWM. To start it manually:

```powershell
zebar
```

### Stopping Everything
Press `Alt + Shift + E` to safely exit both GlazeWM and Zebar.

## ⌨️ Default Keybindings

### Window Management
- `Alt + H/J/K/L` or `Alt + Arrow Keys` - Focus window in direction
- `Alt + Shift + Arrow Keys` - Move window in direction
- `Alt + Enter` - Open Windows Terminal
- `Alt + Shift + Q` - Close focused window
- `Alt + T` - Toggle tiling mode
- `Alt + F` - Toggle fullscreen
- `Alt + M` - Minimize window
- `Alt + Shift + Space` - Toggle floating mode

### Workspace Navigation
- `Alt + 1-9` - Switch to workspace 1-9
- `Alt + Shift + 1-9` - Move window to workspace 1-9
- `Alt + A` - Previous workspace
- `Alt + S` - Next workspace
- `Alt + D` - Last used workspace

### Window Resizing
- `Alt + R` - Enter resize mode
  - In resize mode: `H/J/K/L` or Arrow Keys to resize
  - `Enter` or `Escape` to exit resize mode
- `Alt + U/I/O/P` - Quick resize shortcuts

### System
- `Alt + Shift + R` - Reload GlazeWM configuration
- `Alt + Shift + W` - Redraw all windows
- `Alt + Shift + E` - Exit GlazeWM (and Zebar)
- `Alt + Shift + P` - Pause all keybindings (press again to resume)

## 🖥️ Workspace Configuration

The default configuration includes 9 workspaces across 3 monitors:

### Monitor 0 (Primary)
- **Workspace 1 (🏡)**: Home - General purpose
- **Workspace 2 (📧)**: Mail/Teams - Email and communication apps
- **Workspace 3 (🎵)**: Media - Spotify and media players

### Monitor 1 (Secondary)
- **Workspace 4 (🖥️)**: VS Code - Development environment
- **Workspace 5 (📟)**: Terminal - Command line interface
- **Workspace 6 (📑)**: Office - Microsoft Office apps

### Monitor 2 (Tertiary)
- **Workspace 7 (🌍)**: Browser - Web browsing
- **Workspace 8 (📂)**: Explorer - File management
- **Workspace 9 (📜)**: Notes - Note-taking apps

## 🎨 Window Rules

The configuration automatically assigns applications to specific workspaces:

- **Outlook, MS Teams** → Workspace 2 (📧)
- **Spotify** → Workspace 3 (🎵)
- **VS Code, Cursor** → Workspace 4 (🖥️)
- **Windows Terminal, CMD** → Workspace 5 (📟)
- **Word, Excel, Visio** → Workspace 6 (📑)
- **Edge, Chrome, Firefox, Brave** → Workspace 7 (🌍)
- **File Explorer** → Workspace 8 (📂)
- **OneNote, ChatGPT** → Workspace 9 (📜)

## 🎨 Visual Effects

### Focused Window
- ✅ Green border (`#98971a` - Gruvbox green)
- ✅ Rounded corners
- ✅ Slightly transparent background (99%)

### Non-Focused Windows
- ⬜ Square corners
- 🔲 Transparent (99%)
- 🚫 No border

## 🔧 Customization

### Configuration Files Location
- **GlazeWM**: `%USERPROFILE%\.glzr\glazewm\config.yaml`
- **Zebar HTML**: `%USERPROFILE%\.glzr\zebar\with-glazewm.html`
- **Zebar Styles**: `%USERPROFILE%\.glzr\zebar\styles_gruvbox.css`

### Editing Configuration
1. Edit the configuration files in the locations above
2. Press `Alt + Shift + R` to reload GlazeWM
3. Zebar will automatically reload when GlazeWM reloads

### Backup Configuration
The installation script backs up your configuration files to:
- `windows-env-setup\config\glazewm-config.yaml`
- `windows-env-setup\config\zebar-with-glazewm.html`
- `windows-env-setup\config\styles_gruvbox.css`

## 📊 Zebar Status Bar Information

The status bar displays (from left to right):

### Left Section
- 🪟 Bar icon (GlazeWM logo)
- 🏢 Workspace indicators (clickable tabs with tab-style design)
- 📝 Current window title

### Center Section
- (Empty / expandable)

### Right Section
- 🎵 **Media controls** (when playing) - Previous/Play-Pause/Next
- ⚡ **Tiling direction toggle** - Horizontal/Vertical indicator (clickable)
- 🌐 **Network status** (clickable) - Toggle between SSID and details
- 🧠 **Memory usage** (clickable) - Toggle between % and GB used/total
- ⚡ **CPU usage** (clickable) - Toggle between % and GHz frequency
- 🔋 **Battery level** (clickable) - Toggle between % and time remaining
- 🌦️ **Weather information** - Temperature with icon
- 🕐 **Clock** - Day, Date, Time

### Interactive Features
All stats (network, memory, CPU, battery) are **clickable** and toggle between:
- **Simple view**: Percentage or basic info
- **Detailed view**: Additional information (GB, GHz, time remaining, etc.)

## 🐛 Troubleshooting

### GlazeWM not starting
```powershell
# Check if GlazeWM is installed
glazewm --version

# Check logs
cat $env:USERPROFILE\.glzr\glazewm\errors.log
```

### Zebar not appearing
```powershell
# Check if Zebar is running
Get-Process -Name zebar

# Start Zebar manually
zebar

# Check logs
cat $env:USERPROFILE\.glzr\zebar\errors.log
```

### Windows not tiling properly
1. Press `Alt + Shift + W` to redraw all windows
2. Press `Alt + Shift + R` to reload configuration
3. Check if the window is in the ignore list

### Keybindings not working
1. Press `Alt + Shift + P` to ensure pause mode is not active
2. Check for conflicts with other applications
3. Reload configuration with `Alt + Shift + R`

## 🔗 Additional Resources

- **GlazeWM GitHub**: https://github.com/glzr-io/glazewm
- **GlazeWM Documentation**: https://github.com/glzr-io/glazewm/wiki
- **Zebar GitHub**: https://github.com/glzr-io/zebar
- **Gruvbox Theme**: https://github.com/morhetz/gruvbox

## 💡 Tips and Tricks

1. **Quick Terminal**: Press `Alt + Enter` anywhere to open a new terminal
2. **Float on Demand**: Press `Alt + Shift + Space` to float a window temporarily
3. **Focus Cycling**: Press `Alt + Space` to cycle through tiling → floating → fullscreen
4. **Multi-Monitor**: Use `Alt + Shift + H/L` to move workspaces between monitors
5. **Workspace Memory**: Press `Alt + D` to jump back to your previous workspace

## 🎯 Next Steps

1. **Learn the keybindings** - Start with window focus and workspace switching
2. **Customize workspaces** - Edit `config.yaml` to match your workflow
3. **Adjust window rules** - Automatically assign apps to your preferred workspaces
4. **Tweak the theme** - Modify colors in Zebar's config to match your style
5. **Create your workflow** - Organize your applications across workspaces efficiently

---

**Happy tiling!** 🚀

