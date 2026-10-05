	Function Invoke-APIOnypheASDTaskKill {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to kill/clear an ASD task

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to kill/clear an ASD task by its task ID
	  (v1/asd/task/kill/<id>) - a DELETE request, unlike every other ASD endpoint in this module (all POST or
	  GET). Works on both a still-running task (terminates it) and an already-finished one (clears it from
	  Get-OnypheASDTaskList) - live-tested 2026-09-18 doing the latter, which was necessary to free up this
	  account's single-concurrent-task slot for a new call. Plain DELETE, no request body. BETA endpoint,
	  requires a Griffin View or Griffin View ASM Edition subscription with a non-commercial use licence (see
	  Get-OnypheUserInfo's asd.stdapis property).

	  .PARAMETER TaskId
	  -TaskId string
	  the task ID to kill/clear (returned as .taskid by an ASD call made with astask:true)

	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
	  Set APIKEY as global variable

	  .PARAMETER FuncInput
	  -FuncInput hashtable
	  original bound parameters of the calling wrapper, threaded through to the result object's cli-func_input property

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  C:\PS> Invoke-APIOnypheASDTaskKill -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7"
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
				request = "v1/asd/task/kill/$($TaskId)"
				APIInfo = "asd/task/kill"
				APIInput = @($TaskId)
				APIKeyrequired = $true
				APIVersion = "1"
				Method = "DELETE"
			}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV2 @params
		}
	}
