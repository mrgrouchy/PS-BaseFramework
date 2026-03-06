# PS-BaseFramework

Reusable PowerShell script wrapper that provides:
- structured logging
- transcript capture
- progress reporting
- runtime and end-of-run reporting
- `-WhatIf`/`-Confirm` support via `ShouldProcess`

## Files
- `main.ps1`: base wrapper template. Replace `Invoke-TemplateWorkload` with your real workload.

## Quick Start
1. Edit `main.ps1`.
2. Replace the logic in `Invoke-TemplateWorkload`.
3. Run the script:

```powershell
.\main.ps1 -Verbose
```

## Parameters
- `-LogFile <string>`: transcript/log file path. Default is `<scriptname>.log` in script folder.
- `-ProgressPercent <int>`: initial progress value (`0..100`).
- `-Activity <string>`: progress activity label.
- `-NoTranscript`: disable `Start-Transcript`.

## Example

```powershell
.\main.ps1 -Activity "User Sync" -ProgressPercent 10 -Verbose
```

## What To Customize
- `Invoke-TemplateWorkload` in `main.ps1`: place your workload here.
- `Write-Log` level usage (`INFO`, `WARN`, `ERROR`, `DEBUG`) based on your operational needs.
- parameter list for workload-specific inputs.

## CI
GitHub Actions workflow at `.github/workflows/powershell-ci.yml` runs:
- PowerShell parse check
- PSScriptAnalyzer checks

## Project Governance
- Contributing guide: `CONTRIBUTING.md`
- Security policy: `SECURITY.md`
- License: `LICENSE` (MIT)
