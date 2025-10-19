# Installation and configuration of Komorebi Tiling Window Manager
# Komorebi is a tiling window manager for Windows with extensive customization

param(
    [switch]$Force,
    [ValidateSet("gruvbox", "tokyonight", "catppuccin")]
    [string]$Theme = "gruvbox"
)

$ErrorActionPreference = "Stop"

function Write-Log {
    param($Message, $Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    $Color = switch ($Level) {
        "SUCCESS" { "Green" }
        "ERROR" { "Red" }
        "WARN" { "Yellow" }
        "SKIP" { "Cyan" }
        default { "White" }
    }
    
    Write-Host $LogMessage -ForegroundColor $Color
    $LogPath = Join-Path $PSScriptRoot "..\logs\komorebi.log"
    Add-Content -Path $LogPath -Value $LogMessage
}

function Test-KomorebiInstalled {
    try {
        # Try to find komorebic in PATH
        $null = Get-Command komorebic -ErrorAction Stop
        return $true
    }
    catch {
        # Check common installation locations
        $possiblePaths = @(
            "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\LGUG2Z.komorebi_*\komorebic.exe",
            "$env:LOCALAPPDATA\Programs\komorebi\komorebic.exe",
            "$env:ProgramFiles\komorebi\komorebic.exe"
        )
        
        foreach ($path in $possiblePaths) {
            $found = Get-Item $path -ErrorAction SilentlyContinue
            if ($found) {
                return $true
            }
        }
        
        return $false
    }
}

function Refresh-EnvironmentPath {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
}

function Install-Komorebi {
    Write-Log "Installing Komorebi..."
    
    try {
        # Install via winget
        $result = winget install -e --id LGUG2Z.komorebi --silent --accept-package-agreements --accept-source-agreements 2>&1
        
        # Refresh PATH to detect newly installed executables
        Refresh-EnvironmentPath
        Start-Sleep -Seconds 2
        
        # Verify installation
        if (-not (Test-KomorebiInstalled)) {
            Write-Log "Komorebi may be installed but not yet in PATH. Continuing anyway..." "WARN"
        }
        else {
            Write-Log "Komorebi installed successfully" "SUCCESS"
        }
    }
    catch {
        Write-Log "Error installing Komorebi: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-AutoHotkey {
    Write-Log "Installing AutoHotkey v2..."
    
    try {
        # Check if already installed
        $ahkInstalled = Get-Command autohotkey -ErrorAction SilentlyContinue
        if ($ahkInstalled) {
            Write-Log "AutoHotkey already installed" "INFO"
            return
        }
        
        # Install AutoHotkey v2
        winget install -e --id AutoHotkey.AutoHotkey --silent --accept-package-agreements --accept-source-agreements
        
        Write-Log "AutoHotkey installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing AutoHotkey: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Install-Zebar {
    Write-Log "Installing Zebar status bar..."
    
    try {
        # Install via winget
        winget install -e --id glzr-io.zebar --silent --accept-package-agreements --accept-source-agreements
        
        Write-Log "Zebar installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Zebar: $($_.Exception.Message)" "WARN"
        Write-Log "You can install Zebar manually from: https://github.com/glzr-io/zebar" "INFO"
    }
}

function Install-KomorebiLoading {
    Write-Log "Installing komorebi-loading..."
    
    try {
        # Check if Node.js is installed
        $nodeInstalled = Get-Command node -ErrorAction SilentlyContinue
        if (-not $nodeInstalled) {
            Write-Log "Node.js not found, installing..." "WARN"
            winget install -e --id OpenJS.NodeJS --silent --accept-package-agreements --accept-source-agreements
        }
        
        # Clone komorebi-loading repository
        $loadingPath = "$env:USERPROFILE\.config\komorebi-loading"
        if (Test-Path $loadingPath) {
            Write-Log "komorebi-loading already exists at $loadingPath" "INFO"
        }
        else {
            git clone https://github.com/SuppliedOrange/komorebi-loading.git $loadingPath
            
            # Install dependencies
            Push-Location $loadingPath
            npm install
            Pop-Location
            
            Write-Log "komorebi-loading installed successfully" "SUCCESS"
        }
    }
    catch {
        Write-Log "Error installing komorebi-loading: $($_.Exception.Message)" "WARN"
        Write-Log "You can install manually from: https://github.com/SuppliedOrange/komorebi-loading" "INFO"
    }
}

function Install-FlowLauncherPlugin {
    Write-Log "Installing komoflow Flow Launcher plugin..."
    
    try {
        # Check if Flow Launcher is installed
        $flowPath = "$env:LOCALAPPDATA\FlowLauncher"
        if (-not (Test-Path $flowPath)) {
            Write-Log "Flow Launcher not found, skipping komoflow installation" "WARN"
            Write-Log "Install Flow Launcher first, then install komoflow from Flow Launcher settings" "INFO"
            return
        }
        
        Write-Log "Install komoflow from Flow Launcher: pm install komoflow" "INFO"
    }
    catch {
        Write-Log "Error checking Flow Launcher: $($_.Exception.Message)" "WARN"
    }
}

function New-KomorebiConfig {
    param([string]$Theme)
    
    Write-Log "Creating Komorebi configuration with $Theme theme..."
    
    try {
        $configPath = "$env:USERPROFILE\.config\komorebi"
        if (!(Test-Path $configPath)) {
            New-Item -ItemType Directory -Path $configPath -Force | Out-Null
        }
        
        # Get theme colors
        $colors = Get-ThemeColors -Theme $Theme
        
        # Create komorebi.json configuration
        $komorebiConfig = @"
{
  "`$schema": "https://raw.githubusercontent.com/LGUG2Z/komorebi/master/schema.json",
  "app_specific_configuration_path": "`$Env:USERPROFILE/.config/komorebi/applications.yaml",
  "window_hiding_behaviour": "Cloak",
  "cross_monitor_move_behaviour": "Insert",
  "default_workspace_padding": 10,
  "default_container_padding": 10,
  "border": true,
  "border_width": 3,
  "border_offset": -1,
  "border_colours": {
    "single": "$($colors.BorderFocused)",
    "stack": "$($colors.BorderStack)",
    "monocle": "$($colors.BorderMonocle)",
    "unfocused": "$($colors.BorderUnfocused)"
  },
  "stackbar": {
    "height": 30,
    "mode": "OnStack",
    "tabs": {
      "width": 200,
      "focused_text": "$($colors.StackbarFocusedText)",
      "unfocused_text": "$($colors.StackbarUnfocusedText)",
      "background": "$($colors.StackbarBackground)"
    }
  },
  "monitors": [
    {
      "workspaces": [
        { "name": "1:HOME", "layout": "BSP" },
        { "name": "2:TOOLS", "layout": "BSP" },
        { "name": "3:MEDIA", "layout": "BSP" }
      ]
    },
    {
      "workspaces": [
        { "name": "4:CODE", "layout": "BSP" },
        { "name": "5:TERM", "layout": "BSP" },
        { "name": "6:DOCS", "layout": "BSP" }
      ]
    },
    {
      "workspaces": [
        { "name": "7:WEB", "layout": "BSP" },
        { "name": "8:FILES", "layout": "BSP" },
        { "name": "9:NOTES", "layout": "BSP" }
      ]
    }
  ],
  "workspace_rules": [
    { "kind": "Exe", "id": "Outlook.exe", "matching_strategy": "Legacy", "workspace": "TOOLS" },
    { "kind": "Exe", "id": "Teams.exe", "matching_strategy": "Legacy", "workspace": "TOOLS" },
    { "kind": "Exe", "id": "Slack.exe", "matching_strategy": "Legacy", "workspace": "TOOLS" },
    { "kind": "Exe", "id": "Discord.exe", "matching_strategy": "Legacy", "workspace": "TOOLS" },
    { "kind": "Exe", "id": "Spotify.exe", "matching_strategy": "Legacy", "workspace": "MEDIA" },
    { "kind": "Exe", "id": "vlc.exe", "matching_strategy": "Legacy", "workspace": "MEDIA" },
    { "kind": "Exe", "id": "mpv.exe", "matching_strategy": "Legacy", "workspace": "MEDIA" },
    { "kind": "Exe", "id": "Code.exe", "matching_strategy": "Legacy", "workspace": "CODE" },
    { "kind": "Exe", "id": "Windsurf.exe", "matching_strategy": "Legacy", "workspace": "CODE" },
    { "kind": "Exe", "id": "Cursor.exe", "matching_strategy": "Legacy", "workspace": "CODE" },
    { "kind": "Exe", "id": "WindowsTerminal.exe", "matching_strategy": "Legacy", "workspace": "TERM" },
    { "kind": "Exe", "id": "wt.exe", "matching_strategy": "Legacy", "workspace": "TERM" },
    { "kind": "Exe", "id": "WINWORD.EXE", "matching_strategy": "Legacy", "workspace": "DOCS" },
    { "kind": "Exe", "id": "notepad.exe", "matching_strategy": "Legacy", "workspace": "DOCS" },
    { "kind": "Exe", "id": "notepad++.exe", "matching_strategy": "Legacy", "workspace": "DOCS" },
    { "kind": "Exe", "id": "firefox.exe", "matching_strategy": "Legacy", "workspace": "WEB" },
    { "kind": "Exe", "id": "chrome.exe", "matching_strategy": "Legacy", "workspace": "WEB" },
    { "kind": "Exe", "id": "brave.exe", "matching_strategy": "Legacy", "workspace": "WEB" },
    { "kind": "Exe", "id": "librewolf.exe", "matching_strategy": "Legacy", "workspace": "WEB" },
    { "kind": "Exe", "id": "explorer.exe", "matching_strategy": "Legacy", "workspace": "FILES" },
    { "kind": "Exe", "id": "Joplin.exe", "matching_strategy": "Legacy", "workspace": "NOTES" },
    { "kind": "Exe", "id": "obsidian.exe", "matching_strategy": "Legacy", "workspace": "NOTES" }
  ],
  "float_rules": [
    { "kind": "Exe", "id": "explorer.exe", "matching_strategy": "Legacy" },
    { "kind": "Exe", "id": "taskmgr.exe", "matching_strategy": "Legacy" },
    { "kind": "Title", "id": "Settings", "matching_strategy": "Legacy" },
    { "kind": "Class", "id": "TaskManagerWindow", "matching_strategy": "Legacy" }
  ],
  "active_window_border_colours": {
    "single": "$($colors.BorderFocused)",
    "stack": "$($colors.BorderStack)",
    "monocle": "$($colors.BorderMonocle)"
  }
}
"@
        
        $komorebiConfig | Set-Content -Path "$configPath\komorebi.json" -Encoding UTF8
        Write-Log "Komorebi configuration created with $Theme theme" "SUCCESS"
        
        # Create applications.yaml for app-specific rules
        $applicationsConfig = @"
# Application-specific rules for Komorebi
# See: https://lgug2z.github.io/komorebi/common-workflows/app-specific-configuration.html

- name: "Firefox"
  identifier:
    kind: Exe
    id: firefox.exe
  options:
    - ObjectNameChange

- name: "Chrome"
  identifier:
    kind: Exe
    id: chrome.exe
  options:
    - ObjectNameChange

- name: "VSCode"
  identifier:
    kind: Exe
    id: Code.exe
  options:
    - ObjectNameChange

- name: "Windows Terminal"
  identifier:
    kind: Exe
    id: WindowsTerminal.exe
  options:
    - ObjectNameChange
"@
        
        $applicationsConfig | Set-Content -Path "$configPath\applications.yaml" -Encoding UTF8
        Write-Log "Applications configuration created" "SUCCESS"
        
    }
    catch {
        Write-Log "Error creating Komorebi configuration: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function Get-ThemeColors {
    param([string]$Theme)
    
    switch ($Theme) {
        "gruvbox" {
            return @{
                BorderFocused = "#d79921"
                BorderStack = "#b16286"
                BorderMonocle = "#689d6a"
                BorderUnfocused = "#504945"
                StackbarFocusedText = "#ebdbb2"
                StackbarUnfocusedText = "#928374"
                StackbarBackground = "#282828"
            }
        }
        "tokyonight" {
            return @{
                BorderFocused = "#7aa2f7"
                BorderStack = "#bb9af7"
                BorderMonocle = "#9ece6a"
                BorderUnfocused = "#3b4261"
                StackbarFocusedText = "#c0caf5"
                StackbarUnfocusedText = "#565f89"
                StackbarBackground = "#1a1b26"
            }
        }
        "catppuccin" {
            return @{
                BorderFocused = "#89b4fa"
                BorderStack = "#cba6f7"
                BorderMonocle = "#a6e3a1"
                BorderUnfocused = "#45475a"
                StackbarFocusedText = "#cdd6f4"
                StackbarUnfocusedText = "#6c7086"
                StackbarBackground = "#1e1e2e"
            }
        }
    }
}

function New-AHKConfig {
    param([string]$Theme)
    
    Write-Log "Creating AutoHotkey configuration..."
    
    try {
        $ahkPath = "$env:USERPROFILE\.config\komorebi"
        if (!(Test-Path $ahkPath)) {
            New-Item -ItemType Directory -Path $ahkPath -Force | Out-Null
        }
        
        $ahkConfig = @'
#Requires AutoHotkey v2.0
#SingleInstance Force
InstallKeybdHook(1, 1)

; Komorebi AutoHotkey Configuration
; Theme: $Theme
; Smooth navigation with Win key - blocks Start Menu

komorebic(cmd) {
    RunWait("komorebic.exe " . cmd, , "Hide")
}

; Track if Win was used with a combination
global winUsed := false

; Intercept Win key release to block menu
~LWin Up:: {
    global winUsed
    if (!winUsed) {
        ; Win was pressed alone, do nothing (blocks menu)
    }
    winUsed := false
}

; Helper to mark Win as used
MarkWinUsed() {
    global winUsed
    winUsed := true
}

; === NAVIGATION (Win+H/J/K/L) ===
#h:: {
    MarkWinUsed()
    komorebic("focus left")
}
#j:: {
    MarkWinUsed()
    komorebic("focus down")
}
#k:: {
    MarkWinUsed()
    komorebic("focus up")
}
#l:: {
    MarkWinUsed()
    komorebic("focus right")
}

; === NAVIGATION (Win+Arrows) ===
#Left:: {
    MarkWinUsed()
    komorebic("focus left")
}
#Down:: {
    MarkWinUsed()
    komorebic("focus down")
}
#Up:: {
    MarkWinUsed()
    komorebic("focus up")
}
#Right:: {
    MarkWinUsed()
    komorebic("focus right")
}

