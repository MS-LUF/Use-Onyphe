	Function Get-OnypheBulkAPIType {
		<#
		  .SYNOPSIS 
		  Get Bulk api type available for Onyphe
	  
		  .DESCRIPTION
		  Get Bulk api type available for Onyphe
		  
		  .OUTPUTS
		  Bulk api type as string
		  
		  .EXAMPLE
		  Get Bulk api type available for Onyphe
		  C:\PS> Get-OnypheBulkAPIType
		#>
		  $Config = Read-OnypheConfigFile
		  Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		  if ($Config.DataModel -and $Config.DataModel.apis) {
				$SearchFilters = $Config.DataModel
				$Apis = foreach ($entry in ($SearchFilters.apis -like "bulk*")) {($entry -split "/")[1]}
			  $Apis | get-unique
		  }
	}
