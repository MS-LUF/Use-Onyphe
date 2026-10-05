	Function Invoke-APIOnypheASDSubnetInventory {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Subnet Inventory APIv1

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Subnet Inventory APIv1 -
	  discovers the subnet(s) belonging to the given domain(s), rolled up as an attack-surface inventory. BETA
	  endpoint, requires a Griffin View or Griffin View ASM Edition subscription with a non-commercial use
	  licence (see Get-OnypheUserInfo's asd.stdapis property). Unlike the other ASD endpoints, the request body
	  nests the input under an "inventory" object (matching the official onyphe/cli's generic
	  inventory-endpoint shape) rather than a bare "domain" key.

	  KNOWN CAVEAT (live-tested 2026-09-18): the request itself is confirmed correct - it reaches the server
	  and gets back a genuine business-logic response (HTTP 400, error 1006 "search failed: no result found"),
	  not an auth/licensing/malformed-body error - but this response was returned for every domain tried on
	  the verification account, including large well-known domains (microsoft.com, google.com) that
	  Get-OnypheASDInfo -ASDAPIType domaintld succeeds against on the same account/call. Tried with and
	  without -Untrusted and with multiple domains at once; same result every time. Root cause not confirmed -
	  possibly this endpoint needs an entitlement beyond plain asd.stdapis (e.g. the separate, unlicensed-on-
	  this-account ASM product, given the naming overlap with "inventory"), or needs a richer multi-field
	  inventory input (asn/ip alongside domain) than a domain-only list provides. Implemented and tested at the
	  request-shape level; not yet confirmed to return real data end-to-end.

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
	  C:\PS> Invoke-APIOnypheASDSubnetInventory -Domain example.com
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
				request = "v1/asd/subnet/inventory"
				APIInfo = "asd/subnet/inventory"
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