; === MOVE WINDOWS (Shift+Win+H/J/K/L) ===
+#h:: {
    MarkWinUsed()
    komorebic("move left")
}
+#j:: {
    MarkWinUsed()
    komorebic("move down")
}
+#k:: {
    MarkWinUsed()
    komorebic("move up")
}
+#l:: {
    MarkWinUsed()
    komorebic("move right")
}

; === MOVE WINDOWS (Shift+Win+Arrows) ===
+#Left:: {
    MarkWinUsed()
    komorebic("move left")
}
+#Down:: {
    MarkWinUsed()
    komorebic("move down")
}
+#Up:: {
    MarkWinUsed()
    komorebic("move up")
}
+#Right:: {
    MarkWinUsed()
    komorebic("move right")
}

; === STACK WINDOWS (Ctrl+Win+H/J/K/L) ===
^#h:: {
    MarkWinUsed()
    komorebic("stack left")
}
^#j:: {
    MarkWinUsed()
    komorebic("stack down")
}
^#k:: {
    MarkWinUsed()
    komorebic("stack up")
}
^#l:: {
    MarkWinUsed()
    komorebic("stack right")
}

; === STACK WINDOWS (Ctrl+Win+Arrows) ===
^#Left:: {
    MarkWinUsed()
    komorebic("stack left")
}
^#Down:: {
    MarkWinUsed()
    komorebic("stack down")
}
^#Up:: {
    MarkWinUsed()
    komorebic("stack up")
}
^#Right:: {
    MarkWinUsed()
    komorebic("stack right")
}

