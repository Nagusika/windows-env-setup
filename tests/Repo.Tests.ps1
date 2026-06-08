BeforeDiscovery {
    $repoRoot = Split-Path $PSScriptRoot -Parent
    $psFiles = Get-ChildItem -Path $repoRoot -Recurse -Include '*.ps1', '*.psm1' -File |
        Where-Object { $_.FullName -notmatch '[\\/]tests[\\/]' }
    $jsonFiles = Get-ChildItem -Path (Join-Path $repoRoot 'config') -Filter '*.json' -File
}

Describe 'PowerShell sources parse without errors' {
    It '<Name> has no parse errors' -ForEach $psFiles {
        $parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$parseErrors) | Out-Null
        $parseErrors | Should -BeNullOrEmpty
    }
}

Describe 'config JSON files are valid' {
    It '<Name> parses as JSON' -ForEach $jsonFiles {
        { Get-Content $_.FullName -Raw | ConvertFrom-Json } | Should -Not -Throw
    }
}
