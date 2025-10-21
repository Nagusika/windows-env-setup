# Main Windows environment installation script
# Run as administrator

param(
    [switch]$Verbose
)

# Configuration
$ErrorActionPreference = "Stop"
$LogDir = "logs"
$ConfigDir = "config"

# Create necessary directories
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force }
if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir -Force }

# Logging function
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
    Add-Content -Path "$LogDir\install.log" -Value $LogMessage
}

# Function to prompt user for confirmation
function Confirm-Action {
    param(
        [string]$Message,
        [bool]$DefaultYes = $false
    )
    
    $Prompt = if ($DefaultYes) { "$Message (Y/n)" } else { "$Message (y/N)" }
    $Response = Read-Host $Prompt
    
    if ([string]::IsNullOrWhiteSpace($Response)) {
        return $DefaultYes
    }
    
    return $Response -match '^[Yy]'
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Log "Checking prerequisites..."
    
    # Check Windows version
    $OSVersion = [System.Environment]::OSVersion.Version
    if ($OSVersion.Major -lt 10) {
        throw "Windows 10 or higher required"
    }
    
    # Check PowerShell
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        throw "PowerShell 5.1 or higher required"
    }
    
    # Check administrator rights
    $CurrentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($CurrentUser)
    if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Administrator rights required"
    }
    
    Write-Log "Prerequisites validated" "SUCCESS"
}

# Function to install winget
function Install-Winget {
    Write-Log "Checking winget installation..."
    
    try {
        $null = Get-Command winget -ErrorAction Stop
        Write-Log "winget is already installed" "INFO"
        return
    }
    catch {
        Write-Log "winget not found, installing..." "WARN"
    }
    
    try {
        & ".\scripts\install-winget.ps1"
        Write-Log "winget installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing winget: $($_.Exception.Message)" "ERROR"
        throw
    }
}

# Function to install WSL
function Install-WSL {
    if (-not (Confirm-Action "Install WSL2 with Ubuntu?" $true)) {
        Write-Log "WSL installation skipped by user" "SKIP"
        return
    }
    
    Write-Log "Installing WSL Ubuntu..."
    try {
        & ".\scripts\install-wsl.ps1"
        Write-Log "WSL Ubuntu installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing WSL: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-wsl.ps1" "INFO"
    }
}

# Function to install Windows Terminal
function Install-Terminal {
    if (-not (Confirm-Action "Install Windows Terminal?" $true)) {
        Write-Log "Windows Terminal installation skipped by user" "SKIP"
        return
    }
    
    Write-Log "Installing Windows Terminal..."
    try {
        & ".\scripts\install-terminal.ps1"
        Write-Log "Windows Terminal installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Windows Terminal: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-terminal.ps1" "INFO"
    }
}

# Function to install NerdFonts
function Install-NerdFonts {
    if (-not (Confirm-Action "Install NerdFonts (CascadiaCode, FiraCode)?" $true)) {
        Write-Log "NerdFonts installation skipped by user" "SKIP"
        return
    }
    
    Write-Log "Installing NerdFonts..."
    try {
        & ".\scripts\install-nerdfonts.ps1"
        Write-Log "NerdFonts installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing NerdFonts: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-nerdfonts.ps1" "INFO"
    }
}

# Function to install Git
function Install-Git {
    if (-not (Confirm-Action "Install Git?" $true)) {
        Write-Log "Git installation skipped by user" "SKIP"
        return
    }

    Write-Log "Installing Git..."
    try {
        & ".\scripts\install-git.ps1"
        Write-Log "Git installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Git: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-git.ps1" "INFO"
    }
}

# Function to install GitHub CLI
function Install-GitHubCli {
    if (-not (Confirm-Action "Install GitHub CLI?" $true)) {
        Write-Log "GitHub CLI installation skipped by user" "SKIP"
        return
    }

    Write-Log "Installing GitHub CLI..."
    try {
        & ".\scripts\install-github-cli.ps1"
        Write-Log "GitHub CLI installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing GitHub CLI: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-github-cli.ps1" "INFO"
    }
}

# Function to install GlazeWM
function Install-GlazeWM {
    if (-not (Confirm-Action "Install GlazeWM (Tiling Window Manager)?" $true)) {
        Write-Log "GlazeWM installation skipped by user" "SKIP"
        return
    }

    Write-Log "Installing GlazeWM..."
    try {
        & ".\scripts\install-glazewm.ps1"
        Write-Log "GlazeWM installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing GlazeWM: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-glazewm.ps1" "INFO"
    }
}