; === UNSTACK (Win+U) ===
#u:: {
    MarkWinUsed()
    komorebic("unstack")
}

; === CYCLE STACK (Win+N) ===
#n:: {
    MarkWinUsed()
    komorebic("cycle-stack next")
}
+#n:: {
    MarkWinUsed()
    komorebic("cycle-stack previous")
}

; === WORKSPACES ===
#1:: {
    MarkWinUsed()
    komorebic("focus-workspace 0")
}
#2:: {
    MarkWinUsed()
    komorebic("focus-workspace 1")
}
#3:: {
    MarkWinUsed()
    komorebic("focus-workspace 2")
}
#4:: {
    MarkWinUsed()
    komorebic("focus-workspace 3")
}
#5:: {
    MarkWinUsed()
    komorebic("focus-workspace 4")
}

; === MOVE TO WORKSPACE ===
+#1:: {
    MarkWinUsed()
    komorebic("move-to-workspace 0")
}
+#2:: {
    MarkWinUsed()
    komorebic("move-to-workspace 1")
}
+#3:: {
    MarkWinUsed()
    komorebic("move-to-workspace 2")
}
+#4:: {
    MarkWinUsed()
    komorebic("move-to-workspace 3")
}
+#5:: {
    MarkWinUsed()
    komorebic("move-to-workspace 4")
}

