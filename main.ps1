<#
.SYNOPSIS
    Reusable wrapper template for scripts with logging and progress reporting.
.DESCRIPTION
    Provides a consistent execution wrapper with:
      - parameter handling
      - transcript/log output
      - progress updates
      - start/end timing and runtime reporting
    Replace the body of Invoke-TemplateWorkload with your real workload logic.
#>

[CmdletBinding(SupportsShouldProcess=$true, SupportsPaging=$false, ConfirmImpact='Medium')]
param(
    [Parameter(Mandatory=$false)]
    [string] $LogFile = "$PSScriptRoot\$(Split-Path -Leaf $PSCommandPath).log",

    [Parameter(Mandatory=$false)]
    [ValidateRange(0,100)]
    [int] $ProgressPercent = 0,

    [Parameter(Mandatory=$false)]
    [string] $Activity = 'Custom Task',

    [Parameter(Mandatory=$false)]
    [switch] $NoTranscript
)

Set-StrictMode -Version Latest

$script:ScriptStartTime = Get-Date
$script:TranscriptStarted = $false

function Initialize-Log {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Path
    )

    $parentDir = Split-Path -Path $Path -Parent
    if ($parentDir -and -not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (-not $NoTranscript) {
        Start-Transcript -Path $Path -Append | Out-Null
        $script:TranscriptStarted = $true
    }

    Write-Verbose "Logging initialized. Log file: $Path"
    Write-Log -Message "Start time: $($script:ScriptStartTime.ToString('yyyy-MM-dd HH:mm:ss'))" -Level INFO
}

function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $Message,

        [ValidateSet('INFO','WARN','ERROR','DEBUG')] [string] $Level = 'INFO'
    )

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$timestamp] [$Level] $Message"

    Write-Verbose $entry
    if ($Level -ne 'DEBUG') {
        Write-Information -MessageData $entry -InformationAction Continue
    }
}

function Show-ProgressBar {
    param(
        [Parameter(Mandatory=$false)]
        [ValidateRange(0,100)]
        [int] $PercentComplete,

        [string] $Activity = 'Processing',

        [string] $Status = '',

        [switch] $Completed
    )

    if ($Completed) {
        Write-Progress -Activity $Activity -Completed
        return
    }

    Write-Progress -Activity $Activity -Status $Status -PercentComplete $PercentComplete
}

function Invoke-TemplateWorkload {
    param(
        [Parameter(Mandatory=$true)]
        [string] $ActivityName
    )

    # Replace this block with your real workload.
    for ($i = $ProgressPercent; $i -le 100; $i += 10) {
        Start-Sleep -Milliseconds 200
        Show-ProgressBar -PercentComplete $i -Activity $ActivityName -Status "Step $i% complete"
        Write-Log -Message "Completed $i% of custom task." -Level DEBUG
    }
}

try {
    Initialize-Log -Path $LogFile

    Write-Log -Message 'Beginning workload execution...' -Level INFO
    Show-ProgressBar -PercentComplete $ProgressPercent -Activity $Activity -Status 'Starting'

    if ($PSCmdlet.ShouldProcess($Activity, 'Execute workload')) {
        Invoke-TemplateWorkload -ActivityName $Activity
        Show-ProgressBar -PercentComplete 100 -Activity $Activity -Status 'Completed'
        Write-Log -Message 'Custom workload completed successfully.' -Level INFO
    }
    else {
        Write-Log -Message 'Workload execution skipped by ShouldProcess.' -Level WARN
    }
}
catch {
    Write-Log -Message "An error occurred: $_" -Level ERROR
    throw
}
finally {
    $endTime = Get-Date
    $duration = $endTime - $script:ScriptStartTime
    Write-Log -Message "End time: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))" -Level INFO
    Write-Log -Message "Total runtime: $([math]::Round($duration.TotalSeconds,3)) seconds" -Level INFO
    Show-ProgressBar -Activity $Activity -Completed

    if ($script:TranscriptStarted) {
        try {
            Stop-Transcript | Out-Null
        }
        catch {
            Write-Warning "Unable to stop transcript cleanly: $_"
        }
    }
}
