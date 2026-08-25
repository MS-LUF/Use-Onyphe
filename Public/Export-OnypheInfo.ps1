	Function Export-OnypheInfo {
		<#
		 .SYNOPSIS 
		 main function/cmdlet - Export Search information on onyphe.io web service using search export API
	 
		 .DESCRIPTION
		 main function/cmdlet - Export Search information on onyphe.io web service using search export API
		 send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

		 .PARAMETER InputOnypheObject
		 -InputOnypheObject PSOnyphe object
		 used a PSOnyphe object generated with Search-Onyphe as input
	 
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
	 	 
		 .PARAMETER Wait
		 -Wait int{second}
		 wait for x second before sending the request to manage rate limiting restriction
	
		 .PARAMETER TrackQuery
		 -TrackQuery switch
		 ask Onyphe to return, for each result, which OQL filter matched it

		 .PARAMETER Calculated
		 -Calculated switch
		 ask Onyphe to enrich results with computed fields (e.g. defanged/undefanged URL variants)

		 .PARAMETER UseBetaFeatures
		 -UseBetaFeatures switch
		 use test.onyphe.io to use new beat features of Onyphe

		 .PARAMETER SaveInfoAsFile
		 -SaveInfoAsFile string
		 full path to file where json data will be exported.
		 
		 .OUTPUTS
		 TypeName: System.Management.Automation.PSCustomObject
		 	 
		 .EXAMPLE
		 AdvancedSearch with multiple criteria/filters
		 Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows and export data to myexport.json
		 C:\PS> Export-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan -SaveInfoAsFile .\myexport.json
	 
		 .EXAMPLE
		 simple search with one filter/criteria
		 Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists and export data to myexport.json
		 C:\PS> Export-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -SaveInfoAsFile .\myexport.json
	 
		 .EXAMPLE
		 AdvancedSearch with multiple criteria/filters and set the API key
		 Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows and export data to myexport.json
		 C:\PS> Export-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -SaveInfoAsFile .\myexport.json
	
		 .EXAMPLE
		 simple search with one filter/criteria and use a server filter to retrieve only objects indexed since 2 month
		 Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists and export data to myexport.json
		 C:\PS> Export-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction monthago -FilterValue "2" -SaveInfoAsFile .\myexport.json
	
		.EXAMPLE
		 filter the result and show me only the answer with os property not null for threatlist category for all Russia  and export data to myexport.json
		 C:\PS> Export-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction exist -FilterValue os -SaveInfoAsFile .\myexport.json
	
		 .EXAMPLE
		 filter the results using multiple filters (only os property known and from all organization like *company*) for tcp port 3389 opened in russia  and export data to myexport.json
		 C:\PS> Export-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan -SaveInfoAsFile .\myexport.json

		.EXAMPLE
		 search from onyphe using search-onyphe and pipe the object to export the content to a json file using export-onyphe
		 C:\PS> Search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan | Export-onyphe -SaveInfoAsFile .\myexport.json

		.EXAMPLE
		 exclude a filter from the results by prefixing its name with "!" (OQL NOT), and/or OR two filters together by
		 prefixing them with "?" (OQL OR) - both work as plain text inside -AdvancedSearch, no dedicated parameter needed
		 C:\PS> Export-OnypheInfo -AdvancedSearch @("category:threatlist","!country:RU") -category threatlist -SaveInfoAsFile .\myexport.json

		.EXAMPLE
		 OR several wildcard/regexp conditions together by repeating the function once per condition in -AdvancedFilter
		 (this is how Onyphe's OQL itself combines multiple wildcard/regexp conditions - not a single comma-packed call)
		 C:\PS> Export-OnypheInfo -AdvancedFilter @("orwildcard:domain,g?ogle.com","orwildcard:domain,googl?.com") -Category resolver -SaveInfoAsFile .\myexport.json

		.EXAMPLE
		 ask for the matched-filter/calculated-fields metadata on every exported result
		 C:\PS> Export-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -TrackQuery -Calculated -SaveInfoAsFile .\myexport.json
	 #>
		 [cmdletbinding()]
		 param(
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false,Position=12)]
			[ValidateScript({($_ -is [System.Management.Automation.PSCustomObject]) -or ($_ -is [Deserialized.System.Management.Automation.PSCustomObject])})]
				  [array]$InputOnypheObject,
		 	 [parameter(Mandatory=$false,Position=2)]
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
			 [parameter(Mandatory=$false,Position=7)]
				 [int]$wait,
			 [parameter(Mandatory=$false,Position=9)]
				 [switch]$UseBetaFeatures,
			 [parameter(Mandatory=$false,Position=10)] 
			 [ValidateNotNullOrEmpty()]
				 [Array]$AdvancedFilter,
			 [parameter(Mandatory=$true,Position=11)]
			 	 [string]$SaveInfoAsFile,
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
			 $ParameterAttribute.Mandatory = $false
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
			if (!($InputOnypheObject)) {
				$SearchType = $PsBoundParameters[$ParameterNameType]
				$SearchFilter = $PsBoundParameters[$ParameterNameFilter]
				$SearchFunction = $PsBoundParameters[$ParameterNameFunction]
				if ((!($SearchValue) -and !($AdvancedSearch)) -or !($SearchType)) {
					Throw "SearchValue or AdvancedSearch parameters and SearchType parameter are mandatory"
				}
				$params = @{
					SearchType = $SearchType
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
				if ($TrackQuery) {
					$params.add('TrackQuery', $true)
				}
				if ($Calculated) {
					$params.add('Calculated', $true)
				}
				$params.add('FuncInput', $PsBoundParameters)
			} else {
				if ($InputOnypheObject.'cli-func_input') {
					$params = $InputOnypheObject.'cli-func_input'.clone()
					$params.add('FuncInput', $InputOnypheObject.'cli-func_input'.clone())
					if ($params.Page) {
						$params.remove('Page')
					}
				} else {
					throw "invalid input object, missing property cli-func_input"
				}
			}
			$params.add('OutFile', $SaveInfoAsFile)
			Invoke-APIOnypheExport @params
		}
	}
