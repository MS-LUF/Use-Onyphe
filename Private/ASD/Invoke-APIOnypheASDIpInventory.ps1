	Function Invoke-APIOnypheASDIpInventory {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Ip Inventory APIv1

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Ip Inventory APIv1 -
	  discovers the IP address(es) belonging to the given domain(s), rolled up as an attack-surface inventory.
	  BETA endpoint, requires a Griffin View or Griffin View ASM Edition subscription with a non-commercial use
	  licence (see Get-OnypheUserInfo's asd.stdapis property). Like Invoke-APIOnypheASDSubnetInventory, the
	  request body nests the input under an "inventory" object (matching the official onyphe/cli's generic
	  inventory-endpoint shape) rather than a bare "domain" key - but unlike that endpoint, this one is
	  confirmed live-working: verified 2026-09-18 returning 519 real IPs for a domain with known infrastructure
	  (cross-checked against independently-gathered resolver/datascan subnet data for the same domain - every
	  returned IP falls inside one of the same subnets). Large domains can time out server-side (error 2,
	  "request timed out") rather than fail outright - this is a server-side computation-time characteristic,
	  not a client-side defect.

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
	  C:\PS> Invoke-APIOnypheASDIpInventory -Domain example.com
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
				request = "v1/asd/ip/inventory"
				APIInfo = "asd/ip/inventory"
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
