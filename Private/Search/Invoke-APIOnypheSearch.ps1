	Function Invoke-APIOnypheSearch {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-OnypheAPIV2 function and then call it to search info from search APIs

	  .DESCRIPTION
	  create several input for Invoke-OnypheAPIV2 function and then call it to to search info from search APIs

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

	  .PARAMETER Page
	  -page string{page number}
	  go directly to a specific result page (1 to 1000)
		
	  .PARAMETER Size
	  -Size int{1 to 10000}
	  number of results per page (server default is 100 when omitted)

	  .PARAMETER TrackQuery
	  -TrackQuery switch
	  ask Onyphe to return, for each result, which OQL filter matched it

	  .PARAMETER Calculated
	  -Calculated switch
	  ask Onyphe to enrich results with computed fields (e.g. defanged/undefanged URL variants)

	  .PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe

	  .OUTPUTS
	     TypeName: PSOnyphe

	  .EXAMPLE
	  AdvancedSearch with multiple criteria/filters
	  Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
	  C:\PS> Invoke-APIOnypheSearch -AdvancedSearch @("product:Apache","port:443","os:Windows") -category datascan

	  .EXAMPLE
	  simple search with one filter/criteria
	  Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	  C:\PS> Invoke-APIOnypheSearch -SearchValue RU -Category threatlist -SearchFilter country

	  .EXAMPLE
	  exclude a filter from the results by prefixing its name with "!" (OQL NOT), and/or OR two filters together by
	  prefixing them with "?" (OQL OR) - both work as plain text inside -AdvancedSearch, no dedicated parameter needed
	  C:\PS> Invoke-APIOnypheSearch -AdvancedSearch @("category:threatlist","!country:RU") -category threatlist
	  C:\PS> Invoke-APIOnypheSearch -AdvancedSearch @("?country:RU","?country:CN") -category threatlist

	  .EXAMPLE
	  OR several wildcard/regexp conditions together by repeating the function once per condition in -AdvancedFilter
	  (this is how Onyphe's OQL itself combines multiple wildcard/regexp conditions - not a single comma-packed call)
	  C:\PS> Invoke-APIOnypheSearch -AdvancedFilter @("orwildcard:domain,g?ogle.com","orwildcard:domain,googl?.com") -category resolver

	  .EXAMPLE
	  limit output fields, request a larger page size, and ask for the matched-filter/calculated-fields metadata
	  C:\PS> Invoke-APIOnypheSearch -SearchValue RU -Category threatlist -SearchFilter country -Size 500 -TrackQuery -Calculated

	  .EXAMPLE
	  OQLv2 condition groups (requires an ASM-level or Ctiscan licence) - pass "(" and ")" as their own
	  -AdvancedSearch array elements, never appended to a filter:value element with a space in the same string
	  C:\PS> Invoke-APIOnypheSearch -AdvancedSearch @("(","?domain:sovcloud-core.fr","?domain:sovcloud-api.fr",")","(","?tld:fr",")") -category resolver
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
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string[]]$Page,
		[parameter(Mandatory=$false)]
		[ValidateRange(1,10000)]
			[int]$Size,
		[parameter(Mandatory=$false)]
			[switch]$TrackQuery,
		[parameter(Mandatory=$false)]
			[switch]$Calculated,
		[parameter(Mandatory=$false)]
			[int]$wait,
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
			request = "v2/search/"
			QueryValue = "category:$($SearchType) $($NewSearchValue)"
			APIInfo = "search/$($SearchType)"
			APIKeyrequired = $true
			APIInput = $APIInput
		}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		if ($page) {
			$params.add('page',$page)
		}
		if ($Size) {
			$params.add('size',$Size)
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