# Function to install Zebar
function Install-Zebar {
    if (-not (Confirm-Action "Install Zebar (Status Bar for GlazeWM)?" $true)) {
        Write-Log "Zebar installation skipped by user" "SKIP"
        return
    }

    Write-Log "Installing Zebar..."
    try {
        & ".\scripts\install-zebar.ps1"
        Write-Log "Zebar installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Zebar: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-zebar.ps1" "INFO"
    }
}

# Function to install Docker
function Install-Docker {
    if (-not (Confirm-Action "Install Docker Desktop?" $false)) {
        Write-Log "Docker installation skipped by user" "SKIP"
        return
    }
    
    Write-Log "Installing Docker Desktop..."
    try {
        & ".\scripts\install-docker.ps1"
        Write-Log "Docker Desktop installed successfully" "SUCCESS"
    }
    catch {
        Write-Log "Error installing Docker: $($_.Exception.Message)" "ERROR"
        Write-Log "You can retry later by running: .\scripts\install-docker.ps1" "INFO"
    }
}

# Function to install useful packages via winget
function Install-WingetPackages {
    if (-not (Confirm-Action "Install additional useful packages (CLI tools, browsers, utilities)?" $true)) {
        Write-Log "Additional packages installation skipped by user" "SKIP"
        return
    }
    
    Write-Log "Installing additional packages via winget..."
    
    # Define package categories
    $Packages = @{
        "Base Shell & UX" = @(
            @{Id="Microsoft.PowerShell"; Name="PowerShell 7"},
            @{Id="Microsoft.WindowsTerminal"; Name="Windows Terminal"},
            @{Id="Microsoft.PowerToys"; Name="PowerToys"},
            @{Id="Flow-Launcher.Flow-Launcher"; Name="Flow Launcher"},
            @{Id="Notepad++.Notepad++"; Name="Notepad++"},
            @{Id="VSCodium.VSCodium"; Name="VSCodium"}
        )
        "Browsers (FOSS)" = @(
            @{Id="Mozilla.Firefox"; Name="Firefox"},
            @{Id="LibreWolf.LibreWolf"; Name="LibreWolf"}
        )
        "CLI Toolbox (FOSS)" = @(
            @{Id="BurntSushi.ripgrep.MSVC"; Name="ripgrep"},
            @{Id="sharkdp.fd"; Name="fd"},
            @{Id="junegunn.fzf"; Name="fzf"},
            @{Id="sharkdp.bat"; Name="bat"},
            @{Id="jqlang.jq"; Name="jq"},
            @{Id="eza-community.eza"; Name="eza"},
            @{Id="ajeetdsouza.zoxide"; Name="zoxide"},
            @{Id="Schniz.fnm"; Name="fnm (Node version manager)"},
            @{Id="Starship.Starship"; Name="Starship prompt"}
        )
        "Network / Debug / Monitoring" = @(
            @{Id="WiresharkFoundation.Wireshark"; Name="Wireshark"},
            @{Id="Insecure.Nmap"; Name="Nmap"},
            @{Id="ESnet.iperf3"; Name="iperf3"},
            @{Id="ProcessHacker.ProcessHacker"; Name="Process Hacker"},
            @{Id="LibreHardwareMonitor.LibreHardwareMonitor"; Name="Libre Hardware Monitor"},
            @{Id="Rem0o.FanControl"; Name="Fan Control"},
            @{Id="CrystalDewWorld.CrystalDiskInfo"; Name="CrystalDiskInfo"},
            @{Id="CrystalDewWorld.CrystalDiskMark"; Name="CrystalDiskMark"}
        )
        "Storage / FS / Sync" = @(
            @{Id="7zip.7zip"; Name="7-Zip"},
            @{Id="Rclone.Rclone"; Name="Rclone"},
            @{Id="Syncthing.Syncthing"; Name="Syncthing"},
            @{Id="WinFsp.WinFsp"; Name="WinFsp"},
            @{Id="SSHFS-Win.SSHFS-Win"; Name="SSHFS-Win"}
        )
        "Backups (FOSS)" = @(
            @{Id="restic.restic"; Name="restic"},
            @{Id="kopia.kopia"; Name="Kopia"},
            @{Id="Duplicati.Duplicati"; Name="Duplicati"}
        )
        "PDF / Images / Notes" = @(
            @{Id="SumatraPDF.SumatraPDF"; Name="Sumatra PDF"},
            @{Id="PDFsam.PDFsam"; Name="PDFsam"},
            @{Id="ImageGlass.ImageGlass"; Name="ImageGlass"},
            @{Id="GIMP.GIMP"; Name="GIMP"},
            @{Id="Inkscape.Inkscape"; Name="Inkscape"},
            @{Id="Joplin.Joplin"; Name="Joplin"},
            @{Id="Obsidian.Obsidian"; Name="Obsidian"}
        )
        "Media (FOSS)" = @(
            @{Id="VideoLAN.VLC"; Name="VLC"},
            @{Id="mpv.net"; Name="mpv.net"},
            @{Id="Audacity.Audacity"; Name="Audacity"},
            @{Id="OBSProject.OBSStudio"; Name="OBS Studio"}
        )
        "Remote / P2P" = @(
            @{Id="RustDesk.RustDesk"; Name="RustDesk"},
            @{Id="qBittorrent.qBittorrent"; Name="qBittorrent"}
        )
        "Security / Privacy / Passwords" = @(
            @{Id="KeePassXCTeam.KeePassXC"; Name="KeePassXC"},
            @{Id="Bitwarden.Bitwarden"; Name="Bitwarden"},
            @{Id="VeraCrypt.VeraCrypt"; Name="VeraCrypt"}
        )
        "Boot Tools (FOSS)" = @(
            @{Id="Rufus.Rufus"; Name="Rufus"},
            @{Id="Ventoy.Ventoy"; Name="Ventoy"}
        )
        "Development Tools" = @(
            @{Id="Python.Python.3.12"; Name="Python 3.12"},
            @{Id="GoLang.Go"; Name="Go"},
            @{Id="Rustlang.Rust.MSVC"; Name="Rust"},
            @{Id="OpenJS.NodeJS"; Name="Node.js"},
            @{Id="JetBrains.Toolbox"; Name="JetBrains Toolbox"},
            @{Id="Postman.Postman"; Name="Postman"},
            @{Id="Insomnia.Insomnia"; Name="Insomnia"}
        )
        "Package Managers" = @(
            @{Id="ScoopInstaller.Scoop"; Name="Scoop"}
        )
    }
    
    # Ask for each category
    foreach ($Category in $Packages.Keys) {
        Write-Host ""
        if (Confirm-Action "Install $Category packages?" $true) {
            foreach ($Package in $Packages[$Category]) {
                try {
                    Write-Log "Installing $($Package.Name)..."
                    winget install -e --id $($Package.Id) --silent --accept-package-agreements --accept-source-agreements
                    Write-Log "$($Package.Name) installed" "SUCCESS"
                }
                catch {
                    Write-Log "Failed to install $($Package.Name): $($_.Exception.Message)" "WARN"
                }
            }
        }
        else {
            Write-Log "$Category packages skipped" "SKIP"
        }
    }
    
    Write-Log "Additional packages installation completed" "SUCCESS"
}

# Main function
function Main {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  Windows Environment Setup Script" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "=== Starting Windows environment installation ==="
    
    try {
        # Check prerequisites
        Test-Prerequisites
        
        # Core installations
        Install-Winget
        Install-Git
        Install-GitHubCli
        Install-Terminal
        Install-NerdFonts
        
        # Window Manager installations
        Install-GlazeWM
        Install-Zebar
        
        # Optional installations
        Install-WSL
        Install-Docker
        
        # Additional packages
        Install-WingetPackages
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Log "=== Installation completed successfully ===" "SUCCESS"
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Log "Some changes may require a system restart to take effect" "INFO"
        Write-Host ""
        
        if (Confirm-Action "Do you want to restart now?" $false) {
            Write-Log "Restarting system..." "INFO"
            Restart-Computer -Force
        }
        else {
            Write-Log "Please restart your system manually when convenient" "INFO"
        }
    }
    catch {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Log "=== Installation encountered errors ===" "ERROR"
        Write-Host "========================================" -ForegroundColor Red
        Write-Log "Error: $($_.Exception.Message)" "ERROR"
        Write-Host ""
        Write-Log "Check the log file at: $LogDir\install.log" "INFO"
        exit 1
    }
}

# Execution
Main
