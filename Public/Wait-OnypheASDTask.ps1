	Function Wait-OnypheASDTask {
	<#
	  .SYNOPSIS
	  main function/cmdlet - wait for an ASD task on onyphe.io web service to finish, then return its result

	  .DESCRIPTION
	  main function/cmdlet - wait for an ASD task on onyphe.io web service to finish, then return its result.
	  Repeatedly checks Get-OnypheASDTaskList's per-task "running" flag (the only reliable completion signal
	  found live-testing 2026-09-18 - the ASD Task Poll APIv1's own output is a rolling numeric progress-tick
	  array that does not visibly change shape on completion, so it's surfaced here only as -Verbose progress
	  information, not used to detect completion) every -PollIntervalSec seconds, up to -TimeoutSec seconds
	  total, then calls Get-OnypheASDTask to fetch and return the finished task's actual result. If the task ID
	  is no longer present in Get-OnypheASDTaskList at all (already cleared, or never existed), attempts
	  Get-OnypheASDTask once anyway as a fallback so the caller still sees whatever error the server reports,
	  rather than this cmdlet silently returning nothing. On timeout, returns the last-seen task-list entry
	  with a warning instead of the (still unfinished) result. These are BETA endpoints requiring a Griffin
	  View or Griffin View ASM Edition subscription with a non-commercial use licence - see
	  Get-OnypheUserInfo's asd.stdapis property to check whether they are licensed on your account.

	  .PARAMETER TaskId
	  -TaskId string
	  the task ID to wait for

	  .PARAMETER PollIntervalSec
	  -PollIntervalSec int
	  seconds to wait between each check (default 5)

	  .PARAMETER TimeoutSec
	  -TimeoutSec int
	  maximum total seconds to wait before giving up (default 300)

	  .PARAMETER APIKey
	  -APIKey string{APIKEY}
	  set your APIKEY to be able to use Onyphe API.

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  wait for an ASD task to finish (default polling every 5s, up to 300s), then return its result
	  C:\PS> Wait-OnypheASDTask -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7"

	  .EXAMPLE
	  wait for a long-running task, checking every 10 seconds for up to 10 minutes
	  C:\PS> Wait-OnypheASDTask -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7" -PollIntervalSec 10 -TimeoutSec 600
	#>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
				[string]$TaskId,
			[parameter(Mandatory=$false)]
			[ValidateRange(1,[int]::MaxValue)]
				[int]$PollIntervalSec = 5,
			[parameter(Mandatory=$false)]
			[ValidateRange(1,[int]::MaxValue)]
				[int]$TimeoutSec = 300,
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey
		)
		Process {
			$Config = Read-OnypheConfigFile
			Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}

			$startTime = Get-Date
			$lastList = $null
			$finished = $false
			do {
				$lastList = Invoke-APIOnypheASDTaskList
				$task = $lastList.results | Where-Object { $_.taskid -eq $TaskId }
				if (-not $task) {
					Write-Verbose -message "TaskId $($TaskId) not found in Get-OnypheASDTaskList - trying Get-OnypheASDTask directly as a fallback"
					break
				}
				if ($task.running -eq 'false') {
					$finished = $true
					break
				}
				Write-Verbose -message "TaskId $($TaskId) still running, polling for progress"
				Invoke-APIOnypheASDTaskPoll -TaskId $TaskId | Out-Null
				if ((New-TimeSpan -Start $startTime -End (Get-Date)).TotalSeconds -ge $TimeoutSec) {
					Write-Warning -Message "Wait-OnypheASDTask: timed out after $($TimeoutSec) second(s) waiting for task $($TaskId) to finish - returning the last known Get-OnypheASDTaskList status instead of its (still unfinished) result."
					return $lastList
				}
				Start-Sleep -Seconds $PollIntervalSec
			} while ($true)

			if (-not $finished) {
				Write-Verbose -message "TaskId $($TaskId) was not tracked by Get-OnypheASDTaskList - result may already have been retrieved, or the task ID may be invalid"
			}
			Get-OnypheASDTask -TaskId $TaskId
		}
	}