; === ACTIONS ===
#t:: {
    MarkWinUsed()
    komorebic("toggle-float")
}
#f:: {
    MarkWinUsed()
    komorebic("toggle-monocle")
}
#q:: {
    MarkWinUsed()
    Send("!{F4}")
}
#Enter:: {
    MarkWinUsed()
    Run("wt.exe")
}
#Space:: {
    MarkWinUsed()
    Run("flow-launcher.exe")
}

; === RELOAD ===
+#c:: {
    MarkWinUsed()
    Reload()
}

; === ALLOW WINDOWS SHORTCUTS ===
#e:: {
    MarkWinUsed()
    Send("{LWin Down}e{LWin Up}")
}
#r:: {
    MarkWinUsed()
    Send("{LWin Down}r{LWin Up}")
}
#i:: {
    MarkWinUsed()
    Send("{LWin Down}i{LWin Up}")
}
#d:: {
    MarkWinUsed()
    Send("#d")
}
#Tab:: {
    MarkWinUsed()
    Send("#Tab")
}
'@
        
        $ahkConfig | Set-Content -Path "$ahkPath\komorebi.ahk" -Encoding UTF8
        Write-Log "AutoHotkey configuration created" "SUCCESS"
        
        # Create startup script
        $startupScript = @"
#Requires AutoHotkey v2.0
#SingleInstance Force

; Komorebi Startup Script
; This script starts Komorebi and related tools automatically

; Wait for system to be ready
Sleep(3000)

; Check if Komorebi is already running
if ProcessExist("komorebi.exe") {
    ProcessClose("komorebi.exe")
    Sleep(1000)
}

; Start Komorebi with configuration
try {
    Run("komorebic.exe start --await-configuration", , "Hide")
    Sleep(3000)
    
    ; Verify Komorebi started
    if !ProcessExist("komorebi.exe") {
        MsgBox("Failed to start Komorebi. Please check installation.", "Komorebi Startup Error", 16)
        ExitApp()
    }
} catch as err {
    MsgBox("Error starting Komorebi: " . err.Message, "Komorebi Startup Error", 16)
    ExitApp()
}

