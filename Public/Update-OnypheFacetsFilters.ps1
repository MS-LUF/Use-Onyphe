	Function Update-OnypheFacetsFilters {
	<#
	  .SYNOPSIS
	  Update the local Use-Onyphe-Config.json configuration file's cache of available APIs, functions, filters from user API

	  .DESCRIPTION
	  Update the local Use-Onyphe-Config.json configuration file's cache of available APIs, functions, filters from user API

	  .OUTPUTS
		none
		
		.PARAMETER APIKEY
	  -APIKey string{APIKEY}
		Set APIKEY as global variable
		
		.PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe
	  
	  .EXAMPLE
	  Update the local Use-Onyphe-Config.json configuration file's cache of available APIs, functions, filters from user API
	  C:\PS> Update-OnypheFacetsFilters
	#>
	[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
	Param (
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$UseBetaFeatures
	)
	  Process {
			$Config = Read-OnypheConfigFile
			Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			if ($UseBetaFeatures) {
				$params = @{
					UseBetaFeatures = $true
				}
			} else {
				$params = @{}
			}
			write-verbose -Message "generating new facets/filters cache from Onyphe User info"
			$Results = (Get-OnypheUserInfo @params).results | Select-Object -Property apis,filters,functions
			if ($PSCmdlet.ShouldProcess('local configuration file', 'Refresh facets/filters cache')) {
				$Config.DataModel = [PSCustomObject]@{
					apis      = $Results.apis
					filters   = $Results.filters
					functions = $Results.functions
				}
				Save-OnypheConfigFile -Config $Config
				Write-OnypheLog -Config $Config -Level Information -CmdletName $MyInvocation.MyCommand.Name -Message 'facets/filters cache refreshed in local configuration file'
			}
		}
	}
