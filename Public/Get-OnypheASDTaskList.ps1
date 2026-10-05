	Function Get-OnypheASDTaskList {
	<#
	  .SYNOPSIS
	  main function/cmdlet - list all ASD tasks for the account on onyphe.io web service

	  .DESCRIPTION
	  main function/cmdlet - list all ASD tasks for the account on onyphe.io web service using the ASD Task
	  List APIv1 (v1/asd/task/list) - currently running or already finished. Each entry is
	  {"taskid": "<guid>", "running": "true"|"false"}. Returns error 1007 ("task not found: empty list") when
	  there are no tasks at all - not a failure, just an empty list. Live-tested 2026-09-18: this account
	  allows only one task at a time - a second call to an ASD *inventory endpoint with astask:true while one
	  is already tracked here fails with error 1008 "creating task failed: a task is already running", even
	  after the tracked task has finished, until it is explicitly cleared with Stop-OnypheASDTask. These are
	  BETA endpoints requiring a Griffin View or Griffin View ASM Edition subscription with a non-commercial
	  use licence - see Get-OnypheUserInfo's asd.stdapis property to check whether they are licensed on your
	  account.

	  .PARAMETER APIKey
	  -APIKey string{APIKEY}
	  set your APIKEY to be able to use Onyphe API.

	  .PARAMETER Wait
	  -Wait int{second}
	  wait for x second before sending the request to manage rate limiting restriction

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  list all ASD tasks for the account
	  C:\PS> Get-OnypheASDTaskList
	#>
		[cmdletbinding()]
		Param (
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
			Invoke-APIOnypheASDTaskList
		}
	}
