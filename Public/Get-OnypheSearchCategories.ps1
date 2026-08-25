	Function Get-OnypheSearchCategories {
	<#
	  .SYNOPSIS 
	  Get category available for search APIs of Onyphe
  
	  .DESCRIPTION
	  Get category available for search APIs of Onyphe
	  
	  .OUTPUTS
	  filters as string
	  
	  .EXAMPLE
	  Get category available for search APIs of Onyphe
	  C:\PS> Get-OnypheSearchCategories
	#>
	  $Config = Read-OnypheConfigFile
	  Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
	  if ($Config.DataModel -and $Config.DataModel.apis) {
		  $SearchFilters = $Config.DataModel
		  ($SearchFilters.apis | Where-Object {$_ -like "search/*"}) -replace "search/",""
	  }
	}
