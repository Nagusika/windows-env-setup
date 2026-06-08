#Requires -Version 5.1
#Requires -RunAsAdministrator
# Installation and configuration of WSL2 with Ubuntu.
# Tier 2 (virtualization): requires admin + VirtualMachinePlatform + BIOS virtualization,
# which corporate policy or a locked BIOS may block even when you have admin rights.

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
Import-Module (Join-Path $PSScriptRoot '..\WinEnvSetup.psm1') -Force
Initialize-Log -LogFile (Join-Path $PSScriptRoot '..\logs\wsl.log')

$ConfigDir = Join-Path $PSScriptRoot '..\config'

function Test-FeatureEnabled {
    param([string]$Name)
    $f = Get-WindowsOptionalFeature -Online -FeatureName $Name -ErrorAction SilentlyContinue
    return $f -and $f.State -eq "Enabled"
}

function Enable-WSLFeature {
    Write-Log "Enabling WSL features..."
    foreach ($feature in @('Microsoft-Windows-Subsystem-Linux', 'VirtualMachinePlatform')) {
        if (-not (Test-FeatureEnabled $feature)) {
            $available = Get-WindowsOptionalFeature -Online -FeatureName $feature -ErrorAction SilentlyContinue
            if ($null -eq $available) {
                throw "Feature $feature is unavailable on this host (often blocked by corporate policy)"
            }
            Write-Log "Enabling $feature..."
            Enable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart | Out-Null
        }
    }
    Write-Log "WSL features enabled" "SUCCESS"
}

function Install-WSLKernelUpdate {
    Write-Log "Installing WSL kernel update..."
    $KernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $DownloadPath = "$env:TEMP\wsl_update.msi"

    Write-Log "Downloading WSL kernel update..."
    Invoke-WebRequest -Uri $KernelUrl -OutFile $DownloadPath -UseBasicParsing

    # Supply-chain: verify the MSI is validly signed by Microsoft before installing.
    $sig = Get-AuthenticodeSignature -FilePath $DownloadPath
    if ($sig.Status -ne 'Valid' -or $sig.SignerCertificate.Subject -notmatch 'Microsoft') {
        Remove-Item $DownloadPath -Force -ErrorAction SilentlyContinue
        throw "WSL kernel MSI signature not trusted (status: $($sig.Status))"
    }
    Write-Log "Kernel MSI signature verified" "SUCCESS"

    $proc = Start-Process msiexec.exe -ArgumentList "/i `"$DownloadPath`" /quiet" -Wait -PassThru
    Remove-Item $DownloadPath -Force -ErrorAction SilentlyContinue
    if ($proc.ExitCode -ne 0) { throw "msiexec failed (exit $($proc.ExitCode))" }
    Write-Log "WSL kernel update installed" "SUCCESS"
}

function Set-WSL2AsDefault {
    Write-Log "Setting WSL2 as default version..."
    wsl --set-default-version 2
    if ($LASTEXITCODE -ne 0) { Write-Log "Could not set WSL2 default (exit $LASTEXITCODE)" "WARN" }
    else { Write-Log "WSL2 set as default version" "SUCCESS" }
}

function Install-UbuntuLatest {
    Write-Log "Installing Ubuntu..."
    wsl --install -d Ubuntu --no-launch
    if ($LASTEXITCODE -ne 0) { throw "wsl --install Ubuntu failed (exit $LASTEXITCODE)" }
    Write-Log "Ubuntu installation requested" "SUCCESS"
}

# Copy a repo text file into WSL, normalising to LF without a BOM first so the
# file is valid for Linux consumers regardless of git's checkout line endings.
function Copy-UnixTextIntoWsl {
    param(
        [string]$Distro,
        [string]$LocalPath,
        [string]$DestPath,
        [switch]$AsRoot
    )
    $content = (Get-Content -Path $LocalPath -Raw) -replace "`r`n", "`n"
    $tmp = Join-Path $env:TEMP ([System.IO.Path]::GetFileName($DestPath))
    [System.IO.File]::WriteAllText($tmp, $content)
    if ($AsRoot) { Copy-IntoWsl -Distro $Distro -LocalPath $tmp -DestPath $DestPath -AsRoot }
    else { Copy-IntoWsl -Distro $Distro -LocalPath $tmp -DestPath $DestPath }
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
}

