	Function Invoke-APIOnypheASDTaskPoll {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to check the live progress of an ASD task

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to check the live progress of an ASD task
	  by its task ID (v1/asd/task/poll/<id>). Live-tested 2026-09-18: while a task is running, returns a
	  results array of rolling numeric progress ticks (e.g. [{"value":123},{"value":34},...]) - not a clean
	  boolean "done" flag, and the shape does not visibly change once the task finishes (still the same
	  value-array shape after completion, confirmed by polling past the point Get-OnypheASDTaskList reported
	  running:false for the same task). Because of this, Wait-OnypheASDTask does not rely on this endpoint's
	  own output to detect completion - it cross-checks Get-OnypheASDTaskList's per-task "running" flag
	  instead, and only uses this endpoint to surface progress information. Plain GET, no request body. BETA
	  endpoint, requires a Griffin View or Griffin View ASM Edition subscription with a non-commercial use
	  licence (see Get-OnypheUserInfo's asd.stdapis property).

	  .PARAMETER TaskId
	  -TaskId string
	  the task ID to check progress for (returned as .taskid by an ASD call made with astask:true)

	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
	  Set APIKEY as global variable

	  .PARAMETER FuncInput
	  -FuncInput hashtable
	  original bound parameters of the calling wrapper, threaded through to the result object's cli-func_input property

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  C:\PS> Invoke-APIOnypheASDTaskPoll -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7"
	#>
		[cmdletbinding()]
		Param (
			[parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
				[string]$TaskId,
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "v1/asd/task/poll/$($TaskId)"
				APIInfo = "asd/task/poll"
				APIInput = @($TaskId)
				APIKeyrequired = $true
				APIVersion = "1"
			}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV2 @params
		}
	}
