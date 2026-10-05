	Function Invoke-APIOnypheASDDomainExist {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Domain Exist APIv1

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Domain Exist APIv1 -
	  checks whether the given domain(s) exist, returning {"domain":"...","exist":"true"|"false"} per domain.
	  BETA endpoint, requires a Griffin View or Griffin View ASM Edition subscription with a non-commercial use
	  licence (see Get-OnypheUserInfo's asd.stdapis property). Same bare "domain"-array request body as
	  Invoke-APIOnypheASDDnsDomainExist/Invoke-APIOnypheASDDnsDomainNsExist. Like those sibling endpoints,
	  Onyphe does not document -IncludePattern/-ExcludePattern/-Untrusted for this one either, so they are not
	  exposed here.

	  KNOWN CAVEAT (live-tested 2026-09-19), unlike the other two *Exist endpoints - this one does real,
	  heavier work server-side (likely a much broader dataset than a single passive-DNS/NS-record lookup),
	  which surfaces two behaviors neither dnsdomainexist nor dnsdomainnsexist show: a small domain
	  ("onyphe.io", this project's own "sovcloud-core.fr"/"sovcloud-api.fr"/"neocase-sov.fr") returns a clean
	  "exist":"true"/"false" result synchronously, but a domain with a large enough footprint
	  ("sovcloud-core.fr" and "sovcloud-api.fr" both hit this in testing, alongside "microsoft.com") returns
	  HTTP error 1011 "too many results, you should create a task" instead - same ASD "astask" background-task
	  mode used by Invoke-APIOnypheASDOrgInventory, needing Get-OnypheASDTask/Wait-OnypheASDTask to retrieve
	  the eventual result (confirmed live: "sovcloud-core.fr" via astask eventually returned a normal
	  "exist":"true" record, just not synchronously). A domain that genuinely does not exist
	  ("doesnotexist-abc123xyz.io") returns HTTP error 1006 "search failed: no result found" instead of an
	  "exist":"false" record - the opposite of dnsdomainexist/dnsdomainnsexist's behavior for the same case,
	  where a made-up domain still returns a clean "exist":"false". -AsTask/task-result-retrieval is
	  intentionally not exposed by this wrapper, same reasoning as Invoke-APIOnypheASDOrgInventory.

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
	  C:\PS> Invoke-APIOnypheASDDomainExist -Domain onyphe.io
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
				request = "v1/asd/domain/exist"
				APIInfo = "asd/domain/exist"
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
