	Function Get-OnypheUserInfo {
	<#
	 .SYNOPSIS 
	 main function/cmdlet - Get user account information (rate limiting status, requests remaining in pool...) from onyphe.io web service
 
	 .DESCRIPTION
	 main function/cmdlet - Get user account information (rate limiting status, requests remaining in pool...) from onyphe.io web service
	 send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
 	 
	 .PARAMETER APIKey
	 -APIKey string{APIKEY}
	 set your APIKEY to be able to use Onyphe API.

	 .PARAMETER UseBetaFeatures
	 -UseBetaFeatures switch
	 use test.onyphe.io to use new beat features of Onyphe

     .PARAMETER Wait
	 -Wait int{second}
	 wait for x second before sending the request to manage rate limiting restriction
	 
	 .OUTPUTS
	 TypeName: System.Management.Automation.PSCustomObject
	 
	.EXAMPLE
	get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx and set the api key
	C:\PS> Get-OnypheUserInfo -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	.EXAMPLE
	get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx already set as global variable
	C:\PS> Get-OnypheUserInfo
 #>
   [cmdletbinding()]
   Param (
	[parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
		[string]$APIKey,
	[parameter(Mandatory=$false)]
		[int]$wait,
	[parameter(Mandatory=$false)]
		[switch]$UseBetaFeatures
   )
	process {
		$Config = Read-OnypheConfigFile
		Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		if ($wait) {start-sleep -s $wait}
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		if ($UseBetaFeatures) {
			$params = @{
				UseBetaFeatures = $true
			}
		}
		if ($params) {
			Invoke-APIOnypheUser @params
		} else {
			Invoke-APIOnypheUser
		}
	}
	}
