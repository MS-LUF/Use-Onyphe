	Function Get-OnypheASDAPIName {
	<#
	  .SYNOPSIS
	  Get ASD API type available for Onyphe

	  .DESCRIPTION
	  Get ASD API type available for Onyphe. Unlike Get-OnypheDiscoveryCategories/Get-OnypheSimpleAPIName, this
	  list cannot be derived from /v2/user's "apis" metadata - the ASD APIs (v1, BETA) do not appear in that
	  array (confirmed against a live Griffin View account), so the 21 currently-implemented standard ASD API
	  (stdapis) type names are hardcoded here instead. Whether they are actually usable on a given account still
	  depends on that account's asd.stdapis licence flag (see Get-OnypheUserInfo) - this function always returns
	  the full list regardless of licensing, the API call itself will fail server-side if unlicensed. Note
	  "subnetinventory" is implemented but not yet confirmed to return real data on any tested account (every
	  domain tried returned "no result found") - see Invoke-APIOnypheASDSubnetInventory's comment-based help.
	  "orginventory" returning HTTP error 1011 for a large domain is not a failure - see Get-OnypheASDTask/
	  Wait-OnypheASDTask to retrieve the result via ASD's task/background-task mode. "domainexist" can hit the
	  same HTTP error 1011 for domains with a large enough footprint (unlike its dnsdomainexist/dnsdomainnsexist
	  siblings), and returns HTTP error 1006 rather than an "exist":"false" record for a genuinely
	  non-existent domain - see Invoke-APIOnypheASDDomainExist's comment-based help. "bootstrapcertsowildcard"
	  can also hit HTTP error 1011 for a large certso organization value; live-tested "Bleu SAS" via astask/
	  Wait-OnypheASDTask and found the eventual result was still 0 results, so error 1011's size estimate does
	  not guarantee a large final result set - see Invoke-APIOnypheASDBootstrapCertsoWildcard's comment-based
	  help.

	  .OUTPUTS
	  ASD API type as string

	  .EXAMPLE
	  Get ASD API type available for Onyphe
	  C:\PS> Get-OnypheASDAPIName
	#>
		$Config = Read-OnypheConfigFile
		Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		@('domaintld','domainwildcard','domaincertso','certsodomain','certsowildcard','dnsdomainns','dnsdomainmx','dnsdomainsoa','dnsdomainexist','subnetinventory','ipinventory','orginventory','ipcertso','ipdomain','vhostinventory','scoreinventory','dnsdomainmstenantid','dnsdomainnsexist','domainexist','websubdomaindomain','bootstrapcertsowildcard')
	}
