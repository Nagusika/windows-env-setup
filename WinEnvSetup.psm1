#Requires -Version 5.1
<#
.SYNOPSIS
    Shared helpers for the windows-env-setup scripts.

.DESCRIPTION
    Single source of truth for logging, prompting and — most importantly — honest
    handling of native command exit codes. winget/wsl/msiexec do NOT throw on a
    non-zero exit, so a bare try/catch around them is a no-op; use Invoke-Native or
    Install-WingetPackage instead so failures are actually detected.
#>

Set-StrictMode -Version Latest

$script:WinEnvLogFile = $null

# winget exit codes that are NOT failures for an "ensure installed" intent.
# Treating these as success keeps re-runs idempotent (already-installed is fine).
#   0            success
#   -1978335135  0x8A150061  package already installed / no applicable upgrade
#   -1978335189  0x8A15002B  update not applicable (already current)
$script:WingetSuccessExitCodes = @(0, -1978335135, -1978335189)

function Initialize-Log {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$LogFile)

    $dir = Split-Path -Path $LogFile -Parent
    if ($dir -and -not (Test-Path -Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $script:WinEnvLogFile = $LogFile
}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO', 'SUCCESS', 'WARN', 'ERROR', 'SKIP')][string]$Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = "[$timestamp] [$Level] $Message"
    $color = switch ($Level) {
        'SUCCESS' { 'Green' }
        'ERROR'   { 'Red' }
        'WARN'    { 'Yellow' }
        'SKIP'    { 'Cyan' }
        default   { 'White' }
    }

    Write-Host $line -ForegroundColor $color
    if ($script:WinEnvLogFile) {
        Add-Content -Path $script:WinEnvLogFile -Value $line
    }
}

function Confirm-Action {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [bool]$DefaultYes = $false
    )

    # Non-interactive (pipe / CI): never silently apply a default that would install
    # software or reboot. Decline instead.
    if (-not [Environment]::UserInteractive) {
        Write-Log "Non-interactive session: '$Message' -> No" 'SKIP'
        return $false
    }

    $suffix = if ($DefaultYes) { '(Y/n)' } else { '(y/N)' }
    $response = Read-Host "$Message $suffix"
    if ([string]::IsNullOrWhiteSpace($response)) { return $DefaultYes }
    return $response -match '^[Yy]'
}

function Test-CommandExists {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Name)
    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Invoke-Native {
    <#
    .SYNOPSIS
        Run a native command and throw if its exit code is not a success code.
    .EXAMPLE
        Invoke-Native { wsl --set-default-version 2 } -Action 'set WSL2 default'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][scriptblock]$Command,
        [int[]]$SuccessExitCodes = @(0),
        [string]$Action = 'native command'
    )

    & $Command
    $code = $LASTEXITCODE
    if ($SuccessExitCodes -notcontains $code) {
        throw "$Action failed (exit code $code)"
    }
    return $code
}

function Install-WingetPackage {
    <#
    .SYNOPSIS
        Install a winget package, reporting real success/failure. Idempotent: an
        already-installed package is treated as success.
    .OUTPUTS
        [bool] $true if installed (or already present), $false otherwise.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Id,
        [string]$Name = $Id,
        [ValidateSet('user', 'machine')][string]$Scope
    )

    if (-not (Test-CommandExists 'winget')) {
        Write-Log "winget not available; cannot install $Name" 'WARN'
        return $false
    }

    Write-Log "Installing $Name..."
    $wingetArgs = @(
        'install', '--exact', '--id', $Id, '--silent',
        '--accept-package-agreements', '--accept-source-agreements'
    )
    if ($Scope) { $wingetArgs += @('--scope', $Scope) }

    winget @wingetArgs
    $code = $LASTEXITCODE

    if ($script:WingetSuccessExitCodes -contains $code) {
        Write-Log "$Name installed (winget exit $code)" 'SUCCESS'
        return $true
    }

    Write-Log "Failed to install $Name (winget exit $code)" 'WARN'
    return $false
}

Export-ModuleMember -Function Initialize-Log, Write-Log, Confirm-Action,
    Test-CommandExists, Invoke-Native, Install-WingetPackage
