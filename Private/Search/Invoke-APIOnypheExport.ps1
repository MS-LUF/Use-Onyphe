	Function Invoke-APIOnypheExport {
		<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to export search info from export API
	
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to export search info from export API
	
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
	
		  .PARAMETER APIKEY
		  -APIKey string{APIKEY}
		  Set APIKEY as global variable
				
		  .PARAMETER TrackQuery
		  -TrackQuery switch
		  ask Onyphe to return, for each result, which OQL filter matched it

		  .PARAMETER Calculated
		  -Calculated switch
		  ask Onyphe to enrich results with computed fields (e.g. defanged/undefanged URL variants)

		  .PARAMETER UseBetaFeatures
		  -UseBetaFeatures switch
		  use test.onyphe.io to use new beat features of Onyphe

		  .PARAMETER OutFile
		  -OutFile string{full path to a new file for exporting json data}
		  full path to output file used to write json data from Onyphe

		  .OUTPUTS
		   TypeName: PSOnyphe

		  .EXAMPLE
		  AdvancedSearch export with multiple criteria/filters
		  export search data with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
		  C:\PS> Invoke-APIOnypheSearch -AdvancedSearch @("product:Apache","port:443","os:Windows") -category datascan

		  .EXAMPLE
		  simple export with one filter/criteria
		  export search data with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
		  C:\PS> Invoke-APIOnypheSearch -SearchValue RU -Category threatlist -SearchFilter country

		  .EXAMPLE
		  exclude a filter from the results by prefixing its name with "!" (OQL NOT), and/or OR two filters together by
		  prefixing them with "?" (OQL OR) - both work as plain text inside -AdvancedSearch, no dedicated parameter needed
		  C:\PS> Invoke-APIOnypheExport -AdvancedSearch @("category:threatlist","!country:RU") -category threatlist -OutFile .\out.json

		  .EXAMPLE
		  OR several wildcard/regexp conditions together by repeating the function once per condition in -AdvancedFilter
		  (this is how Onyphe's OQL itself combines multiple wildcard/regexp conditions - not a single comma-packed call)
		  C:\PS> Invoke-APIOnypheExport -AdvancedFilter @("orwildcard:domain,g?ogle.com","orwildcard:domain,googl?.com") -category resolver -OutFile .\out.json

		  .EXAMPLE
		  ask for the matched-filter/calculated-fields metadata on every exported result
		  C:\PS> Invoke-APIOnypheExport -SearchValue RU -Category threatlist -SearchFilter country -TrackQuery -Calculated -OutFile .\out.json

		  .EXAMPLE
		  OQLv2 condition groups (requires an ASM-level or Ctiscan licence) - pass "(" and ")" as their own
		  -AdvancedSearch array elements, never appended to a filter:value element with a space in the same string
		  C:\PS> Invoke-APIOnypheExport -AdvancedSearch @("(","?domain:sovcloud-core.fr","?domain:sovcloud-api.fr",")","(","?tld:fr",")") -category resolver -OutFile .\out.json
		#>
		[cmdletbinding()]
		param(
			[parameter(Mandatory=$true)]
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
				[int]$wait,
			[parameter(Mandatory=$false)]
				[switch]$TrackQuery,
			[parameter(Mandatory=$false)]
				[switch]$Calculated,
			[parameter(Mandatory=$false)]
				[switch]$UseBetaFeatures,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[Array]$AdvancedFilter,
			[parameter(Mandatory=$false)] 
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput,
			[parameter(Mandatory=$true)]
			[ValidateScript({!(test-path $_)})]
				[string]$OutFile
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
						$tmp2 = $tmp[1] -split ",", 2
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
			$params = @{
				request = "v2/export/"
				QueryValue = "category:$($SearchType) $($NewSearchValue)"
				APIInfo = "export/$($SearchType)"
				APIKeyrequired = $true
				APIInput = $APIInput
				Stream = $true
				OutFile = $OutFile
			}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			if ($TrackQuery) {
				$params.add('TrackQuery', $true)
			}
			if ($Calculated) {
				$params.add('Calculated', $true)
			}
			if ($UseBetaFeatures) {
				$params.add('UseBetaFeatures', $true)
			}
			Write-Verbose -message "URL Info : $($params.request)?q=$($params.QueryValue)"
			Invoke-OnypheAPIV2 @params
		}
	}