function Set-WslConfiguration {
    Write-Log "Deploying WSL configuration..."

    # Windows-side global config: corporate networking (mirrored / dnsTunneling /
    # autoProxy) + idle memory reclaim. Plain copy (Windows-side file).
    $globalSrc = Join-Path $ConfigDir 'wslconfig'
    if (Test-Path $globalSrc) {
        Copy-Item -Path $globalSrc -Destination "$env:USERPROFILE\.wslconfig" -Force
        Write-Log "Deployed .wslconfig (mirrored networking, dnsTunneling, autoProxy, memory reclaim)" "SUCCESS"
    }

    # Distro-side /etc/wsl.conf: systemd, appendWindowsPath=false, automount metadata.
    $distro = Get-WslDistro
    if (-not $distro) { Write-Log "No Ubuntu distro found; skipping /etc/wsl.conf" "WARN"; return }

    $distroSrc = Join-Path $ConfigDir 'wsl.conf'
    if (Test-Path $distroSrc) {
        try {
            Copy-UnixTextIntoWsl -Distro $distro -LocalPath $distroSrc -DestPath '/etc/wsl.conf' -AsRoot
            Write-Log "Deployed /etc/wsl.conf into $distro" "SUCCESS"
        }
        catch { Write-Log "Could not deploy /etc/wsl.conf: $($_.Exception.Message)" "WARN" }
    }
    wsl --terminate $distro 2>$null | Out-Null
}

function Initialize-DistroEnvironment {
    Write-Log "Provisioning the WSL dev environment..."
    $distro = Get-WslDistro
    if (-not $distro) { Write-Log "No Ubuntu distro found; skipping provisioning" "WARN"; return }

    $provisionSrc = Join-Path $ConfigDir 'wsl-provision.sh'
    $starshipSrc = Join-Path $ConfigDir 'starship.toml'
    if (-not (Test-Path $provisionSrc)) { Write-Log "Provision script missing; skipping" "WARN"; return }

    try {
        if (Test-Path $starshipSrc) {
            Copy-UnixTextIntoWsl -Distro $distro -LocalPath $starshipSrc -DestPath '/tmp/starship.toml'
        }
        Copy-UnixTextIntoWsl -Distro $distro -LocalPath $provisionSrc -DestPath '/tmp/wsl-provision.sh'
        wsl -d $distro -e bash /tmp/wsl-provision.sh
        if ($LASTEXITCODE -ne 0) { Write-Log "Provisioning returned exit $LASTEXITCODE" "WARN" }
        else { Write-Log "WSL dev environment provisioned" "SUCCESS" }
    }
    catch { Write-Log "Provisioning error: $($_.Exception.Message)" "WARN" }
}

function Main {
    Write-Log "=== WSL2 + Ubuntu Installation ==="

    if ((Test-CommandExists 'wsl') -and (-not $Force) -and (Get-WslDistro)) {
        Write-Log "WSL with Ubuntu is already installed" "INFO"
        Set-WslConfiguration
        Initialize-DistroEnvironment
        return
    }

    try {
        Enable-WSLFeature

        # If the features were just enabled, WSL needs a reboot before it works.
        wsl --status 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Log "A restart is required to enable WSL. Reboot and run this script again." "WARN"
            throw "Restart required for WSL"
        }

        Install-WSLKernelUpdate
        Set-WSL2AsDefault
        Install-UbuntuLatest
        Set-WslConfiguration
        Initialize-DistroEnvironment

        Write-Log "WSL2 + Ubuntu installed and configured" "SUCCESS"
        Write-Log "A restart may be required to finalize installation" "WARN"
    }
    catch {
        Write-Log "Error installing WSL: $($_.Exception.Message)" "ERROR"
        throw
    }
}

Main
