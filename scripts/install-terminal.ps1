#Requires -Version 5.1
# Installation and configuration of Windows Terminal (modern, customizable terminal).

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot '..\WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot '..\logs\terminal.log')

function Test-WindowsTerminalInstalled {
    try {
        $TerminalApp = Get-AppxPackage -Name "Microsoft.WindowsTerminal" -ErrorAction SilentlyContinue
        return $null -ne $TerminalApp
    }
    catch {
        return $false
    }
}

function Install-WindowsTerminalViaWinget {
    Write-Log "Installing Windows Terminal via winget..."
    # Throw on a real winget failure so the Store/GitHub fallback can take over.
    # (Already-installed exit codes are treated as success by Install-WingetPackage.)
    if (-not (Install-WingetPackage -Id 'Microsoft.WindowsTerminal' -Name 'Windows Terminal')) {
        throw "winget could not install Windows Terminal"
    }
}

function Install-WindowsTerminalViaStore {
    Write-Log "Installing Windows Terminal via Microsoft Store..."

    $StoreApp = Get-AppxPackage -Name "Microsoft.WindowsStore" -ErrorAction SilentlyContinue
    if (-not $StoreApp) {
        throw "Microsoft Store not available"
    }
    Start-Process "ms-windows-store://pdp/?ProductId=9N0DX20HK701" -Wait
    Write-Log "Windows Terminal install triggered via Microsoft Store" "SUCCESS"
}

function Install-WindowsTerminalViaGitHub {
    Write-Log "Installing Windows Terminal via GitHub..."

    $TerminalUrl = "https://github.com/microsoft/terminal/releases/latest/download/Microsoft.WindowsTerminal_8wekyb3d8bbwe.msixbundle"
    $DownloadPath = "$env:TEMP\WindowsTerminal.msixbundle"

    Write-Log "Downloading Windows Terminal..."
    Invoke-WebRequest -Uri $TerminalUrl -OutFile $DownloadPath -UseBasicParsing

    Write-Log "Installing Windows Terminal..."
    Add-AppxPackage -Path $DownloadPath   # Add-AppxPackage throws on failure
    Remove-Item $DownloadPath -Force

    Write-Log "Windows Terminal installed via GitHub" "SUCCESS"
}

function Set-WindowsTerminalConfiguration {
    Write-Log "Configuring Windows Terminal..."

    try {
        $ConfigPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
        $ConfigDir = Split-Path $ConfigPath -Parent

        if (!(Test-Path $ConfigDir)) {
            New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
        }

        $TerminalConfig = @{
            "`$schema"        = "https://aka.ms/terminal-profiles-schema"
            "defaultProfile" = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
            "profiles"       = @{
                "defaults" = @{
                    "fontFace"       = "CaskaydiaCove Nerd Font"
                    "fontSize"       = 12
                    "colorScheme"    = "Gruvbox Dark"
                    "cursorShape"    = "bar"
                    "cursorHeight"   = 1
                    "snapOnInput"    = $true
                    "historySize"    = 9001
                    "scrollbarState" = "hidden"
                }
                "list"     = @(
                    @{
                        "guid"             = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
                        "name"             = "Windows PowerShell"
                        "commandline"      = "powershell.exe"
                        "hidden"           = $false
                        "startingDirectory" = "~"
                    },
                    @{
                        "guid"             = "{0caa0dad-35be-5f56-a8ff-afceeeaa6101}"
                        "name"             = "Command Prompt"
                        "commandline"      = "cmd.exe"
                        "hidden"           = $false
                        "startingDirectory" = "~"
                    },
                    @{
                        "guid"             = "{2c4de342-38b7-51cf-b940-2309a097f518}"
                        "name"             = "Ubuntu"
                        "commandline"      = "wsl.exe -d Ubuntu"
                        "hidden"           = $false
                        "startingDirectory" = "~"
                        "icon"             = "ms-appx:///ProfileIcons/{9acb9455-ca41-5af7-950f-6bca1bc9722f}.png"
                    }
                )
            }
            "schemes"        = @(
                @{
                    "name"                = "Gruvbox Dark"
                    "foreground"          = "#ebdbb2"
                    "background"          = "#282828"
                    "cursorColor"         = "#ebdbb2"
                    "selectionBackground" = "#504945"
                    "black"               = "#282828"
                    "red"                 = "#cc241d"
                    "green"               = "#98971a"
                    "yellow"              = "#d79921"
                    "blue"                = "#458588"
                    "purple"              = "#b16286"
                    "cyan"                = "#689d6a"
                    "white"               = "#a89984"
                    "brightBlack"         = "#928374"
                    "brightRed"           = "#fb4934"
                    "brightGreen"         = "#b8bb26"
                    "brightYellow"        = "#fabd2f"
                    "brightBlue"          = "#83a598"
                    "brightPurple"        = "#d3869b"
                    "brightCyan"          = "#8ec07c"
                    "brightWhite"         = "#ebdbb2"
                }
            )
            "keybindings"    = @(
                @{ "command" = "closeTab"; "keys" = @("ctrl+shift+w") },
                @{ "command" = "newTab"; "keys" = @("ctrl+shift+t") },
                @{ "command" = "newWindow"; "keys" = @("ctrl+shift+n") },
                @{ "command" = "nextTab"; "keys" = @("ctrl+tab") },
                @{ "command" = "prevTab"; "keys" = @("ctrl+shift+tab") },
                @{ "command" = "splitHorizontal"; "keys" = @("alt+shift+-") },
                @{ "command" = "splitVertical"; "keys" = @("alt+shift+plus") }
            )
        }

        $TerminalConfig | ConvertTo-Json -Depth 10 | Set-Content -Path $ConfigPath -Encoding UTF8
        Write-Log "Windows Terminal configuration saved in $ConfigPath" "SUCCESS"
        # NB: the repo's config/terminal-settings.json is the source reference and is
        # deliberately NOT overwritten here (a script must not dirty versioned files).
    }
    catch {
        Write-Log "Error configuring Windows Terminal: $($_.Exception.Message)" "ERROR"
    }
}

