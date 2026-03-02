<#
.SYNOPSIS
    Base framework for PowerShell scripts with verbose logging and progress display.
.DESCRIPTION
    This template provides a standard structure: parameter handling, logging to file, verbose output,
    and progress reporting to the console, with human-readable start/end timestamps and duration.
#>

[CmdletBinding()]
param(
    [string] $LogFile = (Join-Path $PSScriptRoot "$(Split-Path -Leaf $PSCommandPath).log")
)

# Enforce strict mode
Set-StrictMode -Version Latest

$script:TimestampFormat = 'yyyy-MM-dd HH:mm:ss'
$script:ScriptStartTime = $null

# Initialize transcript/logging
function Initialize-Log {
    param(
        [string] $Path
    )
    $logDir = Split-Path $Path
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    # Record start time
    $script:ScriptStartTime = Get-Date
    # Start transcript to capture all output
    Start-Transcript -Path $Path -Append | Out-Null
    Write-Verbose "Logging initialized. Log file: $Path"
    # Log script start with human-readable timestamp
    Write-Log -Message "Start time: $($script:ScriptStartTime.ToString($script:TimestampFormat))" -Level INFO
}

# Write log entry
function Write-Log {
    param(
        [string] $Message,
        [ValidateSet('INFO','WARN','ERROR','DEBUG')] [string] $Level = 'INFO'
    )
    # Timestamp with readable format
    $entry = "[$(Get-Date -Format $script:TimestampFormat)] [$Level] $Message"
    # DEBUG goes to verbose stream only; all others go to host (captured by transcript)
    if ($Level -eq 'DEBUG') {
        Write-Verbose $entry
    } else {
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
    # Record end time and calculate duration
    $endTime = Get-Date
    $duration = $endTime - $script:ScriptStartTime
    Write-Log -Message "End time: $($endTime.ToString($script:TimestampFormat))" -Level INFO
    Write-Log -Message "Total runtime: $($duration.TotalSeconds.ToString('F3')) seconds" -Level INFO
    Stop-Transcript | Out-Null
}
