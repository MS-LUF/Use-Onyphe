#
# Created by: lucas.cueff[at]lucas-cueff.com
#
#'(c) 2018-2026 lucas-cueff.com - Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).'

<#
	.SYNOPSIS 
	commandline interface to use onyphe.io web service

	.DESCRIPTION
	use-onyphe.psm1 module provides a commandline interface to onyphe.io web service.
	
	.EXAMPLE
	C:\PS> import-module use-onyphe.psm1
#>

$script:ModuleRoot = $PSScriptRoot

# Logging severity order, used by Write-OnypheLog to compare a log entry's Level against the
# configured MinimumLevel.
$script:LogLevelSeverity   = @{ Debug = 0; Information = 1; Warning = 2; Error = 3 }
# "Warn once per session" flags so a misconfigured or unreachable logging destination doesn't
# spam Write-Warning on every single log call.
$script:LoggingConfigWarned = $false
$script:LoggingSinkFailed   = $false

foreach ($PrivateFunctionFile in (Get-ChildItem -Path (Join-Path -Path $script:ModuleRoot -ChildPath 'Private') -Filter '*.ps1' -Recurse -ErrorAction SilentlyContinue)) {
	. $PrivateFunctionFile.FullName
}

foreach ($PublicFunctionFile in (Get-ChildItem -Path (Join-Path -Path $script:ModuleRoot -ChildPath 'Public') -Filter '*.ps1' -ErrorAction SilentlyContinue)) {
	. $PublicFunctionFile.FullName
}

	New-Alias -Name Update-OnypheLocalData -Value Update-OnypheFacetsFilters
	New-Alias -Name Get-Onyphe -Value Get-OnypheInfo
	New-Alias -Name Get-OnypheFromCSV -Value Get-OnypheInfoFromCSV
	New-Alias -Name Search-Onyphe -Value Search-OnypheInfo
	New-Alias -Name Get-OnypheAlert -Value Get-OnypheAlertInfo
	New-Alias -Name Set-OnypheAlert -Value Set-OnypheAlertInfo
	New-Alias -Name Export-Onyphe -Value Export-OnypheInfo
	New-Alias -Name Export-OnypheBulkSimple -Value Export-OnypheBulkInfo
	New-Alias -Name Export-OnypheBulkSummary -Value Export-OnypheBulkSummaryInfo
	New-Alias -Name Export-OnypheBulkDiscovery -Value Export-OnypheDiscoveryInfo

	Export-ModuleMember -Function  Get-OnypheUserInfo, Search-OnypheInfo, Get-OnypheInfo, Get-OnypheInfoFromCSV, Export-OnypheInfoToFile, Export-OnypheDataShot,
									Export-OnypheBulkInfo, Export-OnypheBulkSummaryInfo, Export-OnypheInfo, Export-OnypheDiscoveryInfo,
									Get-OnypheSummaryAPIName, Get-OnypheSummary, Get-OnypheSimpleBestAPIName, Get-OnypheBulkCategories, Get-OnypheBulkAPIType, Get-OnypheDiscoveryCategories,
									Get-OnypheSearchFunctions, Get-OnypheSearchCategories, Get-OnypheSearchFilters, Set-OnypheAPIKey, Update-OnypheFacetsFilters, Get-OnypheCliFacets,
									Get-OnypheStatsFromObject, Set-OnypheProxy, Import-OnypheEncryptedIKey, Get-OnypheSimpleAPIName, Get-OnypheAlertInfo, Set-OnypheAlertInfo,
									Get-OnypheASDInfo, Get-OnypheASDAPIName
	Export-ModuleMember -Alias Update-OnypheLocalData, Get-Onyphe, Search-Onyphe, Get-OnypheFromCSV, Get-OnypheAlert, Set-OnypheAlert, Export-Onyphe, Export-OnypheBulkSimple, Export-OnypheBulkSummary, Export-OnypheBulkDiscovery