	Function Get-OnypheCliFacets {
	<#
	  .SYNOPSIS 
	  Get facets available for stats on local Onyphe PS Object
  
	  .DESCRIPTION
	  Get facets available for stats on local Onyphe PS Object
	  
	  .OUTPUTS
	  facets as string
	  
	  .EXAMPLE
	  Get facets available for stats on local Onyphe PS Object
	  C:\PS> Get-OnypheCliFacets
	#>
	  $Config = Read-OnypheConfigFile
	  Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
	  if ($Config.DataModel -and $Config.DataModel.apis) {
			$SearchFilters = $Config.DataModel
			$SearchFilters.filters
	  }
  	}
