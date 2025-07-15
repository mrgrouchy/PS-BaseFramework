<#
.SYNOPSIS
    Base framework for PowerShell scripts with verbose logging and progress display.
.DESCRIPTION
    This template provides a standard structure: parameter handling, logging to file, verbose output,
    and progress reporting to the console, with human-readable start/end timestamps and duration.
#>

[CmdletBinding(SupportsShouldProcess=$true, SupportsPaging=$false, ConfirmImpact='Medium')]
param(
    [Parameter(Mandatory=$false)]
    [string] $LogFile = "$PSScriptRoot\$(Split-Path -Leaf $PSCommandPath).log",
    [Parameter(Mandatory=$false)]
    [ValidateRange(0,100)]
    [int] $ProgressPercent = 0
)

# Enforce strict mode
Set-StrictMode -Version Latest

# Initialize transcript/logging
function Initialize-Log {
    param(
        [string] $Path
    )
    if (-not (Test-Path -Path (Split-Path $Path))) {
        New-Item -ItemType Directory -Path (Split-Path $Path) -Force | Out-Null
    }
    # Record start time
    $Global:ScriptStartTime = Get-Date
    # Start transcript to capture all output
    Start-Transcript -Path $Path -Append | Out-Null
    Write-Verbose "Logging initialized. Log file: $Path"
    # Log script start with human-readable timestamp
    Write-Log -Message "Start time: $($Global:ScriptStartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -Level INFO
}

# Write log entry
function Write-Log {
    param(
        [string] $Message,
        [ValidateSet('INFO','WARN','ERROR','DEBUG')] [string] $Level = 'INFO'
    )
    # Timestamp with readable format
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$timestamp] [$Level] $Message"
    # Always log to verbose stream (captured in transcript)
    Write-Verbose $entry
    # Only display to console for non-DEBUG levels
    if ($Level -ne 'DEBUG') {
        Write-Host $entry
    }
}

# Report progress
function Show-ProgressBar {
    param(
        [int] $PercentComplete,
        [string] $Activity = 'Processing',
        [string] $Status = ''
    )
    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

# Main script logic
try {
    Initialize-Log -Path $LogFile

    # --------------------------------
    # Example workload structure:
    #  1. Pre-Workload Setup
    #  2. CUSTOM WORKLOAD BLOCK (add your code here)
    #  3. Post-Workload Cleanup/Logging
    # --------------------------------

    # 1. Pre-Workload Setup
    Write-Log -Message 'Beginning workload execution...' -Level INFO
    # Initialize progress
    Show-ProgressBar -PercentComplete 0 -Activity 'Custom Task' -Status 'Starting'

    # 2. CUSTOM WORKLOAD BLOCK
    <#
        Add your custom processing logic below.
        For example:
          - Iterate over input items
          - Call external APIs or cmdlets
          - Perform file operations, database queries, etc.

        Use Write-Log -Level INFO/WARN/ERROR for high-level messages
        Use Write-Log -Level DEBUG for detailed diagnostics (not shown on console)
        Use Show-ProgressBar to update progress as needed.
    #>
    for ($i = 0; $i -le 100; $i += 10) {
        # Simulated work step
        Start-Sleep -Milliseconds 200
        # Update progress
        Show-ProgressBar -PercentComplete $i -Activity 'Custom Task' -Status "Step $i% complete"
        Write-Log -Message "Completed $i% of custom task." -Level DEBUG
    }

    # 3. Post-Workload Cleanup/Logging
    Show-ProgressBar -PercentComplete 100 -Activity 'Custom Task' -Status 'Completed'
    Write-Log -Message 'Custom workload completed successfully.' -Level INFO

}
catch {
    Write-Log -Message "An error occurred: $_" -Level ERROR
    throw
}
finally {
    # Record end time
    $endTime = Get-Date
    # Calculate duration
    $duration = $endTime - $Global:ScriptStartTime
    # Log script end with human-readable timestamp and duration
    Write-Log -Message "End time: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))" -Level INFO
    Write-Log -Message "Total runtime: $([math]::Round($duration.TotalSeconds,3)) seconds" -Level INFO
    Stop-Transcript | Out-Null
}
