	Function Invoke-APIOnypheASDIpCertso {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Ip Certso APIv1

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Ip Certso APIv1 -
	  discovers the IP address(es) belonging to the given certificate subject.organization value(s). Same
	  request body shape as Invoke-APIOnypheASDDomainCertso (a bare "certso" array, not the nested
	  "inventory" object used by the *Inventory wrappers). Live-tested 2026-09-18: "DigiCert Inc" returned
	  6,046 real IPs; "Bleu SAS" and "ONYPHE" both returned error 1006 "search failed: no result found" -
	  same as Invoke-APIOnypheASDDomainCertso does for "ONYPHE" on this account, so this looks like a
	  per-value "no matching data" result rather than an endpoint-level problem (unlike
	  Invoke-APIOnypheASDSubnetInventory, where every domain tried failed the same way). BETA endpoint,
	  requires a Griffin View or Griffin View ASM Edition subscription with a non-commercial use licence (see
	  Get-OnypheUserInfo's asd.stdapis property).

	  .PARAMETER Certso
	  -Certso string[]
	  one or more certificate subject.organization values to query

	  .PARAMETER IncludePattern
	  -IncludePattern string[]
	  patterns to grep and keep matching results

	  .PARAMETER ExcludePattern
	  -ExcludePattern string[]
	  patterns to grep and exclude from results

	  .PARAMETER Untrusted
	  -Untrusted switch
	  disable Onyphe's backend false-positive filtering (server default is enabled/trusted)

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
	  C:\PS> Invoke-APIOnypheASDIpCertso -Certso "DigiCert Inc"
	#>
		[cmdletbinding()]
		Param (
			[parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
				[string[]]$Certso,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[string[]]$IncludePattern,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[string[]]$ExcludePattern,
			[parameter(Mandatory=$false)]
				[switch]$Untrusted,
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
			$Body = [ordered]@{ certso = $Certso }
			if ($IncludePattern) { $Body.includep = $IncludePattern }
			if ($ExcludePattern) { $Body.excludep = $ExcludePattern }
			if ($Untrusted) { $Body.trusted = $false }
			if ($AsLines) { $Body.aslines = $true }
			$params = @{
				request = "v1/asd/ip/certso"
				APIInfo = "asd/ip/certso"
				APIInput = @($Certso)
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
