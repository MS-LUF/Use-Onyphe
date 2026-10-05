	Function Invoke-APIOnypheASDOrgInventory {
	<#
	  .SYNOPSIS
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Org Inventory APIv1

	  .DESCRIPTION
	  create input for Invoke-OnypheAPIV2 function and then call it to query the ASD Org Inventory APIv1 -
	  discovers the organization(s) associated with the given domain(s), rolled up as an attack-surface
	  inventory. BETA endpoint, requires a Griffin View or Griffin View ASM Edition subscription with a
	  non-commercial use licence (see Get-OnypheUserInfo's asd.stdapis property). Like the other *Inventory
	  wrappers, the request body nests the input under an "inventory" object rather than a bare "domain" key.

	  KNOWN LIMITATION (live-tested 2026-09-18): unlike Invoke-APIOnypheASDIpInventory, this endpoint is only
	  reliably usable synchronously for domains with a small enough org-linked footprint. Large, well-known
	  domains (google.com, github.com) return HTTP error 1011 "too many results, you should create a task"
	  along with the real total (308,407 and 2,620,852 respectively) - i.e. the server refuses to return that
	  much data synchronously and expects the caller to use the "astask" background-task mode instead, polled
	  via the separate ASD task-management endpoints (asd/task/id, /poll, /list, /kill). Small domains tested (this project's own
	  sovcloud-*.fr family) all returned a clean "success" with 0 results (no error, genuinely no org-inventory
	  data at that scale) rather than the 1011/1006 error codes - so this endpoint IS reachable and functioning
	  correctly, but is not yet fully useful for any domain large enough to have real data without also
	  implementing task polling. -AsTask/task-result-retrieval is intentionally not exposed by this wrapper for
	  the same reason it wasn't exposed by the original v2.2.0 ASD integration - see README.md's v2.2.0 notes.

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
	  C:\PS> Invoke-APIOnypheASDOrgInventory -Domain example.com
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
				request = "v1/asd/org/inventory"
				APIInfo = "asd/org/inventory"
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
