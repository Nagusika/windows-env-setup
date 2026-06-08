#Requires -Version 5.1
#Requires -RunAsAdministrator
# Installation and configuration of Docker Desktop.
# Tier 2 (virtualization): requires Hyper-V / WSL2 and admin rights, and Docker Desktop
# may require a paid license in larger organizations. See SECURITY.md / docs.

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot '..\WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot '..\logs\docker.log')

function Test-DockerDesktopInstalled {
    try {
        $app = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*Docker Desktop*" }
        return $null -ne $app
    }
    catch { return $false }
}

function Test-WSL2Available {
    if (-not (Test-CommandExists 'wsl')) { return $false }
    $status = wsl --status 2>$null
    return $status -match "2"
}

function Install-DockerDesktopViaDownload {
    Write-Log "Installing Docker Desktop via direct download..."

    $DockerUrl = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
    $DownloadPath = "$env:TEMP\DockerDesktopInstaller.exe"

    Write-Log "Downloading Docker Desktop..."
    Invoke-WebRequest -Uri $DockerUrl -OutFile $DownloadPath -UseBasicParsing

    # Supply-chain: verify the installer is validly signed by Docker before running it.
    $sig = Get-AuthenticodeSignature -FilePath $DownloadPath
    if ($sig.Status -ne 'Valid' -or $sig.SignerCertificate.Subject -notmatch 'Docker') {
        Remove-Item $DownloadPath -Force -ErrorAction SilentlyContinue
        throw "Docker installer signature not trusted (status: $($sig.Status), signer: $($sig.SignerCertificate.Subject))"
    }
    Write-Log "Installer signature verified: $($sig.SignerCertificate.Subject)" "SUCCESS"

    Write-Log "Installing Docker Desktop..."
    $proc = Start-Process -FilePath $DownloadPath -ArgumentList "install", "--quiet", "--accept-license" -Wait -PassThru
    Remove-Item $DownloadPath -Force
    if ($proc.ExitCode -ne 0) {
        throw "Docker Desktop installer exited with code $($proc.ExitCode)"
    }
    Write-Log "Docker Desktop installed via direct download" "SUCCESS"
}

function Enable-DockerFeature {
    Write-Log "Enabling virtualization features for Docker..."

    foreach ($feature in @('Microsoft-Hyper-V', 'VirtualMachinePlatform', 'Microsoft-Windows-Subsystem-Linux')) {
        $state = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue
        if ($null -eq $state) {
            Write-Log "Feature $feature is not available on this edition/host (often blocked by corporate policy)" "WARN"
            continue
        }
        if ($state.State -ne "Enabled") {
            Write-Log "Enabling $feature..."
            Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart | Out-Null
        }
    }
    Write-Log "Virtualization features processed" "SUCCESS"
}

function Set-DockerDesktopConfiguration {
    Write-Log "Configuring Docker Desktop..."

    try {
        $ConfigPath = "$env:APPDATA\Docker\settings.json"
        $ConfigDir = Split-Path $ConfigPath -Parent
        if (!(Test-Path $ConfigDir)) { New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null }

        $DockerConfig = @{
            "experimental"     = $false
            "builder"          = @{
                "gc" = @{
                    "enabled" = $true
                    "policy"  = @( @{ "all" = $true; "filter" = @("unused-for=24h"); "keepStorage" = "10GB" } )
                }
            }
            "debug"            = $false
            "metricsEnabled"   = $true
        }

        # Write JSON without a BOM (Docker Desktop dislikes a BOM in settings.json).
        $json = $DockerConfig | ConvertTo-Json -Depth 10
        [System.IO.File]::WriteAllText($ConfigPath, $json)
        Write-Log "Docker Desktop configuration saved in $ConfigPath" "SUCCESS"
        # The repo's config/docker-settings.json is the source reference; it is NOT
        # overwritten here (a script must not dirty versioned files).
    }
    catch {
        Write-Log "Error configuring Docker Desktop: $($_.Exception.Message)" "ERROR"
    }
}

function Start-DockerDesktop {
    Write-Log "Starting Docker Desktop..."
    try {
        $exe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        if (-not (Test-Path $exe)) {
            Write-Log "Docker Desktop executable not found; skipping startup" "WARN"
            return
        }
        Start-Process -FilePath $exe -WindowStyle Hidden

        $timeout = 300; $elapsed = 0; $ready = $false
        while (-not $ready -and $elapsed -lt $timeout) {
            Start-Sleep -Seconds 10
            $elapsed += 10
            docker info 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) { $ready = $true }
            else { Write-Log "Waiting for Docker to start... ($elapsed/$timeout seconds)" }
        }
        if ($ready) { Write-Log "Docker Desktop started successfully" "SUCCESS" }
        else { Write-Log "Timeout during Docker Desktop startup" "WARN" }
    }
    catch {
        Write-Log "Error starting Docker Desktop: $($_.Exception.Message)" "ERROR"
    }
}

function Test-DockerInstallation {
    Write-Log "Testing Docker installation..."
    if (-not (Test-CommandExists 'docker')) {
        Write-Log "docker command not available yet (a restart may be required)" "WARN"
        return
    }
    docker version --format "{{.Server.Version}}" 2>$null | Out-Null
    if ($LASTEXITCODE -eq 0) { Write-Log "Docker engine reachable" "SUCCESS" }
    else { Write-Log "Docker installed but engine not reachable yet" "WARN" }
}

function Main {
    Write-Log "=== Docker Desktop Installation ==="

    if ((Test-CommandExists 'docker') -and (-not $Force)) {
        Write-Log "Docker is already installed" "INFO"
        Test-DockerInstallation
        return
    }

    try {
        if (-not (Test-WSL2Available)) {
            Write-Log "WSL2 not detected; enabling virtualization features (may be blocked by policy / BIOS)" "WARN"
            Enable-DockerFeature
        }

        # winget first; fall back to a signature-verified direct download.
        if (-not (Install-WingetPackage -Id 'Docker.DockerDesktop' -Name 'Docker Desktop')) {
            Write-Log "winget could not install Docker Desktop, trying direct download..." "WARN"
            Install-DockerDesktopViaDownload
        }

        if (-not (Test-DockerDesktopInstalled)) {
            throw "Docker Desktop could not be installed"
        }

        Set-DockerDesktopConfiguration
        Start-DockerDesktop
        Test-DockerInstallation

        Write-Log "Docker Desktop installed and configured" "SUCCESS"
        Write-Log "A restart is usually required to finalize installation" "WARN"
    }
    catch {
        Write-Log "Error installing Docker Desktop: $($_.Exception.Message)" "ERROR"
        throw
    }
}

Main
