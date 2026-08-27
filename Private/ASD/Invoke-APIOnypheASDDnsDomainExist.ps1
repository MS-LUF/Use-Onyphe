	Function Invoke-APIOnypheASDDnsDomainExist {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Dns Domain Exist APIv1

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Dns Domain Exist APIv1 -
	  checks whether the given domain(s) exist, based on passive DNS history and/or live DNS brute-force. BETA
	  endpoint, requires a Griffin View or Griffin View ASM Edition subscription with a non-commercial use
	  licence (see Get-OnypheUserInfo's asd.stdapis property). Unlike the other ASD endpoints this one does not
	  support -IncludePattern/-ExcludePattern/-Untrusted (not documented by Onyphe for this endpoint).

	  .PARAMETER Domain
	  -Domain string[]
	  one or more domains to query

	  .PARAMETER AsLines
	  -AsLines switch
	  render results as one JSON object per line instead of with context (server default is with context)

	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
	  Set APIKEY as global variable

	  .PARAMETER FuncInput
	  -FuncInput hashtable
	  original bound parameters of the calling wrapper, threaded through to the result object's cli-func_input property

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  C:\PS> Invoke-APIOnypheASDDnsDomainExist -Domain onyphe.io
	#>
		[cmdletbinding()]
		Param (
			[parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
				[string[]]$Domain,
			[parameter(Mandatory=$false)]
				[switch]$AsLines,
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$Body = [ordered]@{ domain = $Domain }
			if ($AsLines) { $Body.aslines = $true }
			$params = @{
				request = "v1/asd/dns/domain/exist"
				APIInfo = "asd/dns/domain/exist"
				APIInput = @($Domain)
				APIKeyrequired = $true
				APIVersion = "1"
				Data = $Body | ConvertTo-Json
			}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Write-Verbose -message "POST JSON Data : $($Body | ConvertTo-Json)"
			Invoke-OnypheAPIV2 @params
		}
	}