function Set-WindowsTerminalAsDefault {
    Write-Log "Setting Windows Terminal as default terminal..."

    try {
        $RegPath = "HKCU:\Console"
        if (!(Test-Path $RegPath)) {
            New-Item -Path $RegPath -Force | Out-Null
        }
        Set-ItemProperty -Path $RegPath -Name "DelegationConsole" -Value "{2EACA947-7F5F-4CFA-B222-0004BFF319B1}"
        Set-ItemProperty -Path $RegPath -Name "DelegationTerminal" -Value "{2EACA947-7F5F-4CFA-B222-0004BFF319B1}"
        Write-Log "Windows Terminal set as default terminal" "SUCCESS"
    }
    catch {
        Write-Log "Error setting default terminal: $($_.Exception.Message)" "ERROR"
    }
}

function Set-WindowsShellTheme {
    Write-Log "Setting up the PowerShell shell theme (Starship + zoxide)..."
    try {
        # Deploy the shared Starship config (used by both PowerShell and WSL).
        $cfgDir = Join-Path $env:USERPROFILE '.config'
        if (!(Test-Path $cfgDir)) { New-Item -ItemType Directory -Path $cfgDir -Force | Out-Null }
        $src = Join-Path $PSScriptRoot '..\config\starship.toml'
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination (Join-Path $cfgDir 'starship.toml') -Force
        }

        # Wire Starship + zoxide into both PowerShell profiles (idempotent, runtime-guarded).
        $marker = '# >>> windows-env-setup >>>'
        $block = @'

# >>> windows-env-setup >>>
if (Get-Command starship -ErrorAction SilentlyContinue) { Invoke-Expression (&starship init powershell) }
if (Get-Command zoxide   -ErrorAction SilentlyContinue) { Invoke-Expression (& { (zoxide init powershell | Out-String) }) }
Set-Alias -Name ls  -Value eza -ErrorAction SilentlyContinue
Set-Alias -Name cat -Value bat -ErrorAction SilentlyContinue
# <<< windows-env-setup <<<
'@
        $profiles = @(
            (Join-Path $env:USERPROFILE 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1'),
            (Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1')
        )
        foreach ($profilePath in $profiles) {
            $dir = Split-Path $profilePath -Parent
            if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
            if (-not (Test-Path $profilePath) -or -not (Select-String -Path $profilePath -SimpleMatch $marker -Quiet)) {
                Add-Content -Path $profilePath -Value $block
            }
        }
        Write-Log "PowerShell profiles configured (Starship + zoxide)" "SUCCESS"
    }
    catch {
        Write-Log "Error setting up shell theme: $($_.Exception.Message)" "ERROR"
    }
}

function Main {
    Write-Log "=== Windows Terminal Installation ==="

    if ((Test-WindowsTerminalInstalled) -and (-not $Force)) {
        Write-Log "Windows Terminal is already installed" "INFO"
        Set-WindowsTerminalConfiguration
        Set-WindowsTerminalAsDefault
        Set-WindowsShellTheme
        return
    }

    try {
        # Try winget first; fall back to Store, then GitHub.
        try {
            Install-WindowsTerminalViaWinget
        }
        catch {
            Write-Log "Failed to install via winget, trying Store..." "WARN"
            try {
                Install-WindowsTerminalViaStore
            }
            catch {
                Write-Log "Failed to install via Store, trying GitHub..." "WARN"
                Install-WindowsTerminalViaGitHub
            }
        }

        if (-not (Test-WindowsTerminalInstalled)) {
            throw "Windows Terminal could not be installed"
        }

        Set-WindowsTerminalConfiguration
        Set-WindowsTerminalAsDefault
        Set-WindowsShellTheme

        Write-Log "Windows Terminal installed and configured successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Windows Terminal: $($_.Exception.Message)" "ERROR"
        throw
    }
}

Main
