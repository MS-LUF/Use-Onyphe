	Function Get-OnypheSummaryAPIName {
		<#
		  .SYNOPSIS 
		  Get Summary API available for Onyphe
	  
		  .DESCRIPTION
		  Get Summary API available for Onyphe
		  
		  .OUTPUTS
		  Summary API as string
		  
		  .EXAMPLE
		  Get API available for Onyphe
		  C:\PS> Get-OnypheSummaryAPIName
		#>
		  $Config = Read-OnypheConfigFile
		  Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		  if ($Config.DataModel -and $Config.DataModel.apis) {
				$SearchFilters = $Config.DataModel
				$Apis = @($SearchFilters.apis | Where-Object {($_ -like "summary/*")}) -replace "summary/",""
			  $Apis
		  }
	}
