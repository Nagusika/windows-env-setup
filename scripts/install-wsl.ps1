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

function Set-UbuntuConfiguration {
    Write-Log "Configuring WSL / Ubuntu..."

    # 1) Windows-side global config (.wslconfig), written without a BOM.
    $wslConfig = @"
[wsl2]
memory=4GB
processors=2
swap=2GB
localhostForwarding=true
"@ -replace "`r`n", "`n"
    [System.IO.File]::WriteAllText("$env:USERPROFILE\.wslconfig", $wslConfig)
    Write-Log "Wrote $env:USERPROFILE\.wslconfig" "SUCCESS"

    # 2) Distro-side /etc/wsl.conf - ACTUALLY deployed into the distro (LF, no BOM).
    $distro = Get-WslDistro
    if (-not $distro) {
        Write-Log "No Ubuntu distro found; skipping /etc/wsl.conf deployment" "WARN"
        return
    }

    $wslConf = @"
[boot]
systemd=true

[network]
generateHosts = true
generateResolvConf = true

[interop]
enabled = true
appendWindowsPath = true
"@ -replace "`r`n", "`n"

    $tmp = Join-Path $env:TEMP 'wsl.conf'
    [System.IO.File]::WriteAllText($tmp, $wslConf)
    $tmpWslPath = (wsl -d $distro -e wslpath -u $tmp 2>$null)
    $tmpWslPath = ($tmpWslPath -replace "`0", "").Trim()

    wsl -d $distro -u root -e cp $tmpWslPath /etc/wsl.conf
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Failed to deploy /etc/wsl.conf (exit $LASTEXITCODE)" "WARN"
    }
    else {
        Write-Log "Deployed /etc/wsl.conf into $distro" "SUCCESS"
    }
    Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    wsl --terminate $distro 2>$null | Out-Null
}

function Update-UbuntuPackage {
    Write-Log "Updating Ubuntu packages..."
    $distro = Get-WslDistro
    if (-not $distro) { Write-Log "No Ubuntu distro found; skipping package update" "WARN"; return }

    $packages = "curl wget git vim htop tree unzip zip"
    wsl -d $distro -e bash -c "sudo apt update && sudo apt upgrade -y && sudo apt install -y $packages"
    if ($LASTEXITCODE -ne 0) { Write-Log "apt update/install returned exit $LASTEXITCODE" "WARN" }
    else { Write-Log "Ubuntu packages updated" "SUCCESS" }
}

function Main {
    Write-Log "=== WSL2 + Ubuntu Installation ==="

    if ((Test-CommandExists 'wsl') -and (-not $Force) -and (Get-WslDistro)) {
        Write-Log "WSL with Ubuntu is already installed" "INFO"
        Set-UbuntuConfiguration
        Update-UbuntuPackage
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
        Set-UbuntuConfiguration
        Update-UbuntuPackage

        Write-Log "WSL2 + Ubuntu installed and configured" "SUCCESS"
        Write-Log "A restart may be required to finalize installation" "WARN"
    }
    catch {
        Write-Log "Error installing WSL: $($_.Exception.Message)" "ERROR"
        throw
    }
}

Main
