	Function Stop-OnypheASDTask {
	<#
	  .SYNOPSIS
	  main function/cmdlet - kill/clear an ASD task on onyphe.io web service

	  .DESCRIPTION
	  main function/cmdlet - kill/clear an ASD task on onyphe.io web service using the ASD Task Kill APIv1
	  (v1/asd/task/kill/<id>, an HTTP DELETE request) - works on both a still-running task (terminates it) and
	  an already-finished one (clears it from Get-OnypheASDTaskList, which is necessary on this account before
	  a new ASD *inventory call with astask:true can be made - see Get-OnypheASDTaskList's comment-based help).
	  These are BETA endpoints requiring a Griffin View or Griffin View ASM Edition subscription with a
	  non-commercial use licence - see Get-OnypheUserInfo's asd.stdapis property to check whether they are
	  licensed on your account.

	  .PARAMETER TaskId
	  -TaskId string
	  the task ID to kill/clear

	  .PARAMETER APIKey
	  -APIKey string{APIKEY}
	  set your APIKEY to be able to use Onyphe API.

	  .PARAMETER Wait
	  -Wait int{second}
	  wait for x second before sending the request to manage rate limiting restriction

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  kill/clear an ASD task, prompting for confirmation first
	  C:\PS> Stop-OnypheASDTask -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7"

	  .EXAMPLE
	  kill/clear an ASD task without prompting
	  C:\PS> Stop-OnypheASDTask -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7" -Confirm:$false
	#>
		[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
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
			if ($PSCmdlet.ShouldProcess($TaskId, 'Kill/clear Onyphe ASD task')) {
				Invoke-APIOnypheASDTaskKill -TaskId $TaskId
			}
		}
	}
