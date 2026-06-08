BeforeAll {
    $ModulePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'WinEnvSetup.psm1'
    Import-Module $ModulePath -Force
}

Describe 'Invoke-Native' {
    It 'returns 0 on a successful command' {
        Invoke-Native -Command { cmd /c exit 0 } | Should -Be 0
    }

    It 'throws when the exit code is not a success code' {
        { Invoke-Native -Command { cmd /c exit 1 } -Action 'unit test' } | Should -Throw
    }

    It 'accepts custom success exit codes' {
        Invoke-Native -Command { cmd /c exit 3 } -SuccessExitCodes @(0, 3) | Should -Be 3
    }
}

Describe 'Test-CommandExists' {
    It 'returns true for an existing command' {
        Test-CommandExists 'powershell' | Should -BeTrue
    }

    It 'returns false for a missing command' {
        Test-CommandExists 'totally-not-a-real-command-xyz' | Should -BeFalse
    }
}

AfterAll {
    Remove-Module WinEnvSetup -ErrorAction SilentlyContinue
}
