	Function Invoke-APIOnypheASDTaskId {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to retrieve the final result of an ASD task

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to retrieve the final result of an ASD task
	  by its task ID (v1/asd/task/id/<id>) - the result of any ASD *inventory endpoint called with the
	  server-side "astask" flag set (see Invoke-APIOnypheASDOrgInventory's comment-based help for an example of
	  when a task is required). Returns error 1009 ("task not finished, no output file") if the task is still
	  running - use Wait-OnypheASDTask to block until it completes instead of polling this directly. Plain GET,
	  no request body. BETA endpoint, requires a Griffin View or Griffin View ASM Edition subscription with a
	  non-commercial use licence (see Get-OnypheUserInfo's asd.stdapis property).

	  .PARAMETER TaskId
	  -TaskId string
	  the task ID to retrieve results for (returned as .taskid by an ASD call made with astask:true)

	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
	  Set APIKEY as global variable

	  .PARAMETER FuncInput
	  -FuncInput hashtable
	  original bound parameters of the calling wrapper, threaded through to the result object's cli-func_input property

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  C:\PS> Invoke-APIOnypheASDTaskId -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7"
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
				request = "v1/asd/task/id/$($TaskId)"
				APIInfo = "asd/task/id"
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
