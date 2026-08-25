	Function Get-OnypheSimpleAPIName {
	<#
	  .SYNOPSIS 
	  Get Simple API available for Onyphe
  
	  .DESCRIPTION
	  Get Simple API available for Onyphe
	  
	  .OUTPUTS
	  Simple API as string
	  
	  .EXAMPLE
	  Get API available for Onyphe
	  C:\PS> Get-OnypheSimpleAPIName
	#>
	  $Config = Read-OnypheConfigFile
	  Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
	  if ($Config.DataModel -and $Config.DataModel.apis) {
			$SearchFilters = $Config.DataModel
			$Apis = @($SearchFilters.apis | Where-Object {($_ -like "simple/*") -and ($_ -notlike "simple/resolver/*") -and ($_ -notlike "simple/datascan/*") -and ($_ -notlike "simple/*/best")}) -replace "simple/",""
			$Apis += ($SearchFilters.apis | Where-Object {$_ -like "simple/resolver/*"}) -replace "simple/resolver/","resolver"
			$Apis += ($SearchFilters.apis | Where-Object {$_ -like "simple/datascan/*"}) -replace "simple/datascan/","datascan"
		  $Apis
	  }
	}
