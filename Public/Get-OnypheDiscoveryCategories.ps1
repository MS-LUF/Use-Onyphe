	Function Get-OnypheDiscoveryCategories {
	<#
		  .SYNOPSIS
		  Get Discovery API category available for Onyphe

		  .DESCRIPTION
		  Get Discovery API category available for Onyphe (requires a Griffin View
		  subscription for any category to appear - returns nothing otherwise)

		  .OUTPUTS
		  Discovery category as string

		  .EXAMPLE
		  Get category available for Discovery API of Onyphe
		  C:\PS> Get-OnypheDiscoveryCategories
	#>
		  $Config = Read-OnypheConfigFile
		  Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		  if ($Config.DataModel -and $Config.DataModel.apis) {
				$SearchFilters = $Config.DataModel
				$Apis = foreach ($entry in ($SearchFilters.apis -like "bulk/discovery/*")) {($entry -split "/")[2]}
			  	$Apis | get-unique
		  }
	}
