---
name: ps-script
description: Scaffold and extend PowerShell scripts using the PS-BaseFramework pattern, which includes structured logging, transcript capture, progress reporting, runtime tracking, and -WhatIf/-Confirm support via ShouldProcess.
---

# PS-BaseFramework Script Skill

Use this skill when the user wants to create, extend, or modify a PowerShell script that follows the PS-BaseFramework pattern.

## When to Use

- Creating a new PowerShell script that needs logging, progress tracking, or transcript capture
- Adding the PS-BaseFramework wrapper pattern to existing PowerShell code
- Extending a script built on this framework with new parameters or workload logic
- Helping users understand or customize any part of the framework

## Framework Overview

The framework (`main.ps1`) provides:

- **Structured logging** via `Write-Log` (levels: `INFO`, `WARN`, `ERROR`, `DEBUG`)
- **Transcript capture** via `Start-Transcript` (disable with `-NoTranscript`)
- **Progress reporting** via `Show-ProgressBar` wrapping `Write-Progress`
- **Runtime tracking**: start/end time and total seconds logged automatically
- **ShouldProcess support**: `-WhatIf` and `-Confirm` work out of the box
- **Strict mode**: `Set-StrictMode -Version Latest` enabled by default

## Steps for Scaffolding a New Script

1. Copy `main.ps1` as the starting point (or start from the pattern below).
2. Add workload-specific parameters to the `param()` block.
3. Replace the body of `Invoke-TemplateWorkload` with real logic.
4. Use `Write-Log -Level INFO/WARN/ERROR/DEBUG` for all output.
5. Use `Show-ProgressBar` to report incremental progress.
6. Keep the `try/catch/finally` block intact — it ensures cleanup runs on success and failure.

## Core Pattern

```powershell
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
param(
    [string] $LogFile = "$PSScriptRoot\$(Split-Path -Leaf $PSCommandPath).log",
    [ValidateRange(0,100)][int] $ProgressPercent = 0,
    [string] $Activity = 'Custom Task',
    [switch] $NoTranscript
    # Add your own parameters here
)

Set-StrictMode -Version Latest
$script:ScriptStartTime = Get-Date
$script:TranscriptStarted = $false

# ... (Initialize-Log, Write-Log, Show-ProgressBar functions)

function Invoke-TemplateWorkload {
    param([string] $ActivityName)
    # Replace with real workload logic
}

try {
    Initialize-Log -Path $LogFile
    if ($PSCmdlet.ShouldProcess($Activity, 'Execute workload')) {
        Invoke-TemplateWorkload -ActivityName $Activity
    }
}
catch { Write-Log -Message "Error: $_" -Level ERROR; throw }
finally {
    # runtime reporting and transcript stop always run
}
```

## Customization Guidelines

- **Parameters**: Add workload-specific params to `param()`. Keep framework params (`-LogFile`, `-ProgressPercent`, `-Activity`, `-NoTranscript`) unless there is a specific reason to remove them.
- **Workload logic**: All real work goes inside `Invoke-TemplateWorkload`. Break complex logic into helper functions called from there.
- **Log levels**: Use `DEBUG` for verbose step-by-step details, `INFO` for milestones, `WARN` for recoverable issues, `ERROR` for failures.
- **Progress**: Call `Show-ProgressBar` at meaningful checkpoints, not on every loop iteration.
- **ShouldProcess**: Keep `$PSCmdlet.ShouldProcess(...)` wrapping any side-effecting operations to support `-WhatIf`.

## Example: Custom Script

```powershell
# my-sync.ps1 — extends PS-BaseFramework for a user sync task
param(
    [string] $LogFile = "$PSScriptRoot\my-sync.log",
    [switch] $NoTranscript,
    [Parameter(Mandatory=$true)]
    [string] $TenantId
)
# ... (paste framework functions here)

function Invoke-TemplateWorkload {
    param([string] $ActivityName)
    Write-Log -Message "Starting sync for tenant: $TenantId" -Level INFO
    Show-ProgressBar -PercentComplete 10 -Activity $ActivityName -Status 'Fetching users'
    # real sync logic here
    Show-ProgressBar -PercentComplete 100 -Activity $ActivityName -Status 'Done'
}
```
