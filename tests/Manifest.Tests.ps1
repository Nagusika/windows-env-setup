BeforeAll {
    $root = Split-Path $PSScriptRoot -Parent
    $manifest = Get-Content (Join-Path $root 'manifests/packages.json') -Raw | ConvertFrom-Json
    $categories = $manifest.categories
    $allIds = $categories.packages.id
}

Describe 'packages manifest' {
    It 'declares at least one category' {
        $categories.Count | Should -BeGreaterThan 0
    }

    It 'gives every package a non-empty id and name' {
        foreach ($cat in $categories) {
            foreach ($pkg in $cat.packages) {
                $pkg.id   | Should -Not -BeNullOrEmpty
                $pkg.name | Should -Not -BeNullOrEmpty
            }
        }
    }

    It 'uses only known tiers' {
        foreach ($cat in $categories) {
            $cat.tier | Should -BeIn @('default', 'advanced')
        }
    }

    It 'never ships qBittorrent (P2P / HR risk)' {
        $allIds | Should -Not -Contain 'qBittorrent.qBittorrent'
    }

    It 'keeps policy-risky tools out of the default tiers' {
        $risky = @(
            'WiresharkFoundation.Wireshark', 'Insecure.Nmap', 'ProcessHacker.ProcessHacker',
            'RustDesk.RustDesk', 'Rufus.Rufus', 'Ventoy.Ventoy'
        )
        foreach ($cat in $categories) {
            if ($cat.tier -ne 'advanced') {
                foreach ($r in $risky) {
                    $cat.packages.id | Should -Not -Contain $r
                }
            }
        }
    }

    It 'has no duplicate package ids' {
        ($allIds | Group-Object | Where-Object { $_.Count -gt 1 }).Count | Should -Be 0
    }
}
