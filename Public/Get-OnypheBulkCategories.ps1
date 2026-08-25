	Function Get-OnypheBulkCategories {
		<#
		  .SYNOPSIS 
		  Get Bulk category available for Onyphe
	  
		  .DESCRIPTION
		  Get Bulk category available for Onyphe
		  
		  .OUTPUTS
		  Bulk category as string
		  
		  .EXAMPLE
		  Get Bulk category available for Onyphe
		  C:\PS> Get-OnypheBulkCategories
		#>
		  $Config = Read-OnypheConfigFile
		  Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		  if ($Config.DataModel -and $Config.DataModel.apis) {
				$SearchFilters = $Config.DataModel
				$Apis = foreach ($entry in ($SearchFilters.apis -like "bulk/simple/*")) {($entry -split "/")[2]}
			  	$Apis | get-unique
		  }
	}
