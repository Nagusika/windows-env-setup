@{
    # Lint settings shared by the local pre-commit hook and CI.
    Severity = @('Error', 'Warning')

    ExcludeRules = @(
        # Colored console output is an intentional part of the UX of these scripts.
        'PSAvoidUsingWriteHost',
        # These are interactive installer scripts, not a cmdlet library, so the
        # state-changing verbs (Install/Invoke/Set) do not need -WhatIf/-Confirm.
        'PSUseShouldProcessForStateChangingFunctions',
        'PSAvoidUsingPositionalParameters'
    )
}
