# Contributing

Thanks for your interest in improving **windows-env-setup**! Contributions —
bug reports, new packages, documentation fixes, and pull requests — are welcome.

## Development setup

This project uses [`pre-commit`](https://pre-commit.com/) to enforce code quality
(PSScriptAnalyzer for PowerShell, plus whitespace/JSON/YAML checks).

1. **Install pre-commit** (requires Python):
   ```bash
   pip install pre-commit
   ```

2. **Install PSScriptAnalyzer** (PowerShell, as administrator):
   ```powershell
   Install-Module -Name PSScriptAnalyzer -Force -SkipPublisherCheck
   ```

3. **Install the git hooks** (from the repo root):
   ```bash
   pre-commit install
   ```

`pre-commit` now runs automatically on every `git commit`.

## Conventions

- **Commits** follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `refactor:`, `chore:`…), matching the existing history.
- **PowerShell** must pass `Invoke-ScriptAnalyzer -Path . -Recurse` with no errors.
- **Native commands** (`winget`, `wsl`, `msiexec`): always check `$LASTEXITCODE` —
  these do **not** throw on failure, so a bare `try/catch` around them is a no-op.
- **Idempotence**: a script must be safe to re-run; detect already-done state and
  converge instead of erroring or duplicating side effects.
- **Corporate-safe by default**: never add a policy-risky tool to a default-installed
  category. Risk-bearing tools go in the opt-in *Advanced* tier with a warning
  (see [SECURITY.md](SECURITY.md)).

## Reporting bugs / suggesting packages

Open an issue describing your environment (Windows version, PowerShell version) and,
for a package suggestion, its exact `winget` id and which tier it belongs to.
