# Contributing

## Workflow
1. Create a branch from `master`.
2. Make focused changes with clear commit messages.
3. Run local checks before opening a PR.
4. Open a PR with context, testing notes, and impact summary.

## Local checks
Run parse validation:

```powershell
$tokens=$null
$errors=$null
$code = Get-Content -Raw -Path .\main.ps1
[System.Management.Automation.Language.Parser]::ParseInput($code,[ref]$tokens,[ref]$errors) | Out-Null
$errors
```

Run script analyzer (if installed):

```powershell
Invoke-ScriptAnalyzer -Path .\main.ps1 -Severity Error,Warning
```

## Style
- Keep functions small and focused.
- Use `Set-StrictMode -Version Latest`.
- Prefer explicit parameter validation.
- Keep output automation-friendly (`Write-Information`/`Write-Verbose` over `Write-Host`).
