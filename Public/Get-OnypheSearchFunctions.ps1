	Function Get-OnypheSearchFunctions {
		<#
			.SYNOPSIS 
			Get search functions available for search APIs of Onyphe
		
			.DESCRIPTION
			Get search functions available for search APIs of Onyphe (like time filterring etc...)
			
			.OUTPUTS
			functions as string
			
			.EXAMPLE
			Get category available for search APIs of Onyphe
			C:\PS> Get-OnypheSearchFunctions
		#>
			$Config = Read-OnypheConfigFile
			Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
			if ($Config.DataModel -and $Config.DataModel.apis) {
				$SearchFilters = $Config.DataModel
				$SearchFilters.functions
			}
	}
