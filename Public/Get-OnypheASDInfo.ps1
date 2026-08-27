	Function Get-OnypheASDInfo {
	<#
	  .SYNOPSIS
	  main function/cmdlet - Get information from onyphe.io web service using the ASD (Attack Surface Discovery) APIv1

	  .DESCRIPTION
	  main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by ASD API
	  type available. The ASD APIs are BETA endpoints requiring a Griffin View or Griffin View ASM Edition
	  subscription with a non-commercial use licence - see Get-OnypheUserInfo's asd.stdapis property to check
	  whether they are licensed on your account. Only the 9 currently-licensable "standard" ASD APIs (stdapis)
	  are implemented; the "advanced" Pivot Query API (advapis) is not yet implemented in this module.

	  .PARAMETER ASDAPIType
	  -ASDAPIType string {Get-OnypheASDAPIName}
	  ASD API type to use : domaintld, domainwildcard, domaincertso, certsodomain, certsowildcard, dnsdomainns,
	  dnsdomainmx, dnsdomainsoa, dnsdomainexist

	  .PARAMETER Value
	  -Value string[]
	  one or more values to query. For every ASDAPIType except domaincertso this is one or more domains; for
	  domaincertso this is one or more certificate subject.organization values.

	  .PARAMETER IncludePattern
	  -IncludePattern string[]
	  patterns to grep and keep matching results (not supported by ASDAPIType dnsdomainexist)

	  .PARAMETER ExcludePattern
	  -ExcludePattern string[]
	  patterns to grep and exclude from results (not supported by ASDAPIType dnsdomainexist)

	  .PARAMETER Untrusted
	  -Untrusted switch
	  disable Onyphe's backend false-positive filtering, server default is enabled/trusted (not supported by
	  ASDAPIType dnsdomainexist)

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
			  if ($ASDAPIType -eq 'domaincertso') {
				  $params.Certso = $Value
			  } else {
				  $params.Domain = $Value
			  }
			  if ($ASDAPIType -ne 'dnsdomainexist') {
				  if ($IncludePattern) { $params.IncludePattern = $IncludePattern }
				  if ($ExcludePattern) { $params.ExcludePattern = $ExcludePattern }
				  if ($Untrusted) { $params.Untrusted = $true }
			  }
			  if ($AsLines) { $params.AsLines = $true }
			  Write-OnypheLog -Config $Config -Level Information -CmdletName $MyInvocation.MyCommand.Name -Message "Dispatching to $($FunctionName)"
			  & $FunctionName @params
		  }
	}