; Load main AHK configuration (keyboard shortcuts)
configPath := A_AppData . "\..\..\.config\komorebi\komorebi.ahk"
if FileExist(configPath) {
    try {
        Run(configPath)
    } catch as err {
        MsgBox("Error loading AHK config: " . err.Message, "Configuration Error", 48)
    }
} else {
    MsgBox("AHK configuration not found: " . configPath, "Configuration Error", 48)
}

; Start Zebar status bar (if installed)
zebarPath := A_AppData . "\..\Local\Programs\Zebar\Zebar.exe"
if FileExist(zebarPath) {
    Sleep(1000)
    try {
        Run(zebarPath, , "Hide")
    } catch as err {
        ; Zebar is optional, just log the error
    }
}

; Start komorebi-loading (if installed)
loadingPath := A_MyDocuments . "\..\..\.config\komorebi-loading\komorebi-loading.exe"
if FileExist(loadingPath) {
    try {
        Run(loadingPath, , "Hide")
    } catch {
        ; Loading screen is optional
    }
}

; Show success notification
TrayTip("Komorebi Started", "Tiling window manager is active - Press Win+Shift+H for help", 1)

; Keep script running to maintain keyboard shortcuts
return
'@
        
        $startupScript | Set-Content -Path "$ahkPath\komorebi-startup.ahk" -Encoding UTF8
        Write-Log "Startup script created" "SUCCESS"
        
        # Create theme switcher script
        $themeSwitcher = @"
# Komorebi Theme Switcher
# Quick theme switching with Win+Shift+T

`$ErrorActionPreference = "Stop"

# Get current theme from config
`$configPath = "`$env:USERPROFILE\.config\komorebi\komorebi.json"
`$currentConfig = Get-Content `$configPath -Raw | ConvertFrom-Json

# Determine current theme based on border color
`$currentTheme = switch (`$currentConfig.border_colours.single) {
    "#d79921" { "gruvbox" }
    "#7aa2f7" { "tokyonight" }
    "#89b4fa" { "catppuccin" }
    default { "gruvbox" }
}

# Show theme selection
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

