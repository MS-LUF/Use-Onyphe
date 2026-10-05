	Function Invoke-APIOnypheASDWebSubdomainDomain {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Web Subdomain Domain APIv1

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Web Subdomain Domain APIv1
	  - discovers subdomain(s)/hostname(s) for the given domain(s) from web crawl data, returning a mix of
	  {"hostname":"..."} entries and a trailing {"domain":"..."} echo of the query itself. BETA endpoint,
	  requires a Griffin View or Griffin View ASM Edition subscription with a non-commercial use licence (see
	  Get-OnypheUserInfo's asd.stdapis property).

	  Live-tested 2026-09-19: "onyphe.io" returned 5 results (blog.onyphe.io, www.onyphe.io, search.onyphe.io,
	  onyphe.io, plus the domain echo); "sovcloud-core.fr" returned 8 real internal-looking hostnames (e.g.
	  cspv2.sovcloud-core.fr); "sovcloud-api.fr" returned 38; "neocase-sov.fr" returned 3. Unlike the ASD
	  "*Exist" endpoints, -IncludePattern/-ExcludePattern/-Untrusted genuinely filter server-side here (verified
	  live: -ExcludePattern "blog" against "onyphe.io" dropped "blog.onyphe.io" from the result set, going from
	  5 to 3 results). A domain with a large enough footprint ("microsoft.com" in testing) can time out
	  server-side (HTTP error 2 "request timed out") rather than fail outright, the same characteristic already
	  seen on Invoke-APIOnypheASDIpInventory - not an "astask"/task-mode situation like
	  Invoke-APIOnypheASDOrgInventory/Invoke-APIOnypheASDDomainExist, just a computation-time limit. A
	  genuinely non-existent domain returns HTTP error 1006 "search failed: no result found".

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
	  C:\PS> Invoke-APIOnypheASDWebSubdomainDomain -Domain example.com
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
			$Body = [ordered]@{ domain = $Domain }
			if ($IncludePattern) { $Body.includep = $IncludePattern }
			if ($ExcludePattern) { $Body.excludep = $ExcludePattern }
			if ($Untrusted) { $Body.trusted = $false }
			if ($AsLines) { $Body.aslines = $true }
			$params = @{
				request = "v1/asd/web/subdomain/domain"
				APIInfo = "asd/web/subdomain/domain"
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
