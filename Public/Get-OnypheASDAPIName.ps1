	Function Get-OnypheASDAPIName {
	<#
	  .SYNOPSIS
	  Get ASD API type available for Onyphe

	  .DESCRIPTION
	  Get ASD API type available for Onyphe. Unlike Get-OnypheDiscoveryCategories/Get-OnypheSimpleAPIName, this
	  list cannot be derived from /v2/user's "apis" metadata - the ASD APIs (v1, BETA) do not appear in that
	  array (confirmed against a live Griffin View account), so the 9 currently-implemented standard ASD API
	  (stdapis) type names are hardcoded here instead. Whether they are actually usable on a given account still
	  depends on that account's asd.stdapis licence flag (see Get-OnypheUserInfo) - this function always returns
	  the full list regardless of licensing, the API call itself will fail server-side if unlicensed.

	  .OUTPUTS
	  ASD API type as string

	  .EXAMPLE
	  Get ASD API type available for Onyphe
	  C:\PS> Get-OnypheASDAPIName
	#>
		$Config = Read-OnypheConfigFile
		Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		@('domaintld','domainwildcard','domaincertso','certsodomain','certsowildcard','dnsdomainns','dnsdomainmx','dnsdomainsoa','dnsdomainexist')
	}
