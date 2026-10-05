	Function Get-OnypheASDTask {
	<#
	  .SYNOPSIS
	  main function/cmdlet - retrieve the final result of an ASD task on onyphe.io web service

	  .DESCRIPTION
	  main function/cmdlet - retrieve the final result of an ASD task on onyphe.io web service using the ASD
	  Task Id APIv1 (v1/asd/task/id/<id>). Any ASD *inventory endpoint (Get-OnypheASDInfo -ASDAPIType
	  orginventory/subnetinventory/ipinventory) can return HTTP error 1011 "too many results, you should
	  create a task" for a large domain instead of its usual results - re-run the same ASD call adding an
	  "astask":"true" field to get a .taskid back instead, then use that task ID here (or with
	  Wait-OnypheASDTask, which polls until the task finishes and calls this automatically). Returns error
	  1009 ("task not finished, no output file") if the task hasn't finished yet. These are BETA endpoints
	  requiring a Griffin View or Griffin View ASM Edition subscription with a non-commercial use licence -
	  see Get-OnypheUserInfo's asd.stdapis property to check whether they are licensed on your account.

	  .PARAMETER TaskId
	  -TaskId string
	  the task ID to retrieve results for

	  .PARAMETER APIKey
	  -APIKey string{APIKEY}
	  set your APIKEY to be able to use Onyphe API.

	  .PARAMETER Wait
	  -Wait int{second}
	  wait for x second before sending the request to manage rate limiting restriction

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  retrieve the final result of a finished ASD task
	  C:\PS> Get-OnypheASDTask -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7"
	#>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
				[string]$TaskId,
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
				[int]$wait
		)
		Process {
			$Config = Read-OnypheConfigFile
			Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
			if ($wait) {start-sleep -s $wait}
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			Invoke-APIOnypheASDTaskId -TaskId $TaskId
		}
	}