`$form = New-Object System.Windows.Forms.Form
`$form.Text = "Komorebi Theme Switcher"
`$form.Size = New-Object System.Drawing.Size(350, 220)
`$form.StartPosition = "CenterScreen"
`$form.FormBorderStyle = "FixedDialog"
`$form.MaximizeBox = `$false
`$form.MinimizeBox = `$false

`$label = New-Object System.Windows.Forms.Label
`$label.Location = New-Object System.Drawing.Point(10, 10)
`$label.Size = New-Object System.Drawing.Size(320, 20)
`$label.Text = "Select Komorebi Theme:"
`$form.Controls.Add(`$label)

`$currentLabel = New-Object System.Windows.Forms.Label
`$currentLabel.Location = New-Object System.Drawing.Point(10, 35)
`$currentLabel.Size = New-Object System.Drawing.Size(320, 20)
`$currentLabel.Text = "Current: `$currentTheme"
`$currentLabel.ForeColor = [System.Drawing.Color]::Gray
`$form.Controls.Add(`$currentLabel)

`$radioGruvbox = New-Object System.Windows.Forms.RadioButton
`$radioGruvbox.Location = New-Object System.Drawing.Point(20, 65)
`$radioGruvbox.Size = New-Object System.Drawing.Size(300, 20)
`$radioGruvbox.Text = "Gruvbox (warm, retro)"
`$radioGruvbox.Checked = (`$currentTheme -eq "gruvbox")
`$form.Controls.Add(`$radioGruvbox)

`$radioTokyo = New-Object System.Windows.Forms.RadioButton
`$radioTokyo.Location = New-Object System.Drawing.Point(20, 90)
`$radioTokyo.Size = New-Object System.Drawing.Size(300, 20)
`$radioTokyo.Text = "Tokyo Night (cool, modern)"
`$radioTokyo.Checked = (`$currentTheme -eq "tokyonight")
`$form.Controls.Add(`$radioTokyo)

`$radioCat = New-Object System.Windows.Forms.RadioButton
`$radioCat.Location = New-Object System.Drawing.Point(20, 115)
`$radioCat.Size = New-Object System.Drawing.Size(300, 20)
`$radioCat.Text = "Catppuccin (pastel, elegant)"
`$radioCat.Checked = (`$currentTheme -eq "catppuccin")
`$form.Controls.Add(`$radioCat)

`$okButton = New-Object System.Windows.Forms.Button
`$okButton.Location = New-Object System.Drawing.Point(90, 150)
`$okButton.Size = New-Object System.Drawing.Size(75, 25)
`$okButton.Text = "Apply"
`$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
`$form.AcceptButton = `$okButton
`$form.Controls.Add(`$okButton)

`$cancelButton = New-Object System.Windows.Forms.Button
`$cancelButton.Location = New-Object System.Drawing.Point(175, 150)
`$cancelButton.Size = New-Object System.Drawing.Size(75, 25)
`$cancelButton.Text = "Cancel"
`$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
`$form.CancelButton = `$cancelButton
`$form.Controls.Add(`$cancelButton)

`$result = `$form.ShowDialog()

if (`$result -eq [System.Windows.Forms.DialogResult]::OK) {
    `$selectedTheme = if (`$radioGruvbox.Checked) { "gruvbox" }
                     elseif (`$radioTokyo.Checked) { "tokyonight" }
                     elseif (`$radioCat.Checked) { "catppuccin" }
                     else { "gruvbox" }
    
    if (`$selectedTheme -ne `$currentTheme) {
        # Run installation script with new theme
        `$scriptPath = "`$PSScriptRoot\..\..\scripts\install-komorebi.ps1"
        Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"`$scriptPath`" -Theme `$selectedTheme -Force" -Verb RunAs -Wait
        
        # Restart Komorebi
        Start-Process komorebic.exe -ArgumentList "stop" -NoNewWindow -Wait
        Start-Sleep -Seconds 1
        Start-Process autohotkey.exe -ArgumentList "`"`$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk`""
        
        [System.Windows.Forms.MessageBox]::Show("Theme changed to `$selectedTheme!`n`nKomorebi has been restarted.", "Theme Switcher", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}

`$form.Dispose()
"@
        
        $themeSwitcher | Set-Content -Path "$ahkPath\switch-theme.ps1" -Encoding UTF8
        Write-Log "Theme switcher script created" "SUCCESS"
        
        # Create help overlay script
        $helpOverlay = @'
# Komorebi Help Overlay
# Display keyboard shortcuts in a fancy overlay window

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create semi-transparent overlay form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Komorebi Keyboard Shortcuts"
$form.Size = New-Object System.Drawing.Size(900, 700)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 30, 30, 30)
$form.Opacity = 0.95
$form.TopMost = $true
$form.ShowInTaskbar = $false

# Add close instruction
$closeLabel = New-Object System.Windows.Forms.Label
$closeLabel.Location = New-Object System.Drawing.Point(10, 10)
$closeLabel.Size = New-Object System.Drawing.Size(880, 25)
$closeLabel.Text = "Press ESC or click anywhere to close"
$closeLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Italic)
$closeLabel.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 150)
$closeLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($closeLabel)

# Title
$title = New-Object System.Windows.Forms.Label
$title.Location = New-Object System.Drawing.Point(10, 40)
$title.Size = New-Object System.Drawing.Size(880, 40)
$title.Text = "🪟 KOMOREBI KEYBOARD SHORTCUTS"
$title.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
$title.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 100)
$title.TextAlign = "MiddleCenter"
$form.Controls.Add($title)

# Create scrollable panel
$panel = New-Object System.Windows.Forms.Panel
$panel.Location = New-Object System.Drawing.Point(20, 90)
$panel.Size = New-Object System.Drawing.Size(860, 580)
$panel.AutoScroll = $true
$panel.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($panel)

# Shortcuts content
$shortcuts = @"
┌─────────────────────────────────────────────────────────────────┐
│  NAVIGATION                                                     │
├─────────────────────────────────────────────────────────────────┤
│  Win+H/J/K/L or Win+Ctrl+Arrows    Focus window                │
│  Win+Shift+H/J/K/L or Win+Shift+Ctrl+Arrows  Move window       │
│  Win+Arrow Keys                     Stack windows              │
│  Win+U                              Unstack window             │
│  Win+N / Win+Shift+N                Cycle stacked windows      │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  WORKSPACES                                                     │
├─────────────────────────────────────────────────────────────────┤
│  Win+1/2/3/4/5                      Switch to workspace        │
│  Win+Shift+1/2/3/4/5                Move window to workspace   │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  WINDOW MANAGEMENT                                              │
├─────────────────────────────────────────────────────────────────┤
│  Win+T                              Toggle floating            │
│  Win+F                              Toggle fullscreen          │
│  Win+Q                              Close window               │
│  Win+= / Win+-                      Resize horizontal          │
│  Win+Shift+= / Win+Shift+-          Resize vertical            │
│  Win+X / Win+Y                      Flip layout                │
│  Win+Shift+Space                    Cycle layout               │
│  Win+Shift+R                        Retile all windows         │
│  Win+P                              Pause/unpause Komorebi     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  APPLICATIONS                                                   │
├─────────────────────────────────────────────────────────────────┤
│  Win+Enter                          Windows Terminal           │
│  Win+Space                          Flow Launcher              │
│  Win+E                              File Explorer              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  SYSTEM                                                         │
├─────────────────────────────────────────────────────────────────┤
│  Win+Shift+C                        Reload configuration       │
│  Win+Shift+T                        Theme switcher             │
│  Win+Shift+H or Win+?               This help                  │
│  Win+D                              Show desktop               │
│  Win+Tab                            Task view                  │
└─────────────────────────────────────────────────────────────────┘

💡 TIP: Use HJKL for speed, Arrow keys for intuition
💡 TIP: Press Win+Shift+T to change themes
💡 TIP: Stack windows with Win+Arrows, cycle with Win+N
"@

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.ReadOnly = $true
$textBox.ScrollBars = "Vertical"
$textBox.Location = New-Object System.Drawing.Point(10, 10)
$textBox.Size = New-Object System.Drawing.Size(820, 550)
$textBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$textBox.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$textBox.ForeColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
$textBox.BorderStyle = "None"
$textBox.Text = $shortcuts
$panel.Controls.Add($textBox)

# Close on ESC
$form.Add_KeyDown({
    param($sender, $e)
    if ($e.KeyCode -eq "Escape") {
        $form.Close()
    }
})

# Close on click
$form.Add_Click({ $form.Close() })
$panel.Add_Click({ $form.Close() })
$textBox.Add_Click({ $form.Close() })

# Show form
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
$form.Dispose()
'@
        
        $helpOverlay | Set-Content -Path "$ahkPath\show-help.ps1" -Encoding UTF8
        Write-Log "Help overlay script created" "SUCCESS"
        
    }
    catch {
        Write-Log "Error creating AHK configuration: $($_.Exception.Message)" "ERROR"
        throw
    }
}

function New-ZebarConfig {
    param([string]$Theme)
    
    Write-Log "Creating Zebar configuration with $Theme theme..."
    
    try {
        $zebarPath = "$env:USERPROFILE\.config\zebar"
        if (!(Test-Path $zebarPath)) {
            New-Item -ItemType Directory -Path $zebarPath -Force | Out-Null
        }
        
        $colors = Get-ThemeColors -Theme $Theme
        
        $zebarConfig = @"
{
  "bars": [
    {
      "name": "main-bar",
      "position": "top",
      "height": 32,
      "background": "$($colors.StackbarBackground)",
      "foreground": "$($colors.StackbarFocusedText)",
      "font_family": "CaskaydiaCove Nerd Font",
      "font_size": 11,
      "widgets": [
        {
          "type": "text",
          "content": " 🪟 ",
          "foreground": "$($colors.BorderFocused)",
          "font_size": 14
        },
        {
          "type": "workspaces",
          "workspace_labels": {
            "HOME": "1: ",
            "TOOLS": "2: ",
            "MEDIA": "3: ",
            "CODE": "4: ",
            "TERM": "5: ",
            "DOCS": "6: ",
            "WEB": "7: ",
            "FILES": "8: ",
            "NOTES": "9: "
          },
          "focused_background": "$($colors.BorderFocused)",
          "focused_foreground": "$($colors.StackbarBackground)",
          "unfocused_background": "$($colors.StackbarBackground)",
          "unfocused_foreground": "$($colors.StackbarUnfocusedText)",
          "padding": "4px 8px",
          "margin": "0 2px"
        },
        {
          "type": "separator",
          "content": " | ",
          "foreground": "$($colors.BorderUnfocused)"
        },
        {
          "type": "window_list",
          "max_windows": 5,
          "show_icons": true,
          "focused_foreground": "$($colors.BorderFocused)",
          "unfocused_foreground": "$($colors.StackbarUnfocusedText)"
        },
        {
          "type": "spacer"
        },
        {
          "type": "system_info",
          "show_cpu": true,
          "show_memory": true,
          "show_network": false,
          "foreground": "$($colors.StackbarUnfocusedText)"
        },
        {
          "type": "separator",
          "content": " | ",
          "foreground": "$($colors.BorderUnfocused)"
        },
        {
          "type": "clock",
          "format": " %H:%M  %d/%m/%Y",
          "foreground": "$($colors.StackbarFocusedText)"
        }
      ]
    }
  ]
}
"@
        
        $zebarConfig | Set-Content -Path "$zebarPath\config.json" -Encoding UTF8
        Write-Log "Zebar configuration created with $Theme theme" "SUCCESS"
        
    }
    catch {
        Write-Log "Error creating Zebar configuration: $($_.Exception.Message)" "WARN"
    }
}

function Add-StartupEntry {
    Write-Log "Adding Komorebi to startup..."
    
    try {
        # Find AutoHotkey executable
        $ahkExe = $null
        try {
            $ahkCmd = Get-Command autohotkey -ErrorAction Stop
            $ahkExe = $ahkCmd.Source
        }
        catch {
            # Search in common locations
            $searchPaths = @(
                "$env:LOCALAPPDATA\Programs\AutoHotkey\v2\AutoHotkey.exe",
                "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe",
                "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey.exe"
            )
            
            foreach ($path in $searchPaths) {
                if (Test-Path $path) {
                    $ahkExe = $path
                    break
                }
            }
        }
        
        if (-not $ahkExe) {
            Write-Log "AutoHotkey executable not found. Startup shortcut may not work." "WARN"
            $ahkExe = "autohotkey.exe"  # Fallback to PATH
        }
        
        $startupFolder = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        $startupScript = "$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
        $shortcutPath = Join-Path $startupFolder "Komorebi.lnk"
        
        # Remove old shortcut if exists
        if (Test-Path $shortcutPath) {
            Remove-Item $shortcutPath -Force
        }
        
        # Create shortcut
        $WshShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut($shortcutPath)
        $Shortcut.TargetPath = $ahkExe
        $Shortcut.Arguments = "`"$startupScript`""
        $Shortcut.WorkingDirectory = "$env:USERPROFILE\.config\komorebi"
        $Shortcut.Description = "Komorebi Tiling Window Manager"
        $Shortcut.Save()
        
        Write-Log "Startup entry created at: $shortcutPath" "SUCCESS"
        Write-Log "AutoHotkey path: $ahkExe" "INFO"
    }
    catch {
        Write-Log "Error adding startup entry: $($_.Exception.Message)" "WARN"
        Write-Log "You can manually create the shortcut or run: .\scripts\fix-komorebi-startup.ps1" "INFO"
    }
}

function Show-PostInstallInfo {
    param([string]$Theme)
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  Komorebi Installation Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Theme: $Theme" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Configuration files created:" -ForegroundColor Yellow
    Write-Host "  - Komorebi config: $env:USERPROFILE\.config\komorebi\komorebi.json"
    Write-Host "  - AHK config: $env:USERPROFILE\.config\komorebi\komorebi.ahk"
    Write-Host "  - Startup script: $env:USERPROFILE\.config\komorebi\komorebi-startup.ahk"
    Write-Host "  - Zebar config: $env:USERPROFILE\.config\zebar\config.json"
    Write-Host ""
    Write-Host "Key Bindings (Win + key):" -ForegroundColor Yellow
    Write-Host "  Win+H/J/K/L or Win+Arrows - Focus window"
    Write-Host "  Win+Shift+H/J/K/L or Win+Shift+Arrows - Move window"
    Write-Host "  Win+Ctrl+Arrows     - Cycle stacked windows"
    Write-Host "  Win+U               - Unstack window"
    Write-Host "  Win+T               - Toggle float"
    Write-Host "  Win+F               - Toggle monocle (fullscreen)"
    Write-Host "  Win+1/2/3/4/5       - Switch workspace"
    Write-Host "  Win+Shift+1/2/3/4/5 - Move window to workspace"
    Write-Host "  Win+Enter           - Open Windows Terminal"
    Write-Host "  Win+Space           - Open Flow Launcher"
    Write-Host "  Win+Q               - Close window"
    Write-Host "  Win+Shift+T         - Theme switcher (GUI)" -ForegroundColor Green
    Write-Host "  Win+Shift+H or Win+? - Help overlay" -ForegroundColor Green
    Write-Host ""
    Write-Host "Note: Windows key menu is disabled" -ForegroundColor Cyan
    Write-Host "      Some Windows shortcuts still work (Win+E, Win+D, Win+Tab)"
    Write-Host "      Arrow keys can be used instead of H/J/K/L"
    Write-Host ""
    Write-Host "Startup Configuration:" -ForegroundColor Green
    Write-Host "  ✓ Komorebi will start automatically on login"
    Write-Host "  ✓ Shortcut added to: $env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Komorebi.lnk"
    Write-Host "  ✓ AutoHotkey will load keyboard shortcuts"
    Write-Host "  ✓ Zebar status bar will start automatically"
    Write-Host ""
    Write-Host "To start Komorebi now (without reboot):" -ForegroundColor Yellow
    Write-Host "  autohotkey.exe `"$env:USERPROFILE\.config\komorebi\komorebi-startup.ahk`""
    Write-Host ""
    Write-Host "Additional tools installed:" -ForegroundColor Yellow
    Write-Host "  - Zebar (status bar)"
    Write-Host "  - komorebi-loading (loading screen)"
    Write-Host "  - komoflow (Flow Launcher plugin - install from Flow Launcher)"
    Write-Host ""
    Write-Host "Change theme later by running:" -ForegroundColor Yellow
    Write-Host "  .\scripts\install-komorebi.ps1 -Theme <gruvbox|tokyonight|catppuccin>"
    Write-Host ""
}

function Main {
    Write-Log "=== Komorebi Tiling Window Manager Installation ==="
    
    try {
        # Check if already installed
        if ((Test-KomorebiInstalled) -and (-not $Force)) {
            Write-Log "Komorebi is already installed" "INFO"
            Write-Log "Use -Force to reinstall" "INFO"
        }
        else {
            Install-Komorebi
        }
        
        # Install dependencies
        Install-AutoHotkey
        
        # Install additional tools
        Install-Zebar
        Install-KomorebiLoading
        Install-FlowLauncherPlugin
        
        # Create configurations
        New-KomorebiConfig -Theme $Theme
        New-AHKConfig -Theme $Theme
        New-ZebarConfig -Theme $Theme
        
        # Add to startup
        Add-StartupEntry
        
        # Show post-install information
        Show-PostInstallInfo -Theme $Theme
        
        Write-Log "Komorebi installation completed successfully" "SUCCESS"
        
    }
    catch {
        Write-Log "Error installing Komorebi: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Execution
Main
