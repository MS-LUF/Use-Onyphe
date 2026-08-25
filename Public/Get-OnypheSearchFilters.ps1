	Function Get-OnypheSearchFilters {
  <#
		.SYNOPSIS 
		Get filters available for search APIs of Onyphe

		.DESCRIPTION
		Get filters available for search APIs of Onyphe
		
		.OUTPUTS
		filters as string
		
		.EXAMPLE
		Get filters available for search APIs of Onyphe
		C:\PS> Get-OnypheSearchFilters
  #>
	$Config = Read-OnypheConfigFile
	Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
	if ($Config.DataModel -and $Config.DataModel.apis) {
		$SearchFilters = $Config.DataModel
		$SearchFilters.filters
	}
	}
