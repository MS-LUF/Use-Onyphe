	Function Invoke-APIOnypheASDTaskList {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to list all ASD tasks for the account

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to list all ASD tasks for the account
	  (v1/asd/task/list) - currently running or already finished. Live-tested 2026-09-18: each entry is
	  {"taskid": "<guid>", "running": "true"|"false"} - "running":"false" is the reliable signal that a task
	  has finished and its result can be fetched via Get-OnypheASDTask, used internally by Wait-OnypheASDTask
	  for that reason. Returns error 1007 ("task not found: empty list") when there are no tasks at all -
	  treat that as an empty list, not a failure. This account was observed to allow only one task at a time
	  (a second astask:true call while one is still tracked returns error 1008 "creating task failed: a task
	  is already running" - even after the first task finished, until it was explicitly cleared via
	  Stop-OnypheASDTask). Plain GET, no request body, no task ID needed. BETA endpoint, requires a Griffin
	  View or Griffin View ASM Edition subscription with a non-commercial use licence (see
	  Get-OnypheUserInfo's asd.stdapis property).

	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
	  Set APIKEY as global variable

	  .PARAMETER FuncInput
	  -FuncInput hashtable
	  original bound parameters of the calling wrapper, threaded through to the result object's cli-func_input property

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  C:\PS> Invoke-APIOnypheASDTaskList
	#>
		[cmdletbinding()]
		Param (
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
				request = "v1/asd/task/list"
				APIInfo = "asd/task/list"
				APIInput = @("list")
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
