	Function Search-OnypheInfo {
	<#
	 .SYNOPSIS 
	 main function/cmdlet - Search for IP information on onyphe.io web service using search API
 
	 .DESCRIPTION
	 main function/cmdlet - Search for IP information on onyphe.io web service using search API
	 send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
 
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
	 
	 .PARAMETER APIKey
	 -APIKey string{APIKEY}
	 set your APIKEY to be able to use Onyphe API.
 
	 .PARAMETER Page
	 -page string{page number}
	 go directly to a specific result page (1 to 1000)
	 you can set a list of page using x-y like 1-100 to read the first 100 pages

	 .PARAMETER Size
	 -Size int{1 to 10000}
	 number of results per page (server default is 100 when omitted)

	 .PARAMETER TrackQuery
	 -TrackQuery switch
	 ask Onyphe to return, for each result, which OQL filter matched it

	 .PARAMETER Calculated
	 -Calculated switch
	 ask Onyphe to enrich results with computed fields (e.g. defanged/undefanged URL variants)

	 .PARAMETER Wait
	 -Wait int{second}
	 wait for x second before sending the request to manage rate limiting restriction

	 .PARAMETER UseBetaFeatures
	 -UseBetaFeatures switch
	 use test.onyphe.io to use new beat features of Onyphe
	 
	 .OUTPUTS
	 TypeName: System.Management.Automation.PSCustomObject
		 
	 .EXAMPLE
	 AdvancedSearch with multiple criteria/filters
	 Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
	 C:\PS> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan
 
	 .EXAMPLE
	 simple search with one filter/criteria
	 Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	 C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country
 
	 .EXAMPLE
	 AdvancedSearch with multiple criteria/filters and set the API key
	 Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
	 C:\PS> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	 
	 .EXAMPLE
	 simple search with one filter/criteria and request page 2 of the results
	 Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	 C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -page "2"

	 .EXAMPLE
	 simple search with one filter/criteria and use a server filter to retrieve only objects indexed since 2 month
	 Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	 C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction monthago -FilterValue "2"

	.EXAMPLE
	 filter the result and show me only the answer with os property not null for threatlist category for all Russia
	 C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction exist -FilterValue os

	 .EXAMPLE
     filter the results using multiple filters (only os property known and from all organization like *company*) for tcp port 3389 opened in russia
	 C:\PS> search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan

	 .EXAMPLE
	 exclude a filter from the results by prefixing its name with "!" (OQL NOT), and/or OR two filters together by
	 prefixing them with "?" (OQL OR) - both work as plain text inside -AdvancedSearch, no dedicated parameter needed
	 C:\PS> Search-OnypheInfo -AdvancedSearch @("category:threatlist","!country:RU") -category threatlist
	 C:\PS> Search-OnypheInfo -AdvancedSearch @("?country:RU","?country:CN") -category threatlist

	 .EXAMPLE
	 OR several wildcard/regexp conditions together by repeating the function once per condition in -AdvancedFilter
	 (this is how Onyphe's OQL itself combines multiple wildcard/regexp conditions - not a single comma-packed call)
	 C:\PS> Search-OnypheInfo -AdvancedFilter @("orwildcard:domain,g?ogle.com","orwildcard:domain,googl?.com") -Category resolver

	 .EXAMPLE
	 limit output fields, request a larger page size, and ask for the matched-filter/calculated-fields metadata
	 C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -Size 500 -TrackQuery -Calculated

	 .EXAMPLE
	 OQLv2 condition groups (requires an ASM-level or Ctiscan licence - check Get-OnypheUserInfo's oqlversion property)
	 group conditions with parentheses to AND two independent OR-groups together; pass "(" and ")" as their own
	 -AdvancedSearch array elements, never appended to a filter:value element with a space in the same string - the
	 module's multi-word auto-quoting will otherwise swallow the closing paren into the previous value and produce
	 an OQL syntax error server-side
	 C:\PS> Search-OnypheInfo -AdvancedSearch @("(","?domain:sovcloud-core.fr","?domain:sovcloud-api.fr",")","(","?tld:fr",")") -Category resolver
 #>
	 [cmdletbinding()]
	 param(
		 [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false,Position=2)]
		 [ValidateNotNullOrEmpty()]  
		 	[string]$SearchValue,
		 [parameter(Mandatory=$false,Position=5)] 
		 [ValidateNotNullOrEmpty()]
		 	[string[]]$FilterValue,
		 [parameter(Mandatory=$false,Position=6)] 
		 [ValidateNotNullOrEmpty()]
		 	[Array]$AdvancedSearch,
		 [parameter(Mandatory=$false,Position=8)]
		 [ValidateLength(40,40)]
		 	[string]$APIKey,
		 [parameter(Mandatory=$false,Position=9)]
		 [ValidateScript({($_ -match "^((?!0)\d+)$") -or ($_ -match "^((?!0)\d+)(-)((?!0)\d+)$")})]
		 	[string[]]$Page,
		 [parameter(Mandatory=$false,Position=7)]
		 	[int]$wait,
		 [parameter(Mandatory=$false,Position=10)]
		 	[switch]$UseBetaFeatures,
		 [parameter(Mandatory=$false,Position=11)]
		 [ValidateNotNullOrEmpty()]
		 	[Array]$AdvancedFilter,
		 [parameter(Mandatory=$false,Position=12)]
		 [ValidateRange(1,10000)]
		 	[int]$Size,
		 [parameter(Mandatory=$false,Position=13)]
		 	[switch]$TrackQuery,
		 [parameter(Mandatory=$false,Position=14)]
		 	[switch]$Calculated
	 )
	 DynamicParam
	 {
		 $ParameterNameType = 'SearchType'
		 $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		 $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		 $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
		 $ParameterAttribute.ValueFromPipeline = $false
		 $ParameterAttribute.ValueFromPipelineByPropertyName = $false
		 $ParameterAttribute.Mandatory = $true
		 $ParameterAttribute.Position = 1
		 $AttributeCollection.Add($ParameterAttribute)
		 $arrSet = Get-OnypheSearchCategories
		 if ($arrSet) {
		 	$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		 	$AttributeCollection.Add($ValidateSetAttribute)
		 }
		 $ParameterNameAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList @("Category")
		 $AttributeCollection.Add($ParameterNameAlias)
		 $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
		 $RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
		 
		 $ParameterNameFilter = 'SearchFilter'
		 $AttributeCollection2 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		 $ParameterAttribute2 = New-Object System.Management.Automation.ParameterAttribute
		 $ParameterAttribute2.ValueFromPipeline = $false
		 $ParameterAttribute2.ValueFromPipelineByPropertyName = $false
		 $ParameterAttribute2.Mandatory = $false
		 $ParameterAttribute2.Position = 3
		 $AttributeCollection2.Add($ParameterAttribute2)
		 $arrSet =  Get-OnypheSearchFilters
		 if ($arrSet) {
		 	$ValidateSetAttribute2 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		 	$AttributeCollection2.Add($ValidateSetAttribute2)
		 }
		 $RuntimeParameter2 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFilter, [string], $AttributeCollection2)
		 $RuntimeParameterDictionary.Add($ParameterNameFilter, $RuntimeParameter2)

		 $ParameterNameFunction = 'FilterFunction'
		 $AttributeCollection3 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		 $ParameterAttribute3 = New-Object System.Management.Automation.ParameterAttribute
		 $ParameterAttribute3.ValueFromPipeline = $false
		 $ParameterAttribute3.ValueFromPipelineByPropertyName = $false
		 $ParameterAttribute3.Mandatory = $false
		 $ParameterAttribute3.Position = 4
		 $AttributeCollection3.Add($ParameterAttribute3)
		 $arrSet =  Get-OnypheSearchFunctions
		 if ($arrSet) {
		 	$ValidateSetAttribute3 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		 	$AttributeCollection3.Add($ValidateSetAttribute3)
		 }
		 $RuntimeParameter3 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFunction, [string], $AttributeCollection3)
		 $RuntimeParameterDictionary.Add($ParameterNameFunction, $RuntimeParameter3)
		 
		 return $RuntimeParameterDictionary
	}
	Process {
		$Config = Read-OnypheConfigFile
		Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		$SearchType = $PsBoundParameters[$ParameterNameType]
		$SearchFilter = $PsBoundParameters[$ParameterNameFilter]
		$SearchFunction = $PsBoundParameters[$ParameterNameFunction]
		$params = @{
			SearchType = $SearchType
			FuncInput = $PsBoundParameters
		}
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		if ($wait) {start-sleep -s $wait}
		if ($SearchFilter -and !($SearchValue)) {
			throw "please use the SearchValue parameter when using SearchFilter parameter or used AdvancedSearch instead"
		}
		if ($SearchFunction -and !($FilterValue)) {
			throw "please use the FilterValue parameter when using FilterFunction parameter"
		}
		if ($AdvancedSearch) {
			 $params.add('AdvancedSearch',$AdvancedSearch)
		} elseif ($SearchValue) {
			$params.add('SearchValue',$SearchValue)
			$params.add('SearchFilter',$SearchFilter)
		}
		if ($AdvancedFilter) {
			$params.add('AdvancedFilter',$AdvancedFilter)
		} elseif ($SearchFunction) {
			$params.add('FilterFunction', $SearchFunction)
			$params.add('FilterValue',$FilterValue)
		}
		if ($UseBetaFeatures) {
			$params.add('UseBetaFeatures', $true)
		}
		if ($Size) {
			$params.add('Size', $Size)
		}
		if ($TrackQuery) {
			$params.add('TrackQuery', $true)
		}
		if ($Calculated) {
			$params.add('Calculated', $true)
		}
		if ($Page) {
			switch -regex ($page) {
				"^((?!0)\d+)(-)((?!0)\d+)$" {
					$page = $page -split "-"
					for ($i=[int]$page[0];$i -le [int]$page[1];$i++) {
						if ($params.page) {
							$params.Page = $i.tostring()
						} else {
							$params.add('Page', $i.tostring())
						}
						if ($wait) {
							Start-Sleep -s $wait
						} else {
							Start-Sleep -s 3
						}
						Invoke-APIOnypheSearch @params
					}
				}
				"^((?!0)\d+)$" {
					$params.add('Page', $page[0])
					Invoke-APIOnypheSearch @params
				}
			}
		} else {
			Invoke-APIOnypheSearch @params
		}
	}
 	}
