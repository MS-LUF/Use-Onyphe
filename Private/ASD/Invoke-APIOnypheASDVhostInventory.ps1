	Function Invoke-APIOnypheASDVhostInventory {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Vhost Inventory APIv1

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Vhost Inventory APIv1 -
	  discovers the virtual host(s)/forward DNS hostname(s) belonging to the given domain(s), rolled up as an
	  attack-surface inventory. Same nested "inventory" request body shape as
	  Invoke-APIOnypheASDSubnetInventory/IpInventory/OrgInventory. Live-tested 2026-09-19: "sovcloud-core.fr"
	  returned 21 real forward hostnames (e.g. "mysignins.identity.sovcloud.fr"); "google.com" returned 1,338
	  results synchronously with no size-ceiling error - unlike Invoke-APIOnypheASDOrgInventory, this endpoint
	  did not hit HTTP error 1011 on a large domain in testing, so the astask/Wait-OnypheASDTask workaround is
	  likely unnecessary for typical use (though a large enough domain could still hit it - not exhaustively
	  tested). "onyphe.io" returned error 1006 "search failed: no result found", the same per-value data gap
	  already seen on other ASD endpoints for that value. BETA endpoint, requires a Griffin View or Griffin
	  View ASM Edition subscription with a non-commercial use licence (see Get-OnypheUserInfo's asd.stdapis
	  property).

	  .PARAMETER Domain
	  -Domain string[]
	  one or more domains to query

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
	  C:\PS> Invoke-APIOnypheASDVhostInventory -Domain example.com
	#>
		[cmdletbinding()]
		Param (
			[parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
				[string[]]$Domain,
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
			$Body = [ordered]@{ inventory = [ordered]@{ domain = $Domain } }
			if ($IncludePattern) { $Body.includep = $IncludePattern }
			if ($ExcludePattern) { $Body.excludep = $ExcludePattern }
			if ($Untrusted) { $Body.trusted = $false }
			if ($AsLines) { $Body.aslines = $true }
			$params = @{
				request = "v1/asd/vhost/inventory"
				APIInfo = "asd/vhost/inventory"
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
