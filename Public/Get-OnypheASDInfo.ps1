	Function Get-OnypheASDInfo {
	<#
	  .SYNOPSIS
	  main function/cmdlet - Get information from onyphe.io web service using the ASD (Attack Surface Discovery) APIv1

	  .DESCRIPTION
	  main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by ASD API
	  type available. The ASD APIs are BETA endpoints requiring a Griffin View or Griffin View ASM Edition
	  subscription with a non-commercial use licence - see Get-OnypheUserInfo's asd.stdapis property to check
	  whether they are licensed on your account. Only 21 of the ~21-22 "standard" ASD APIs (stdapis) documented by
	  the official onyphe/cli are implemented so far; the "advanced" Pivot Query API (advapis) and the
	  remaining stdapis inventory/existence-check endpoints are not yet implemented in this module. ASD task
	  management (for results too large to return synchronously) is implemented separately - see
	  Get-OnypheASDTask/Get-OnypheASDTaskList/Wait-OnypheASDTask/Stop-OnypheASDTask.

	  .PARAMETER ASDAPIType
	  -ASDAPIType string {Get-OnypheASDAPIName}
	  ASD API type to use : domaintld, domainwildcard, domaincertso, certsodomain, certsowildcard, dnsdomainns,
	  dnsdomainmx, dnsdomainsoa, dnsdomainexist, subnetinventory, ipinventory, orginventory, ipcertso, ipdomain,
	  vhostinventory, scoreinventory, dnsdomainmstenantid, dnsdomainnsexist, domainexist, websubdomaindomain,
	  bootstrapcertsowildcard

	  .PARAMETER Value
	  -Value string[]
	  one or more values to query. For domaincertso, ipcertso and bootstrapcertsowildcard this is one or more
	  certificate subject.organization values; for subnetinventory/ipinventory/orginventory/vhostinventory/
	  scoreinventory, the domain(s) are wrapped
	  server-side into an inventory rollup rather than queried individually; for every other ASDAPIType this
	  is one or more domains.

	  .PARAMETER IncludePattern
	  -IncludePattern string[]
	  patterns to grep and keep matching results (not supported by ASDAPIType dnsdomainexist, dnsdomainnsexist,
	  domainexist)

	  .PARAMETER ExcludePattern
	  -ExcludePattern string[]
	  patterns to grep and exclude from results (not supported by ASDAPIType dnsdomainexist, dnsdomainnsexist,
	  domainexist)

	  .PARAMETER Untrusted
	  -Untrusted switch
	  disable Onyphe's backend false-positive filtering, server default is enabled/trusted (not supported by
	  ASDAPIType dnsdomainexist, dnsdomainnsexist, domainexist)

	  .PARAMETER AsLines
	  -AsLines switch
	  render results as one JSON object per line instead of with context (server default is with context)

	  .PARAMETER APIKey
	  -APIKey string{APIKEY}
	  set your APIKEY to be able to use Onyphe API.

	  .PARAMETER Wait
	  -Wait int{second}
	  wait for x second before sending the request to manage rate limiting restriction

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  discover related domains across TLDs for example.com
	  C:\PS> Get-OnypheASDInfo -ASDAPIType domaintld -Value example.com

	  .EXAMPLE
	  discover certificate subject.organization value(s) linked to a domain
	  C:\PS> Get-OnypheASDInfo -ASDAPIType certsodomain -Value example.com

	  .EXAMPLE
	  discover domain(s) linked to a certificate subject.organization value, disabling backend false-positive filtering
	  C:\PS> Get-OnypheASDInfo -ASDAPIType domaincertso -Value "Example Organization" -Untrusted

	  .EXAMPLE
	  check whether one or more domains exist (passive DNS history / live brute-force)
	  C:\PS> Get-OnypheASDInfo -ASDAPIType dnsdomainexist -Value @("example.com","example.org")

	  .EXAMPLE
	  discover the subnet(s) belonging to one or more domains, as an attack-surface inventory rollup
	  C:\PS> Get-OnypheASDInfo -ASDAPIType subnetinventory -Value example.com

	  .EXAMPLE
	  discover the IP address(es) belonging to one or more domains, as an attack-surface inventory rollup
	  C:\PS> Get-OnypheASDInfo -ASDAPIType ipinventory -Value example.com

	  .EXAMPLE
	  discover the organization(s) associated with one or more domains, as an attack-surface inventory rollup
	  C:\PS> Get-OnypheASDInfo -ASDAPIType orginventory -Value example.com

	  .EXAMPLE
	  discover the IP address(es) belonging to a certificate subject.organization value
	  C:\PS> Get-OnypheASDInfo -ASDAPIType ipcertso -Value "Example Organization"

	  .EXAMPLE
	  discover the IP address(es) belonging to one or more domains
	  C:\PS> Get-OnypheASDInfo -ASDAPIType ipdomain -Value example.com

	  .EXAMPLE
	  discover the virtual host(s)/forward DNS hostname(s) belonging to one or more domains
	  C:\PS> Get-OnypheASDInfo -ASDAPIType vhostinventory -Value example.com

	  .EXAMPLE
	  discover risk-flagged findings for one or more domains, as an attack-surface inventory rollup
	  C:\PS> Get-OnypheASDInfo -ASDAPIType scoreinventory -Value example.com

	  .EXAMPLE
	  discover other domain(s) sharing the same Microsoft 365 tenant as one or more domains (a live DNS lookup)
	  C:\PS> Get-OnypheASDInfo -ASDAPIType dnsdomainmstenantid -Value example.com

	  .EXAMPLE
	  check whether one or more domains have an existing NS record (a live DNS lookup)
	  C:\PS> Get-OnypheASDInfo -ASDAPIType dnsdomainnsexist -Value @("example.com","example.org")

	  .EXAMPLE
	  check whether one or more domains exist - can return HTTP error 1011 "too many results, you should create a task" for domains with a large enough footprint, see Get-OnypheASDTask/Wait-OnypheASDTask
	  C:\PS> Get-OnypheASDInfo -ASDAPIType domainexist -Value @("example.com","example.org")

	  .EXAMPLE
	  discover subdomain(s)/hostname(s) for one or more domains from web crawl data
	  C:\PS> Get-OnypheASDInfo -ASDAPIType websubdomaindomain -Value example.com

	  .EXAMPLE
	  seed a wildcard-domain search from a certificate subject.organization value - can return HTTP error 1011 "too many results, you should create a task" for a large organization, see Get-OnypheASDTask/Wait-OnypheASDTask
	  C:\PS> Get-OnypheASDInfo -ASDAPIType bootstrapcertsowildcard -Value "Example Organization"
	#>
		[cmdletbinding()]
		Param (
		  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		  [ValidateNotNullOrEmpty()]
			  [string[]]$Value,
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
			  [int]$wait
		  )
		  DynamicParam
		  {
			  $ParameterNameType = 'ASDAPIType'
			  $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
			  $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
			  $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
			  $ParameterAttribute.ValueFromPipeline = $false
			  $ParameterAttribute.ValueFromPipelineByPropertyName = $false
			  $ParameterAttribute.Mandatory = $true
			  $ParameterAttribute.Position = 2
			  $AttributeCollection.Add($ParameterAttribute)
			  $arrSet = Get-OnypheASDAPIName
			  if ($arrSet) {
				  $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
				  $AttributeCollection.Add($ValidateSetAttribute)
			  }
			  $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
			  $RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
			  return $RuntimeParameterDictionary
		  }
		  Process {
			  $Config = Read-OnypheConfigFile
			  Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
			  $ASDAPIType = $PsBoundParameters[$ParameterNameType]
			  if ($wait) {start-sleep -s $wait}
			  if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			  $FunctionName = "Invoke-APIOnypheASD$($ASDAPIType)"
			  if (-not (Get-Command -Name $FunctionName -CommandType Function -ErrorAction SilentlyContinue)) {
				  throw "ASD API $($ASDAPIType) not implemented yet in this version of Use-Onyphe pwsh module"
			  }
			  $params = @{}
			  if ($ASDAPIType -in @('domaincertso','ipcertso','bootstrapcertsowildcard')) {
				  $params.Certso = $Value
			  } else {
				  $params.Domain = $Value
			  }
			  if ($ASDAPIType -notin @('dnsdomainexist','dnsdomainnsexist','domainexist')) {
				  if ($IncludePattern) { $params.IncludePattern = $IncludePattern }
				  if ($ExcludePattern) { $params.ExcludePattern = $ExcludePattern }
				  if ($Untrusted) { $params.Untrusted = $true }
			  }
			  if ($AsLines) { $params.AsLines = $true }
			  Write-OnypheLog -Config $Config -Level Information -CmdletName $MyInvocation.MyCommand.Name -Message "Dispatching to $($FunctionName)"
			  & $FunctionName @params
		  }
	}
