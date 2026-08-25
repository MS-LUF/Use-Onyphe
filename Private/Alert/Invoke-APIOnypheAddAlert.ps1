	Function Invoke-APIOnypheAddAlert {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-OnypheAPIv2 function and then call it to add new alert for alert/add API
  
	  .DESCRIPTION
	  create several input for Invoke-OnypheAPIv2 function and then call it to add new alert for alert/add API
	  	  
	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
	   Set APIKEY as global variable.
		
	  .PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	   use test.onyphe.io to use new beat features of Onyphe
	  
	  .PARAMETER AlertName
	  -AlertName string
	   Name of the new Onpyhe Alert

	  .PARAMETER AdvancedSearch
	  -AdvancedSearch ARRAY{filter:value,filter:value}
		Search with multiple criterias
		
	  .PARAMETER AdvancedFilter
	  -AdvancedFilter ARRAY{filter:value,filter:value}
	  Filter with multiple criterias

	  .PARAMETER SearchValue
	  -SearchValue STRING{value}
	  string to be searched with -SearchFilter parameter

	  .PARAMETER SearchFilter
	  -SearchFilter STRING{Get-OnypheSearchFilters}
	  Filter to be used with string set with SearchValue parameter

	  .PARAMETER Category
	  -Category STRING{Get-OnypheSearchCategories}
		Search Type or Category
		
	  .PARAMETER FilterFunction
	  -FilterFunction String{Get-OnypheSearchFunctions}
	  Filter search function

	  .PARAMETER FilterValue
	  -FilterValue String
	  value to use as input for FilterFunction

	  .PARAMETER AlertEmail
	  -AlertEmail string
	   Target mail receiving Onyphe Alert

	  .PARAMETER GenerateAlertOutput
	  -GenerateAlertOutput switch
	   Generate A Powershell Object containing the input instead of calling Invoke-OnypheAPIV2 with the inputs

	  .PARAMETER InputAlertObject
	  -InputAlertObject PSObject
	   use PSObject as input with the alert query already defined

	  .OUTPUTS
	  TypeName: PSOnyphe
  
	  .EXAMPLE
	  New alert based on AdvancedSearch with multiple criteria/filters
	  Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
	  C:\PS> Invoke-APIOnypheAddAlert -AlertEmail "alert@example.com" -AlertName "My new Alert" -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan

	  .EXAMPLE
	  New alert based on simple search with one filter/criteria
	  Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	  C:\PS> Invoke-APIOnypheAddAlert -AlertEmail "alert@example.com" -AlertName "My new Alert" -SearchValue RU -SearchType threatlist -SearchFilter country
	#>
	[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
	Param (
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()] 
			[string]$AlertName,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[string]$AlertEmail,
		[parameter(Mandatory=$false)]
		[Alias("Category")]
		[ValidateNotNullOrEmpty()]
			[string]$SearchType,  
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[string]$SearchValue,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[string]$SearchFilter,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[string]$FilterFunction,    
		[parameter(Mandatory=$false)] 
		[ValidateNotNullOrEmpty()]
			[string[]]$FilterValue,
		[parameter(Mandatory=$false)] 
		[ValidateNotNullOrEmpty()]
			[Array]$AdvancedSearch,
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$UseBetaFeatures,
		[parameter(Mandatory=$false)] 
		[ValidateNotNullOrEmpty()]
			[Array]$AdvancedFilter,
		[parameter(mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
	)  
	  Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$APIInput = @()
		if ($AdvancedSearch) {
			$NewAdvancedSearch = $AdvancedSearch.clone()
			for ($i=0; $i -lt $NewAdvancedSearch.length; $i++) {
				$tmp = $null
				$tmp = $NewAdvancedSearch[$i] -split ":"
				if (($tmp[1] -match "\s") -and ($tmp[1] -notlike "`"*`"")) {$tmp[1] = "`"$($tmp[1])`""}
				$NewAdvancedSearch[$i] = $tmp -join ":"
			}
			$NewSearchValue = $NewAdvancedSearch -join " "
			$APIInput += @($NewSearchValue)
		} Elseif ($SearchValue) {
			$NewSearchValue = $SearchValue
			if ($NewSearchValue -match "(\s)"){
				$NewSearchValue = "$($searchfilter):`"$($NewSearchValue)`""
			} else {
				$NewSearchValue = "$($searchfilter):$($NewSearchValue)"
			}
			$APIInput += @($NewSearchValue)
		}
		if ($AdvancedFilter) {
			$NewAdvancedFilter = $AdvancedFilter.clone()
			for ($i=0; $i -lt $NewAdvancedFilter.length; $i++) {
				$tmp = $null
				$tmp = $NewAdvancedFilter[$i] -split ":"
				if (($tmp.Count -gt 1) -and ($tmp[1].contains(","))) {
					$tmp2 = $tmp[1] -split ","
					if (($tmp2[1] -match "\s") -and ($tmp2[1] -notlike "`"*`"")) {$tmp2[1] = "`"$($tmp2[1])`""}
					$tmp[1] = $tmp2 -join ","
				} else {
					if (($tmp[1] -match "\s") -and ($tmp[1] -notlike "`"*`"")) {$tmp[1] = "`"$($tmp[1])`""}
				}
				$tmp[0] = "-" + $tmp[0]
				$NewAdvancedFilter[$i] = $tmp -join ":"
			}
			$NewAdvancedFilter = $NewAdvancedFilter -join " "
			$NewSearchValue = "$($NewSearchValue) $($NewAdvancedFilter)"
			$APIInput += @($NewAdvancedFilter)
		} elseif ($FilterFunction) {
				$NewFilterfunction = $FilterFunction
				$NewSearchValue = "$($NewSearchValue) -$($NewFilterfunction):$($FilterValue -join ",")"
				$APIInput += "-$($NewFilterfunction):$($FilterValue -join ",")"
		}
		$Data = [PSCustomObject]@{
			name = $AlertName
			email = $AlertEmail
			query = "category:$($SearchType)" + " " + $APIInput
		}
		$params = @{
			request = "v2/alert/add/"
			APIInfo = "alert/add"
			APIInput = $Data
			APIKeyrequired = $true
			Data = $Data | ConvertTo-Json
		}
		if ($UseBetaFeatures) {
			$params.add("UseBetaFeatures", $true)
		}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		write-verbose -message "POST JSON Data : $($Data | ConvertTo-Json)"
		Write-Verbose -message "URL Info : $($params.request)"
		if ($PSCmdlet.ShouldProcess($AlertName, 'Create Onyphe alert')) {
			Invoke-OnypheAPIV2 @params
		}
	  }
	}
