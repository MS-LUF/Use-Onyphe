#
# Created by: lucas.cueff[at]lucas-cueff.com
#
# v0.92 : 
# - manage new search APIs
# - code refactoring
# - fix file export for new categories and properties
# - manage proxy connection
# - manage API key storage with encryption in a config file
# - add paging feature on search and info functions
# - add tag filter
# v0.93 : 
# - add local stat function
# v0.94 :
# - manage new apis (ctl, sniffer, onionscan, md5)
# - use userinfos API to collect APIs and search filters
# - rewrite get-onyphe info function to simplify the code
# - update invoke-apionyphedatascan with only a single parameter
# v0.95 :
# - fix HTTP error on invoke-onyphe when no network is available
# - add datashot management
# - add function to export datashot to picture file
# - fix Get-OnypheInfoFromCSV
# - update Export-OnypheInfoToFile
# v0.96 :
# - add new filtering function for search request
# - add Get-OnypheSearchFunctions function
# - update Invoke-APIOnypheSearch and Search-OnypheInfo functions
# - replace SimpleSearchfilter parameter with SimpleSearchfilter
# - replace SimpleSearchValue parameter with SearchValue
# - add FunctionFilter and FunctionValue parameters
# - update Get-OnypheInfoFromCSV to manage new filter function in search request
# - add new alias Get-OnypheInfoFromCSV
# v0.97 :
# - code improvement
# - add beta switch to use beta interface of onyphe instead of production one
# - improve paging parameters
# - add advancedfilter option to Search-onyphe to manage multiple filter functions input
# - add onionshot category to datashot export function
# v0.98 :
# - update paging regex to support more than 1000 pages
# v0.99 :
# - replace $env:appdata with $home for Linux and Powershell Core compatibility
# - create new function to request APIv2 (Invoke-OnypheAPIV2) and managing api key as new header etc...
# - rename previous function to request APIv1 (Invoke-OnypheAPIV1) and fix Net.WebException management for Powershell core
# - create new functions to deal with Onyphe Alert APIs (Invoke-APIOnypheListAlert, Invoke-APIOnypheDelAlert, Invoke-APIOnypheAddAlert)
# - create new functions for managing the Onyphe Alert (Get-OnypheAlertInfo, Set-OnypheAlertInfo)
# v1.0 :
# - fix rate limiting issue on paging
# - manage new API in Export-OnypheInfoToFile
# v1.1 : 
# - add new APIv2, migrate from APIv1 to full APIv2
# - remove temporary fix for empty array in APIv2
# - update deserialization of psobject
#
# released on 08/2020
# v1.2 : Last public release
# - add bulk API
# - update code to optimize file export (decrease memory to write file directly)
# - update object type to PSOnyphe
# - update inputobject parameter to InputOnypheObject
# - fix various bug found 

#
#'(c) 2018-2020 lucas-cueff.com - Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).'

# dev : comment on fonction missing

<#
	.SYNOPSIS 
	commandline interface to use onyphe.io web service

	.DESCRIPTION
	use-onyphe.psm1 module provides a commandline interface to onyphe.io web service.
	
	.EXAMPLE
	C:\PS> import-module use-onyphe.psm1
#>

	Function Get-OnypheStatsFromObject {
 <#
	.SYNOPSIS 
	Get Some stats (count, total, min, max, average) for one or multiple properties of a onyphe result powershell object

	.DESCRIPTION
	Get Some stats (count, total, min, max, average) for one or multiple properties of a onyphe result powershell object
	
	.PARAMETER InputOnypheObject
	-InputOnypheObject PSCustomObject{Onyphe result PSCustomObject}
	Onyphe object used for the stat
	
	.PARAMETER AdvancedFacets
	-AdvancedFacets ARRAY{list of onyphe objects' properties}
	Onyphe result object's property requested for the stat (results = on object per property requested)

	.PARAMETER Facets
	-Facets string{onyphe objects' property}
	Onyphe result object's property requested for the stat
	
	.OUTPUTS
   	TypeName: PSOnyphe
		
	.EXAMPLE
	Search SynScan info and request stats for 'ip','port','tag' and 'organization' properties
	C:\PS> Search-OnypheInfo -AdvancedSearch @('country:FR','port:23','os:Linux') -SearchType synscan | Get-OnypheStatsFromObject -AdvancedFacets @('ip','port','tag','organization')

	.EXAMPLE
	Search SynScan info and request stats for 'ip' property
	C:\PS> $onypheobj = Search-OnypheInfo -AdvancedSearch @('country:FR','port:23','os:Linux') -SearchType synscan
	C:\PS> Get-OnypheStatsFromObject -Facets 'ip' -InputOnypheObject $onypheobj
#>
	[cmdletbinding()]
	Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[ValidateScript({$_ -is [System.Management.Automation.PSCustomObject]})]
			[array]$InputOnypheObject,
		[parameter(Mandatory=$false)] 
		[ValidateNotNullOrEmpty()]
			[Array]$AdvancedFacets
	)
	DynamicParam
	{		
		$ParameterNameFilter = 'Facets'
		$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		$AttributeCollection2 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		$ParameterAttribute2 = New-Object System.Management.Automation.ParameterAttribute
		$ParameterAttribute2.ValueFromPipeline = $false
		$ParameterAttribute2.ValueFromPipelineByPropertyName = $false
		$ParameterAttribute2.Mandatory = $false
		$AttributeCollection2.Add($ParameterAttribute2)
		$arrSet =  Get-OnypheCliFacets
		$ValidateSetAttribute2 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		$AttributeCollection2.Add($ValidateSetAttribute2)
		$RuntimeParameter2 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFilter, [string], $AttributeCollection2)
		$RuntimeParameterDictionary.Add($ParameterNameFilter, $RuntimeParameter2)
		return $RuntimeParameterDictionary
	}
	Process {
		$Facets = $PsBoundParameters[$ParameterNameFilter]
		if (!$Facets -and !$AdvancedFacets) {
			Write-Verbose -Message "both AdvancedFacets and Facets options are empty, please use at least one of this parameter to set the facets to be used for the stats"
			throw "Please provide a valid facets option"
		}
		$script:results = @()
		$script:TemplateFacetObject = new-object psobject -Property @{
			'Onyphe-Facet' = $null
			'Onyphe-Property-value' = $null
			'Onyphe-Property-Count' = $null
		}
		If ($AdvancedFacets) {
			foreach ($facet in $AdvancedFacets) {
				$tmp = $InputOnypheObject.results."$($Facet)" | sort-object | get-unique
				$script:AllFacetObjects = @()
				foreach ($object in $tmp) {
					$tmpobj = $script:TemplateFacetObject | Select-Object *
					$tmpobj.'Onyphe-Property-value' = $object
					if (($InputOnypheObject.results | Where-Object {$_."$($Facet)" -eq "$($object)"}).count) {
						$tmpobj.'Onyphe-Property-Count' = ($InputOnypheObject.results | Where-Object {$_."$($Facet)" -eq "$($object)"}).count
					} Else {
						$tmpobj.'Onyphe-Property-Count' = 1
					}
					$tmpobj.'Onyphe-Facet' = $facet
					$script:AllFacetObjects += $tmpobj
				}
				$tmpmeasureobj = $script:AllFacetObjects.'Onyphe-Property-Count' | measure-object -Sum -Maximum -Minimum -Average
				$script:results += New-Object psobject -Property @{
					Stats = $script:AllFacetObjects
					Count = $tmpmeasureobj.Count
					Sum = $tmpmeasureobj.Sum
					Min = $tmpmeasureobj.Minimum
					Max = $tmpmeasureobj.Maximum
					Average = $tmpmeasureobj.Average
				}
			}
		} Else {
			$script:AllFacetObjects = @()
			$tmp = $InputOnypheObject.results."$($Facets)" | sort-object | get-unique
			foreach ($object in $tmp) {
				$tmpobj = $script:TemplateFacetObject | Select-Object *
				$tmpobj.'Onyphe-Property-value' = $object
				if (($InputOnypheObject.results | Where-Object {$_."$($Facets)" -eq "$($object)"}).count) {
					$tmpobj.'Onyphe-Property-Count' = ($InputOnypheObject.results | Where-Object {$_."$($Facets)" -eq "$($object)"}).count
				} Else {
					$tmpobj.'Onyphe-Property-Count' = 1
				}
				$tmpobj.'Onyphe-Facet' = $Facets
				$script:AllFacetObjects += $tmpobj
			}
			$tmpmeasureobj = $script:AllFacetObjects.'Onyphe-Property-Count' | measure-object -Sum -Maximum -Minimum -Average
			$script:results = New-Object psobject -Property @{
				Stats = $script:AllFacetObjects
				Count = $tmpmeasureobj.Count
				Sum = $tmpmeasureobj.Sum
				Min = $tmpmeasureobj.Minimum
				Max = $tmpmeasureobj.Maximum
				Average = $tmpmeasureobj.Average
			}
		}
		$results
	}
	}
	Function Get-OnypheInfoFromCSV {
 <#
	.SYNOPSIS 
	Get IP information from onyphe.io web service using as an input a CSV file containing all information

	.DESCRIPTION
	get various ip data information from onyphe.io web service using as an input a csv file (; separator)
	
	.PARAMETER fromcsv
	-fromcsv string{full path to csv file}
	automate onyphe.io request for multiple IP request
	
	.PARAMETER APIKey
	-APIKey string{APIKEY}
	set your APIKEY to be able to use Onyphe API.

	.PARAMETER csvdelimiter
	-csvdelimiter string{csv separator}
	set your csv separator. default is ;
	
	.OUTPUTS
	TypeName: System.Management.Automation.PSCustomObject
		
	.EXAMPLE
	Request info for several IP information from a csv formated file and your API key is already set as global variable
	C:\PS> Get-onypheinfofromcsv -fromcsv .\input.csv
	
	.EXAMPLE
	Request info for several IP information from a csv formated file and set the API key as global variable
	C:\PS> Get-onypheinfofromcsv -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	.EXAMPLE
	Request info for several IP information from a csv formated file using ',' separator and set the API key as global variable
	C:\PS> Get-onypheinfofromcsv -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -csvdelimiter ","
#>
  [cmdletbinding()]
  Param (
  	[parameter(Mandatory=$true)]
  	[ValidateScript({test-path "$($_)"})]
		  $fromcsv,
  	[parameter(Mandatory=$false)]
	  [ValidateLength(40,40)]
		  [string]$APIKey,
	  [parameter(Mandatory=$false)]
    	$csvdelimiter
	)
	process {
		$Script:Result = @()
		if ($APIKey) {
			Set-OnypheAPIKey -APIKEY $APIKey | out-null
		}
		if (!$csvdelimiter) {$csvdelimiter = ";"}
		if (($fromcsv -is [System.String]) -and (test-path $fromcsv)) {
				$csvcontent = import-csv $fromcsv -delimiter $csvdelimiter
		} ElseIf (($fromcsv -is [System.Management.Automation.PSCustomObject]) -and $fromcsv.'API-Input') {
			$csvcontent = $fromcsv
		} Else {
			write-verbose -message "provide a valid csv file as input or valid System.Management.Automation.PSCustomObject object"
			write-verbose -message "please use the following column in your file : ip, searchtype, datascanstring"
			throw "please provide a valid csv file as input or valid System.Management.Automation.PSCustomObject object"
		}
		$APISearchEntries = $csvcontent | where-object {$_.API -eq "Search"}
		foreach ($entry in $APISearchEntries) {
			$params = @{
				SearchType = $entry.'Search-Type'
				Wait = 3
			 }
			if ($entry.'Search-Request'.contains("+")) {
				$tmparray = $entry.'Search-Request'.split("+")
				$params.add('AdvancedSearch',$tmparray)
			} else {
				$params.add('AdvancedSearch',@($entry.'Search-Request'))
			}
			if ($entry.'Filter-Request') {
				if ($entry.'Filter-Request'.contains("+")) {
					$tmparray = $entry.'Filter-Request'.split("+")
					$params.add('AdvancedFilter',$tmparray)
				} else {
					$params.add('AdvancedFilter', $entry.'Filter-Request')
				}
			}
			if ($entry.'Page') {
				$params.add('Page', $entry.'Page')
			}
			$Script:Result += Search-OnypheInfo @params
		}
		$SummaryEntries = $csvcontent | where-object {($_.API -eq "IP") -or ($_.API -eq "Domain") -or ($_.API -eq "HostName")}
		foreach ($entry in $SummaryEntries) {
				$Script:Result += Get-OnypheSummary -SummaryAPIType $entry.API -SearchValue $entry.'API-Input' -wait 3
		}
		$SimpleEntries = $csvcontent | where-object {($_.API -ne "IP") -and ($_.API -ne "Domain") -and ($_.API -ne "HostName") -and ($_.API -ne "Search")}
		foreach ($entry in $SimpleEntries) {
			$Script:Result += Get-OnypheInfo -SimpleAPIType $entry.API -SearchValue $entry.'API-Input' -wait 3
		}
		$Script:Result
	}
	}
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
			 	 [string]$SaveInfoAsFile
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
			 $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
			 $AttributeCollection.Add($ValidateSetAttribute)
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
			 $ValidateSetAttribute2 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
			 $AttributeCollection2.Add($ValidateSetAttribute2)
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
			 $ValidateSetAttribute3 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
			 $AttributeCollection3.Add($ValidateSetAttribute3)
			 $RuntimeParameter3 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFunction, [string], $AttributeCollection3)
			 $RuntimeParameterDictionary.Add($ParameterNameFunction, $RuntimeParameter3)
			 
			 return $RuntimeParameterDictionary
		}
		Process {
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
	Function Export-OnypheBulkInfo {
		<#
		 .SYNOPSIS 
		 main function/cmdlet - Export Search information on onyphe.io web service using bulk APIs
	 
		 .DESCRIPTION
		 main function/cmdlet - Export Search information on onyphe.io web service using bulk APIs
		 bulk APIs use input file containing ip, domain or hostname and sends back streamed json as result.
	 	 
		 .PARAMETER APIKey
		 -APIKey string{APIKEY}
		 set your APIKEY to be able to use Onyphe API.
	 	 
		 .PARAMETER Wait
		 -Wait int{second}
		 wait for x second before sending the request to manage rate limiting restriction
	
		 .PARAMETER SaveInfoAsFile
		 -SaveInfoAsFile string
		 full path to file where json data will be exported.

		 .PARAMETER FilePath
		 -FilePath string
		 full path to file to be imported to the bulk API.

		 .PARAMETER BulkAPIType
		 -BulkAPIType string {Get-OnypheSummaryAPIName}
		 Bulk API to be used : ip, domain, hostname
		 
		 .OUTPUTS
		 TypeName: System.Management.Automation.PSCustomObject
		 	 
		 .EXAMPLE
		 export search for IP information into Json file using myfile.txt as source IPs file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType ip
	 
		 .EXAMPLE
		 export search for domain information into Json file using myfile.txt as source domains file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType domain
	 
		 .EXAMPLE
		 export search for hostname information into Json file using myfileip.txt as source hostnames file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType hostname
	 #>
		[cmdletbinding()]
		param(
			[parameter(Mandatory=$true)]
			[ValidateScript({test-path "$($_)"})]
				[string]$FilePath,
			[parameter(Mandatory=$true)]
				[string]$SaveInfoAsFile,
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
				[int]$wait
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
			$ParameterAttribute.Position = 2
			$AttributeCollection.Add($ParameterAttribute)
			$arrSet =  Get-OnypheSummaryAPIName
			$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
			$AttributeCollection.Add($ValidateSetAttribute)
			$ParameterNameAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList @("BulkAPIType")
			$AttributeCollection.Add($ParameterNameAlias)
			$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
			$RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
			return $RuntimeParameterDictionary
	 	}
		Process {
			$SearchType = $PsBoundParameters[$ParameterNameType]
			if ($wait) {start-sleep -s $wait}
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				OutFile = $SaveInfoAsFile
				FilePath = $FilePath
			}
			if (test-path function:\"Invoke-APIBulkSummaryOnyphe$($Searchtype)") {
				$responsestream = invoke-expression "Invoke-APIBulkSummaryOnyphe$($Searchtype) `@params"
			} else {
				throw "API $($Searchtype) not implemented yet in this version of Use-Onyphe pwsh module"
			}
		}
	}
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
		 	[Array]$AdvancedFilter
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
		 $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		 $AttributeCollection.Add($ValidateSetAttribute)
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
		 $ValidateSetAttribute2 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		 $AttributeCollection2.Add($ValidateSetAttribute2)
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
		 $ValidateSetAttribute3 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		 $AttributeCollection3.Add($ValidateSetAttribute3)
		 $RuntimeParameter3 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFunction, [string], $AttributeCollection3)
		 $RuntimeParameterDictionary.Add($ParameterNameFunction, $RuntimeParameter3)
		 
		 return $RuntimeParameterDictionary
	}
	Process {
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
					$params.add('Page', $page)
					Invoke-APIOnypheSearch @params
				}
			}
		} else {
			Invoke-APIOnypheSearch @params
		}
	}
 	}
	Function Get-OnypheInfo {
  <#
	.SYNOPSIS 
	main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Simple API available

	.DESCRIPTION
	main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Simple API available
	send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
	
	.PARAMETER SimpleAPIType string (ctl,datascan,geoloc,inetnum,pastries,resolver,sniffer,synscan,threatlist,datashot,onionscan,onionshot,topsite,vulnscan,resolverreverse,resolverforward,datascandatamd5)
	-SearchValue string -SimpleAPIType Inetnum -APIKey string{APIKEY}
	look for an ip address in onyphe database
	-SearchValue string -SimpleAPIType Threatlist -APIKey string{APIKEY}
	look for threat info about a specific IP in onyphe database.
	-SearchValue string -SimpleAPIType Pastries -APIKey string{APIKEY}
	look for an pastbin data about a specific IP in onyphe database.
	-SearchValue string -SimpleAPIType Synscan -APIKey string{APIKEY}
	
	.PARAMETER APIKey
	-APIKey string{APIKEY}
	set your APIKEY to be able to use Onyphe API.

    .PARAMETER Page
	-page string{page number}
	go directly to a specific result page (1 to 1000)
	you can set a list of page using x-y like 1-100 to read the first 100 pages

    .PARAMETER Wait
	-Wait int{second}
	wait for x second before sending the request to manage rate limiting restriction
	
	.OUTPUTS
	TypeName: System.Management.Automation.PSCustomObject
		
	.EXAMPLE
	Request geoloc information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -SimpleAPIType Geoloc
	
	.EXAMPLE
	Request dns reverse information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -SimpleAPIType ResolverReverse -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	request IIS keyword datascan information
	C:\PS> Get-OnypheInfo -SimpleAPIType DataScan -SearchValue "IIS" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	request datascan information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -SimpleAPIType DataScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request pastebin content information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -SimpleAPIType Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	.EXAMPLE
	Request pastebin content information for ip 8.8.8.8 and see page 2 of results
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -SimpleAPIType Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -page "2"
	
	.EXAMPLE
	Request dns forward information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -SimpleAPIType ResolverForward -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request threatlist information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -SimpleAPIType Threatlist -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request inetnum information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -SimpleAPIType Inetnum -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request synscan information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -SimpleAPIType SynScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"	
#>
  [cmdletbinding()]
  Param (
	[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[string]$SearchValue,
	[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
		[string]$APIKey,
	[parameter(Mandatory=$false)]
	[ValidateScript({($_ -match "^((?!0)\d+)$") -or ($_ -match "^((?!0)\d+)(-)((?!0)\d+)$")})]
		[string[]]$Page,
	[parameter(Mandatory=$false)]
		[int]$wait
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
		$ParameterAttribute.Position = 2
		$AttributeCollection.Add($ParameterAttribute)
		$arrSet =  Get-OnypheSimpleAPIName
		$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		$AttributeCollection.Add($ValidateSetAttribute)
		$ParameterNameAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList @("SimpleAPIType")
		$AttributeCollection.Add($ParameterNameAlias)
		$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
		$RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
		return $RuntimeParameterDictionary
 }
	process {
		$SearchType = $PsBoundParameters[$ParameterNameType]
		if (!($SearchType -and $SearchValue)) {
			throw "Please provide a valid searchvalue and simple API type parameters"
		}
		if ($wait) {start-sleep -s $wait}
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		If ($searchtype) {
			if ($SearchValue) {
				$params = @{
					input = $SearchValue
				}
				if (test-path function:\"Invoke-APIOnyphe$($Searchtype)") {
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
									invoke-expression "Invoke-APIOnyphe$($Searchtype) `@params"
								}
							}
							"^((?!0)\d+)$" {
								$params.add('Page', $page)
								invoke-expression "Invoke-APIOnyphe$($Searchtype) `@params"
							}
						}
					} else {
						invoke-expression "Invoke-APIOnyphe$($Searchtype) `@params"
					}
				} else {
					throw "API $($Searchtype) not implemented yet in this version of Use-Onyphe pwsh module"
				}
			} else {
				throw "-SearchValue parameter must be used with -SimpleAPIType"
			}
		} 
	}
	}
	Function Get-OnypheSummary {
		<#
		  .SYNOPSIS 
		  main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Summary API available
	  
		  .DESCRIPTION
		  main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Summary API available
		  send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
		  
		  .PARAMETER SummaryAPIType string (ip,domain,hostname)
		  -SearchValue string -SummaryAPIType ip -APIKey string{APIKEY}
		  look for an all info available regarding an ip address in onyphe database
		  -SearchValue string -SummaryAPIType domain -APIKey string{APIKEY}
		  look for an all info available regarding a domain in onyphe database
		  -SearchValue string -SummaryAPIType hostname -APIKey string{APIKEY}
		  look for an all info available regarding an hostname in onyphe database
		  
		  .PARAMETER APIKey
		  -APIKey string{APIKEY}
		  set your APIKEY to be able to use Onyphe API.
	  
		  .PARAMETER Page
		  -page string{page number}
		  go directly to a specific result page (1 to 1000)
		  you can set a list of page using x-y like 1-100 to read the first 100 pages
	  
		  .PARAMETER Wait
		  -Wait int{second}
		  wait for x second before sending the request to manage rate limiting restriction
		  
		  .OUTPUTS
		  TypeName: System.Management.Automation.PSCustomObject
		  
		  .EXAMPLE
		  Request all information for ip 8.8.8.8 
		  C:\PS> Get-OnypheSummary -SearchValue "8.8.8.8" -SummaryAPIType ip
		  
		  .EXAMPLE
		  Request all information for perdu.com domain and set the API key
		  C:\PS> Get-OnypheSummary -SearchValue "perdu.com" -SummaryAPIType domain -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		  
		  .EXAMPLE
		  Request all information for www.perdu.com hostname  and see page 2 of results
		  C:\PS> Get-OnypheSummary -SearchValue "www.perdu.com" -SummaryAPIType hostname -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -page "2"
		  
	  #>
		[cmdletbinding()]
		Param (
		  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false)]
			  [ValidateNotNullOrEmpty()]
			  [string]$SearchValue,
		  [parameter(Mandatory=$false)]
			  [ValidateLength(40,40)]
			  [string]$APIKey,
		  [parameter(Mandatory=$false)]
		  [ValidateScript({($_ -match "^((?!0)\d+)$") -or ($_ -match "^((?!0)\d+)(-)((?!0)\d+)$")})]
			  [string[]]$Page,
		  [parameter(Mandatory=$false)]
			  [int]$wait
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
			  $ParameterAttribute.Position = 2
			  $AttributeCollection.Add($ParameterAttribute)
			  $arrSet =  Get-OnypheSummaryAPIName
			  $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
			  $AttributeCollection.Add($ValidateSetAttribute)
			  $ParameterNameAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList @("SummaryAPIType")
			  $AttributeCollection.Add($ParameterNameAlias)
			  $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
			  $RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
			  return $RuntimeParameterDictionary
	   }
		  process {
			  $SearchType = $PsBoundParameters[$ParameterNameType]
			  if (!($SearchType -and $SearchValue)) {
				  throw "Please provide a valid searchvalue and summary API type parameters"
			  }
			  if ($wait) {start-sleep -s $wait}
			  if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			  If ($searchtype) {
				  if ($SearchValue) {
					  $params = @{
						  input = $SearchValue
					  }
					  if (test-path function:\"Invoke-APISummaryOnyphe$($Searchtype)") {
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
										  invoke-expression "Invoke-APISummaryOnyphe$($Searchtype) `@params"
									  }
								  }
								  "^((?!0)\d+)$" {
									  $params.add('Page', $page)
									  invoke-expression "Invoke-APISummaryOnyphe$($Searchtype) `@params"
								  }
							  }
						  } else {
							  invoke-expression "Invoke-APISummaryOnyphe$($Searchtype) `@params"
						  }
					  } else {
						  throw "API $($Searchtype) not implemented yet in this version of Use-Onyphe pwsh module"
					  }
				  } else {
					  throw "-SearchValue parameter must be used with -SummaryAPIType"
				  }
			  } 
		  }
	}
	Function Get-OnypheUserInfo {
	<#
	 .SYNOPSIS 
	 main function/cmdlet - Get user account information (rate limiting status, requests remaining in pool...) from onyphe.io web service
 
	 .DESCRIPTION
	 main function/cmdlet - Get user account information (rate limiting status, requests remaining in pool...) from onyphe.io web service
	 send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
 	 
	 .PARAMETER APIKey
	 -APIKey string{APIKEY}
	 set your APIKEY to be able to use Onyphe API.

	 .PARAMETER UseBetaFeatures
	 -UseBetaFeatures switch
	 use test.onyphe.io to use new beat features of Onyphe

     .PARAMETER Wait
	 -Wait int{second}
	 wait for x second before sending the request to manage rate limiting restriction
	 
	 .OUTPUTS
	 TypeName: System.Management.Automation.PSCustomObject
	 
	.EXAMPLE
	get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx and set the api key
	C:\PS> Get-OnypheUserInfo -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	.EXAMPLE
	get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx already set as global variable
	C:\PS> Get-OnypheUserInfo
 #>
   [cmdletbinding()]
   Param (
	[parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
		[string]$APIKey,
	[parameter(Mandatory=$false)]
		[int]$wait,
	[parameter(Mandatory=$false)]
		[switch]$UseBetaFeatures
   )
	process {
		if ($wait) {start-sleep -s $wait}
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		if ($UseBetaFeatures) {
			$params = @{
				UseBetaFeatures = $true
			}
		}
		if ($params) {
			Invoke-APIOnypheUser @params
		} else {
			Invoke-APIOnypheUser
		}
	}
	}
	Function Get-OnypheAlertInfo {
<#
	 .SYNOPSIS 
	 main function/cmdlet - get existing alert on onyphe.io web service using alert APIs
 
	 .DESCRIPTION
	 main function/cmdlet - get all alert on onyphe.io web service using alert APIs and filter alert with query or mail criteria at client side
	 get content through HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
 	 
	 .PARAMETER APIKey
	 -APIKey string{APIKEY}
	 set your APIKEY to be able to use Onyphe API.
 
	 .PARAMETER UseBetaFeatures
	 -UseBetaFeatures switch
	 use test.onyphe.io to use new beat features of Onyphe
	
	 .PARAMETER SearchFilter
	 -SearchFilter String {"query","name", "email", "id" - default value "name"} 
	 Selected field to be used for searching/filtering process at client side
	 
	 .PARAMETER SearchOperator
	 -SearchOperator String {"eq","ne","like","notlike","match","notmatch" - default value "eq"}
	 Powershell Search operator to be used for filtering

	 .PARAMETER SearchValue
	 -SearchValue String
	 Value to be used as main filter could be a word or expression depending of chosen search operator

	 .OUTPUTS
	 TypeName: System.Management.Automation.PSCustomObject
	 		 
	 .EXAMPLE
	 Get all existing alert using "jeanclaude.dusse@lesbronzesfontdusk.io"
	 C:\PS> Get-OnypheAlert -SearchValue "jeanclaude.dusse@lesbronzesfontdusk.io" -SearchOperator eq -SearchFilter email

	 .EXAMPLE
     Get all existing alert for your onyphe account
	 C:\PS> Get-OnypheAlert
 #>
		[cmdletbinding()]
		Param (
		 [parameter(Mandatory=$false)]
		 [ValidateLength(40,40)]
			 [string]$APIKey,
		 [parameter(Mandatory=$false,Position=10)]
			 [switch]$UseBetaFeatures,
		 [Parameter(Mandatory=$false)]
		 [validateSet("query","name", "email", "id")]
			 [string]$SearchFilter = "name",
		 [Parameter(Mandatory=$false)]
		 [ValidateNotNullOrEmpty()]
			 [string]$SearchValue,
	     [Parameter(Mandatory=$false)]
	     [validateSet("eq","ne","like","notlike","match","notmatch")]
			 [string]$SearchOperator = "eq"
		)
		 process {
			 if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			 if ($UseBetaFeatures) {
				$results = Invoke-APIOnypheListAlert -UseBetaFeatures
			 } else {
				$results = Invoke-APIOnypheListAlert
			 }
			 if (!$SearchValue) {
				$results
			 } else {
				switch ($SearchOperator) {
					eq {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -eq $SearchValue})}
					ne {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -ne $SearchValue})}
					like {$results| add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -like $SearchValue})}
					notlike {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -notlike $SearchValue})}
					match {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -match $SearchValue})}
					notmatch {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -notmatch $SearchValue})}
					Default {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -eq $SearchValue})}
				}
				$results
			 }
		 }
	}
	Function Set-OnypheAlertInfo {
<#
	 .SYNOPSIS 
	 main function/cmdlet - create, modify, delete an alert on onyphe.io web service using alert APIs
 
	 .DESCRIPTION
	 main function/cmdlet - create, modify, delete an alert on onyphe.io web service using alert APIs
	 post JSON content through HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
 
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
 
	 .PARAMETER SearchType
	 -SearchType STRING{Get-OnypheSearchCategories}
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
 
	 .PARAMETER UseBetaFeatures
	 -UseBetaFeatures switch
	 use test.onyphe.io to use new beat features of Onyphe
	
	 .PARAMETER AlertAction
	 -AlertAction String {"new","delete","modify" - default value "new"} 
	 Mandatory parameter used to select what kind of action is requested : creation, deletion, modification of an alert
	 
	 .PARAMETER AlertName
	 -AlertName String
	 Name of the alert. Only alphanumeric and space characters allowed.

	 .PARAMETER AlertMail
	 -AlertMail String
	 Mail address used to send you back the alert when a new event is matching your query

	 .OUTPUTS
	 TypeName: System.Management.Automation.PSCustomObject
	 		 
	 .EXAMPLE
	 New alert for AdvancedSearch with multiple criteria/filters
	 Set a new alert named "windows apache" matching datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows, and sent back the alert on "jeanclaude.dusse@lesbronzesfontdusk.io"
	 C:\PS> Set-OnypheAlert -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan -AlertAction new -AlertName "windows apache" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"
 
	 .EXAMPLE
	 New alert for simple search with one filter/criteria
	 Set a new alert named "from russia with lv" matching threatlist for all IP matching the criteria : all IP from russia tagged by threat lists, and sent back the alert on "jeanclaude.dusse@lesbronzesfontdusk.io"
	 C:\PS> Set-OnypheAlert -SearchValue RU -SearchType threatlist -SearchFilter country -AlertAction new -AlertName "from russia with lv" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"
 	 
	 .EXAMPLE
	 New alert for simple search with one filter/criteria and use a server filter to retrieve only objects indexed since 2 month, 
	 Set an new alert named "from russia with lv 2 m" matching threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	 C:\PS> Set-OnypheAlert -SearchValue RU -SearchType threatlist -SearchFilter country -FilterFunction monthago -FilterValue "2" -AlertAction new -AlertName "from russia with lv 2 m" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"

	 .EXAMPLE
	 Modify an existing alert named "from paris with lv" and update mail and query
	 Modify an existing alert named "from paris with lv" an update it to match threatlist for all IP matching the criteria : all IP from russia tagged by threat lists and filter the result and show me only the answer with os property not null, finally sent back the alert to new mail "robert.lespinasse@lesbronzesfontdusk.io"
	 C:\PS> Set-OnypheAlert -SearchValue FR -SearchType threatlist -SearchFilter country -FilterFunction exist -FilterValue os -AlertAction modify -AlertName "from paris with lv" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"

	 .EXAMPLE
	 New alert for advanced search and filter
	 Set a new alert named "RandR" matching datascan for all IP matching the criteria : all ip from RU with TCP 3389 port opened, filter the results using multiple filters (only os property known and from all organization like *company*), and finally sent back the alert to "robert.lespinasse@lesbronzesfontdusk.io"
	 C:\PS> Set-OnypheAlert -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"

	 .EXAMPLE
     Delete an existing alert named "windows apache"
	 C:\PS> Set-OnypheAlert -AlertAction delete -AlertName "windows apache"
 #>
		[cmdletbinding()]
		param(
			[parameter(Mandatory=$false,Position=5)]
			[ValidateNotNullOrEmpty()]  
				[string]$SearchValue,
			[parameter(Mandatory=$false,Position=8)] 
			[ValidateNotNullOrEmpty()]
				[string[]]$FilterValue,
			[parameter(Mandatory=$false,Position=9)] 
			[ValidateNotNullOrEmpty()]
				[Array]$AdvancedSearch,
			[Parameter(Mandatory=$true,Position=1)]
			[validateSet("new","delete","modify")]
				[string]$AlertAction = "new",
			[Parameter(Mandatory=$false,Position=2)]
			[ValidateScript({$_ -match "^[a-zA-Z0-9.!£#$%&'^_`{}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"})]
				[string]$AlertMail,
			[Parameter(Mandatory=$true, Position=3)]
			[ValidateScript({$_ -match "^[a-zA-Z0-9 ]*$"})]
				[string]$AlertName,
			[parameter(Mandatory=$false,Position=11)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false,Position=12)]
				[switch]$UseBetaFeatures,
			[parameter(Mandatory=$false,Position=10)] 
			[ValidateNotNullOrEmpty()]
				[Array]$AdvancedFilter,
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false)]
			[ValidateScript({($_ -is [System.Management.Automation.PSCustomObject]) -or ($_ -is [Deserialized.System.Management.Automation.PSCustomObject])})]
				[array]$InputOnypheObject
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
			$ParameterAttribute.Position = 4
			$AttributeCollection.Add($ParameterAttribute)
			$arrSet = Get-OnypheSearchCategories
			$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
			$AttributeCollection.Add($ValidateSetAttribute)
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
			$ParameterAttribute2.Position = 6
			$AttributeCollection2.Add($ParameterAttribute2)
			$arrSet =  Get-OnypheSearchFilters
			$ValidateSetAttribute2 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
			$AttributeCollection2.Add($ValidateSetAttribute2)
			$RuntimeParameter2 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFilter, [string], $AttributeCollection2)
			$RuntimeParameterDictionary.Add($ParameterNameFilter, $RuntimeParameter2)
   
			$ParameterNameFunction = 'FilterFunction'
			$AttributeCollection3 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
			$ParameterAttribute3 = New-Object System.Management.Automation.ParameterAttribute
			$ParameterAttribute3.ValueFromPipeline = $false
			$ParameterAttribute3.ValueFromPipelineByPropertyName = $false
			$ParameterAttribute3.Mandatory = $false
			$ParameterAttribute3.Position = 7
			$AttributeCollection3.Add($ParameterAttribute3)
			$arrSet =  Get-OnypheSearchFunctions
			$ValidateSetAttribute3 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
			$AttributeCollection3.Add($ValidateSetAttribute3)
			$RuntimeParameter3 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFunction, [string], $AttributeCollection3)
			$RuntimeParameterDictionary.Add($ParameterNameFunction, $RuntimeParameter3)
			
			return $RuntimeParameterDictionary
	   }
		 process {
			$SearchType = $PsBoundParameters[$ParameterNameType]
			$SearchFilter = $PsBoundParameters[$ParameterNameFilter]
			$SearchFunction = $PsBoundParameters[$ParameterNameFunction]
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			if ($SearchValue -or $AdvancedSearch) {
				$params = @{
					SearchType = $SearchType
					AlertName = $AlertName
					AlertEmail = $AlertMail
					FuncInput = $PsBoundParameters
				}
			} elseif ($InputOnypheObject) {
				if (!$AlertName -and !$AlertMail) {
					throw "please use AlertName, AlertMail and AlertAction parameters when using InputOnypheObject parameter"
				} else {
					if ($InputOnypheObject.'cli-func_input') {
						$params = $InputOnypheObject.'cli-func_input'.clone()
						$params.add('FuncInput', $InputOnypheObject.'cli-func_input'.clone())
						$params.add('AlertName',$AlertName)
						$params.add('AlertEmail',$Alertmail)
						if ($params.Page) {
							$params.remove('Page')
						}
					} else {
						throw "invalid input object, missing property cli-func_input"
					}
				}
			}
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
			$AlertCheck = Get-OnypheAlertInfo -SearchValue $AlertName
			switch ($AlertAction) {
				new {
					if (!$AlertMail) {
						throw "please provide a mail address using AlertMail parameter"
					}
					if (!$AdvancedSearch -and !$SearchValue -and !$InputOnypheObject) {
						throw "please provide valid search request for the alert query system using AdvancedSearch or SearchValue parameters. Or Please provide a valid input object using InputOnypheObject parameter."
					}
					if ($AlertCheck.'cli-Filtered_Results') {
						throw "$($Alertname) is already used as an existing alert"
					} else {
						Invoke-APIOnypheAddAlert @params
					}
				}
				delete {
					if ($AlertCheck.'cli-Filtered_Results') {
						Invoke-APIOnypheDelAlert -AlertID $AlertCheck.'cli-Filtered_Results'.ID
					} else {
						throw "$($Alertname) not existing"
					}
				}
				modify {
					if (!$AlertMail) {
						throw "please provide a mail address using AlertMail parameter"
					}
					if (!$AdvancedSearch -and !$SearchValue -and !$InputOnypheObject) {
						throw "please provide valid search request for the alert query system using AdvancedSearch or SearchValue parameters. Or Please provide a valid input object using InputOnypheObject parameter."
					}
					if ($AlertCheck.'cli-Filtered_Results') {
						Invoke-APIOnypheDelAlert -AlertID $AlertCheck.'cli-Filtered_Results'.ID
						Invoke-APIOnypheAddAlert @params
					} else {
						throw "$($Alertname) not existing"
					}
				}
			}
		 }
	}
	Function Invoke-APIOnypheUser {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-OnypheAPIV2 function and then call it to get the user account info from user API
  
	  .DESCRIPTION
	  create several input for Invoke-OnypheAPIV2 function and then call it to get the user account info from user API
	  	  
	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
		Set APIKEY as global variable.
		
		.PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe
	  
	  .OUTPUTS
		 TypeName: PSOnyphe
  
	  .EXAMPLE
	  get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx and set the api key
	  C:\PS> Invoke-APIOnypheUser -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	  .EXAMPLE
	  get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx already set as global variable
	  C:\PS> Invoke-APIOnypheUser
	#>
	[cmdletbinding()]
	Param ( 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$UseBetaFeatures,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
	)  
	  Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "v2/user/"
				APIInfo = "user"
				APIInput = "none"
				APIKeyrequired = $true
			}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			if ($UseBetaFeatures) {
				$params.add("UseBetaFeatures", $true)
			}
			Write-Verbose -message "URL Info : $($params.request)"  
			Invoke-OnypheAPIV2 @params
		}
    }
	Function Invoke-APIOnypheInetnum {
  <#
	.SYNOPSIS 
	create several input for Invoke-OnypheAPIV2 function and then call it to get the inetnum info from inetnum API

	.DESCRIPTION
	create several input for Invoke-OnypheAPIV2 function and then call it to get the inetnum info from inetnum API
	
	.PARAMETER IP
	-IP string{IP}
	IP to be used for the geoloc API usage
	
	.PARAMETER APIKEY
	-APIKey string{APIKEY}
	Set APIKEY as global variable.

	.PARAMETER Page
	-page string{page number}
	go directly to a specific result page (1 to 1000)
	
	.OUTPUTS
	TypeName: PSOnyphe

	.EXAMPLE
	get inetnum info for subnet 93.184.208.0
	C:\PS> Invoke-APIOnypheInetnum -IP 93.184.208.0

	.EXAMPLE
	get inetnum info for subnet 93.184.208.0 and set the api key
	C:\PS> Invoke-APIOnypheInetnum -IP 93.184.208.0 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
  [cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
			[string]$IP, 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string]$Page,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/simple/inetnum/$($IP)"
			APIInfo = "inetnum"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	}
	}
	Function Invoke-APIOnyphePastries {
  <#
	.SYNOPSIS 
	create several input for Invoke-OnypheAPIV2 function and then call it to get the pastries (pastebin) info from pastries API

	.DESCRIPTION
	create several input for Invoke-OnypheAPIV2 function and then call it to get the pastries (pastebin) info from pastries API
	
	.PARAMETER IP
	-IP string{IP}
	IP to be used for the pastries API usage
	
	.PARAMETER APIKEY
	-APIKey string{APIKEY}
	Set APIKEY as global variable.

	.PARAMETER Page
	-page string{page number}
	go directly to a specific result page (1 to 1000)
	
	.OUTPUTS
	TypeName: PSOnyphe

	.EXAMPLE
	get all pastries info for IP 8.8.8.8
	C:\PS> Invoke-APIOnyphePastries -IP 8.8.8.8

	.EXAMPLE
	get all pastries info for IP 8.8.8.8 and set the api key
	C:\PS> Invoke-APIOnyphePastries -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
  [cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
			[string[]]$IP, 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string]$Page,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/simple/pastries/$($IP)"
			APIInfo = "patries"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	}
	}
	Function Invoke-APIOnypheSynScan {
    <#
	.SYNOPSIS 
	create several input for Invoke-OnypheAPIV2 function and then call it to get the syn scan info from synscan API

	.DESCRIPTION
	create several input for Invoke-OnypheAPIV2 function and then call it to get the syn scan info from synscan API
	
	.PARAMETER IP
	-IP string{IP}
	IP to be used for the geoloc API usage
	
	.PARAMETER APIKEY
	-APIKey string{APIKEY}
	Set APIKEY as global variable.

	.PARAMETER Page
	-page string{page number}
	go directly to a specific result page (1 to 1000)
	
	.OUTPUTS
	TypeName: PSOnyphe

	.EXAMPLE
	get syn scan info for IP 8.8.8.8
	C:\PS> Invoke-APIOnypheSynScan -IP 8.8.8.8

	.EXAMPLE
	get syn scan info for IP 8.8.8.8 and set the api key
	C:\PS> Invoke-APIOnypheSynScan -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
  [cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
			[string[]]$IP, 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string]$Page,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/simple/synscan/$($IP)"
			APIInfo = "synscan"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	}
	}
	Function Invoke-APIOnypheSniffer {
	<#
	.SYNOPSIS 
	create several input for Invoke-OnypheAPIV2 function and then call it to get the IP sniffer info from sniffer API

	.DESCRIPTION
	create several input for Invoke-OnypheAPIV2 function and then call it to get the IP sniffer info from sniffer API
	
	.PARAMETER IP
	-IP string{IP}
	IP to be used for the sniffer API usage
	
	.PARAMETER APIKEY
	-APIKey string{APIKEY}
	Set APIKEY as global variable.

	.PARAMETER Page
	-page string{page number}
	go directly to a specific result page (1 to 1000)
	
	.OUTPUTS
	TypeName: PSOnyphe

	.EXAMPLE
	get sniffer info for IP 217.138.28.194
	C:\PS> Invoke-APIOnypheSniffer -IP 217.138.28.194

	.EXAMPLE
	get sniffer info for IP 217.138.28.194 and set the api key
	C:\PS> Invoke-APIOnypheSniffer -IP 217.138.28.194 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
				[string[]]$IP, 
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateScript({$_ -match "^((?!0)\d+)$"})]
				[string]$Page,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "v2/simple/sniffer/$($IP)"
				APIInfo = "sniffer"
				APIInput = @("$($IP)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-APIOnypheCtl {
	<#
	.SYNOPSIS 
	create several input for Invoke-OnypheAPIV2 function and then call it to get the CTL (certificate transparancy) info from ctl API

	.DESCRIPTION
	create several input for Invoke-OnypheAPIV2 function and then call it to get the CTL (certificate transparancy) info from ctl API
	
	.PARAMETER Domain
	-Domain string{Domain or FQDN}
	Domain or FQDN to be used for the ctl API usage
	
	.PARAMETER APIKEY
	-APIKey string{APIKEY}
	Set APIKEY as global variable.

	.PARAMETER Page
	-page string{page number}
	go directly to a specific result page (1 to 1000)
	
	.OUTPUTS
	TypeName: PSOnyphe

	.EXAMPLE
	get CTL info for fnac.com
	C:\PS> Invoke-APIOnypheCtl -Domain fnac.com

	.EXAMPLE
	get CTL info for fnac.com and set the api key
	C:\PS> Invoke-APIOnypheCtl -Domain fnac.com -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$")})]
				[string[]]$Domain, 
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateScript({$_ -match "^((?!0)\d+)$"})]
				[string]$Page,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "v2/simple/ctl/$($Domain)"
				APIInfo = "ctl"
				APIInput = @("$($Domain)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-APIOnypheDatascanDataMD5 {
	<#
	.SYNOPSIS 
	create several input for Invoke-OnypheAPIV2 function and then call it to get info from onyphe md5 signature

	.DESCRIPTION
	create several input for Invoke-OnypheAPIV2 function and then call it to get info from onyphe md5 signature
	
	.PARAMETER MD5
	-MD5 string{MD5 Hash}
	MD5 to be used for the md5 API usage
	
	.PARAMETER APIKEY
	-APIKey string{APIKEY}
	Set APIKEY as global variable.

	.PARAMETER Page
	-page string{page number}
	go directly to a specific result page (1 to 1000)
	
	.OUTPUTS
	TypeName: PSOnyphe

	.EXAMPLE
	get md5 info for 7a1f20cae067b75a52bc024b83ee4667 hash
	C:\PS> Invoke-APIOnypheDatascanDataMd5 -MD5 7a1f20cae067b75a52bc024b83ee4667

	.EXAMPLE
	get md5 info for 7a1f20cae067b75a52bc024b83ee4667 hash and set the api key
	C:\PS> Invoke-APIOnypheDatascanDataMd5 -MD5 7a1f20cae067b75a52bc024b83ee4667 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "^[a-f0-9]{32}$")})]
				[string]$MD5, 
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateScript({$_ -match "^((?!0)\d+)$"})]
				[string]$Page,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "v2/simple/datascan/md5/$($MD5)"
				APIInfo = "md5"
				APIInput = @("$($MD5)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-APIOnypheOnionScan {
	<#
		.SYNOPSIS 
		create several input for Invoke-OnypheAPIV2 function and then call it to get info for a .onion link using OnionScan API

		.DESCRIPTION
		create several input for Invoke-OnypheAPIV2 function and then call it to get info for a .onion link using OnionScan API
		
		.PARAMETER Onion
		-Onion string{Onion URL}
		Onion link to be used for the Onion API usage
		
		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.

		.PARAMETER Page
		-page string{page number}
		go directly to a specific result page (1 to 1000)
		
		.OUTPUTS
		TypeName: PSOnyphe

		.EXAMPLE
		get md5 info for 3g2upl4pq6kufc4m.onion URL
		C:\PS> Invoke-APIOnypheOnionScan -Onion "3g2upl4pq6kufc4m.onion"

		.EXAMPLE
		get md5 info for 3g2upl4pq6kufc4m.onion URL and set the api key
		C:\PS> Invoke-APIOnypheOnionScan -Onion "3g2upl4pq6kufc4m.onion" -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "[a-z2-7]{16}\.onion") -or ($_ -match "[a-z2-7]{56}\.onion")})]
				[string]$Onion, 
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateScript({$_ -match "^((?!0)\d+)$"})]
				[string]$Page,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "v2/simple/onionscan/$($Onion)"
				APIInfo = "onionscan"
				APIInput = @("$($Onion)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-APIOnypheResolver {
		<#
			  .SYNOPSIS 
			  create several input for Invoke-OnypheAPIV2 function and then call it to get the resolver dns info from resolver API
	  
			  .DESCRIPTION
			  create several input for Invoke-OnypheAPIV2 function and then call it to get the resolver dns info from resolver API
			  
			  .PARAMETER IP
			  -IP string{IP}
			  IP to be used for the resolver API usage
			  
			  .PARAMETER APIKEY
			  -APIKey string{APIKEY}
			  Set APIKEY as global variable.
	  
			  .PARAMETER Page
			  -page string{page number}
			  go directly to a specific result page (1 to 1000)
			  
			  .OUTPUTS
			   TypeName: PSOnyphe
	  			  
			  .EXAMPLE
			  get dns info info for IP 8.8.8.8
			  C:\PS> Invoke-APIOnypheResolver -IP 8.8.8.8
	  
			  .EXAMPLE
			  get dns info info for IP 8.8.8.8 ans set the api key
			  C:\PS> Invoke-APIOnypheResolver -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		#>
		[cmdletbinding()]
		Param (
			  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			  [Alias("input")]
			  [ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
				  [string]$IP, 
			  [parameter(Mandatory=$false)]
			  [ValidateLength(40,40)]
				  [string]$APIKey,
			  [parameter(Mandatory=$false)]
			  [ValidateScript({$_ -match "^((?!0)\d+)$"})]
				  [string]$Page,
				[parameter(Mandatory=$false)]
				[ValidateNotNullOrEmpty()]
					[hashtable]$FuncInput
		)
		  Process {
			  if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			  $params = @{
				  request = "v2/simple/resolver/$($IP)"
				  APIInfo = "resolver"
				  APIInput = @("$($IP)")
				  APIKeyrequired = $true
			  }
			  if ($page) {$params.add('page',$page)}
			  if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			  Write-Verbose -message "URL Info : $($params.request)"
			  Invoke-OnypheAPIV2 @params
		  }
	}
	Function Invoke-APIOnypheResolverReverse {
  <#
		.SYNOPSIS 
		create several input for Invoke-OnypheAPIV2 function and then call it to get the reverse dns info from reverse API

		.DESCRIPTION
		create several input for Invoke-OnypheAPIV2 function and then call it to get the reverse dns info from reverse API
		
		.PARAMETER IP
		-IP string{IP}
		IP to be used for the reverse API usage
		
		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.

		.PARAMETER Page
		-page string{page number}
		go directly to a specific result page (1 to 1000)
		
		.OUTPUTS
		TypeName: PSOnyphe
		
		.EXAMPLE
		get reverse dns info info for IP 8.8.8.8
		C:\PS> Invoke-APIOnypheReverse -IP 8.8.8.8

		.EXAMPLE
		get reverse dns info info for IP 8.8.8.8 ans set the api key
		C:\PS> Invoke-APIOnypheResolverReverse -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
  [cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
			[string]$IP, 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string]$Page,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/simple/resolver/reverse/$($IP)"
			APIInfo = "reverse"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	}
	}
	Function Invoke-APIOnypheResolverForward {
  <#
		.SYNOPSIS 
		create several input for Invoke-OnypheAPIV2 function and then call it to get the dns forwarder info from forward API

		.DESCRIPTION
		create several input for Invoke-OnypheAPIV2 function and then call it to get the dns forwarder info from forward API
		
		.PARAMETER IP
		-IP string{IP}
		IP to be used for the forward API usage
		
		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.
		
		.PARAMETER Page
		-page string{page number}
		go directly to a specific result page (1 to 1000)
		
		.OUTPUTS
		TypeName: PSOnyphe
		
		.EXAMPLE
		get all forward dns info for IP 8.8.8.8
		C:\PS> Invoke-APIOnypheResolverForward -IP 8.8.8.8

		.EXAMPLE
		get all forward dns info for IP 8.8.8.8 ans set the api key
		C:\PS> Invoke-APIOnypheResolverForward -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
  [cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
			[string]$IP, 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string]$Page,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/simple/resolver/forward/$($IP)"
			APIInfo = "forward"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	}
	}
	Function Invoke-APIOnypheThreatlist {
  <#
		.SYNOPSIS 
		create several input for Invoke-OnypheAPIV2 function and then call it to get the threat info from threatlist API

		.DESCRIPTION
		create several input for Invoke-OnypheAPIV2 function and then call it to get the threat info from threatlist API
		
		.PARAMETER IP
		-IP string{IP}
		IP to be used for the threatlist API usage
		
		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.

		.PARAMETER Page
		-page string{page number}
		go directly to a specific result page (1 to 1000)
			
		.OUTPUTS
		TypeName: PSOnyphe

		.EXAMPLE
		get all threat info for IP 	201.111.50.232
		C:\PS> Invoke-APIOnypheThreatlist -IP 201.111.50.232

		.EXAMPLE
		get all threat info for IP 201.111.50.232 and set the api key
		C:\PS> Invoke-APIOnypheThreatlist -IP 201.111.50.232 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
  [cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
			[string]$IP, 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string]$Page,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/simple/threatlist/$($IP)"
			APIInfo = "threatlist"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	}
	}
	Function Invoke-APIOnypheTopSite {
		<#
			  .SYNOPSIS 
			  create several input for Invoke-OnypheAPIV2 function and then call it to get the threat info from topsite API
	  
			  .DESCRIPTION
			  create several input for Invoke-OnypheAPIV2 function and then call it to get the threat info from topsite API
			  
			  .PARAMETER IP
			  -IP string{IP}
			  IP to be used for the topsite API usage
			  
			  .PARAMETER APIKEY
			  -APIKey string{APIKEY}
			  Set APIKEY as global variable.
	  
			  .PARAMETER Page
			  -page string{page number}
			  go directly to a specific result page (1 to 1000)
				  
			  .OUTPUTS
			  TypeName: PSOnyphe
	  
			  .EXAMPLE
			  get all topsite info for IP 178.250.241.22
			  C:\PS> Invoke-APIOnypheTopsite -IP 178.250.241.22
	  
			  .EXAMPLE
			  get all topsite info for IP 178.250.241.22 and set the api key
			  C:\PS> Invoke-APIOnypheTopsite -IP 178.250.241.22 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		#>
		[cmdletbinding()]
		Param (
			  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			  [Alias("input")]
			  [ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
				  [string]$IP, 
			  [parameter(Mandatory=$false)]
			  [ValidateLength(40,40)]
				  [string]$APIKey,
			  [parameter(Mandatory=$false)]
			  [ValidateScript({$_ -match "^((?!0)\d+)$"})]
				  [string]$Page,
				[parameter(Mandatory=$false)]
				[ValidateNotNullOrEmpty()]
					[hashtable]$FuncInput
		)
		  Process {
			  if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			  $params = @{
				  request = "v2/simple/topsite/$($IP)"
				  APIInfo = "topsite"
				  APIInput = @("$($IP)")
				  APIKeyrequired = $true
			  }
			  if ($page) {$params.add('page',$page)}
			  if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			  }
			  Write-Verbose -message "URL Info : $($params.request)"
			  Invoke-OnypheAPIV2 @params
		  }
	}
	Function Invoke-APIOnypheVulnscan {
		<#
			  .SYNOPSIS 
			  create several input for Invoke-OnypheAPIV2 function and then call it to get the CVe info from vulnscan API
	  
			  .DESCRIPTION
			  create several input for Invoke-OnypheAPIV2 function and then call it to get the CVE info from vulnscan API
			  
			  .PARAMETER IP
			  -IP string{IP}
			  IP to be used for the vulnscan API usage
			  
			  .PARAMETER APIKEY
			  -APIKey string{APIKEY}
			  Set APIKEY as global variable.
	  
			  .PARAMETER Page
			  -page string{page number}
			  go directly to a specific result page (1 to 1000)
				  
			  .OUTPUTS
			  TypeName: PSOnyphe
	  
			  .EXAMPLE
			  get all CVE info for IP 178.250.241.22
			  C:\PS> Invoke-APIOnypheVulnscan -IP 178.250.241.22
	  
			  .EXAMPLE
			  get all CVE info for IP 178.250.241.22 and set the api key
			  C:\PS> Invoke-APIOnypheVulnscan -IP 178.250.241.22 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		#>
		[cmdletbinding()]
		Param (
			  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			  [Alias("input")]
			  [ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
				  [string]$IP, 
			  [parameter(Mandatory=$false)]
			  [ValidateLength(40,40)]
				  [string]$APIKey,
			  [parameter(Mandatory=$false)]
			  [ValidateScript({$_ -match "^((?!0)\d+)$"})]
				  [string]$Page,
				[parameter(Mandatory=$false)]
				[ValidateNotNullOrEmpty()]
					[hashtable]$FuncInput
		)
		  Process {
			  if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			  $params = @{
				  request = "v2/simple/vulnscan/$($IP)"
				  APIInfo = "vulnscan"
				  APIInput = @("$($IP)")
				  APIKeyrequired = $true
			  }
			  if ($page) {$params.add('page',$page)}
			  if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			  }
			  Write-Verbose -message "URL Info : $($params.request)"
			  Invoke-OnypheAPIV2 @params
		  }
	}
	Function Invoke-APIOnypheDataScan {
  <#
		.SYNOPSIS 
		create several input for Invoke-OnypheAPIV2 function and then call it to get the data scan info from datascan API

		.DESCRIPTION
		create several input for Invoke-OnypheAPIV2 function and then call it to get the data scan info from datascan API
		
		.PARAMETER IPOrDataScanString
		-IPOrDataScanString string{IP}
		IP to be used for the DataScan API usage
		-IPOrDataScanString string
		string to be used for the DataScan API usage

		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.

		.PARAMETER Page
		-page string{page number}
		go directly to a specific result page (1 to 1000)
		
		.OUTPUTS
		TypeName: PSOnyphe

		.EXAMPLE
		get all data scan info for IP 27.251.29.154
		C:\PS> Invoke-APIOnypheDataScan -IPOrDataScanString 27.251.29.154

		.EXAMPLE
		get all info for info available for PanWeb web server
		C:\PS> Invoke-APIOnypheDataScan -IPOrDataScanString "PanWeb"

		.EXAMPLE
		get all data scan info for IP 27.251.29.154 and set the api key
		C:\PS> Invoke-APIOnypheDataScan -IPOrDataScanString 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #> 
 [cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateNotNullOrEmpty()]
			[string]$IPOrDataScanString,
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string]$Page,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
  )
	Process {
		$script:DateRequest = get-date
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/simple/datascan/$($IPOrDataScanString)"
			APIInput = "$($IPOrDataScanString)"
			APIInfo = "datascan"
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	}
	}
	Function Invoke-APIOnypheDataShot {
	<#
		.SYNOPSIS 
		create several input for Invoke-OnypheAPIV2 function and then call it to get the threat info from Datashot API

		.DESCRIPTION
		create several input for Invoke-OnypheAPIV2 function and then call it to get the threat info from Datashot API
		
		.PARAMETER IP
		-IP string{IP}
		IP to be used for the Datashot API usage
		
		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.

		.PARAMETER Page
		-page string{page number}
		go directly to a specific result page (1 to 1000)
			
		.OUTPUTS
		TypeName: PSOnyphe

		.EXAMPLE
		get all datashot for IP 178.250.241.22
		C:\PS> Invoke-APIOnypheDatashot -IP 178.250.241.22

		.EXAMPLE
		get all datashot for IP 178.250.241.22 and set the api key
		C:\PS> Invoke-APIOnypheDatashot -IP 178.250.241.22 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
		[cmdletbinding()]
		Param (
			  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			  [Alias("input")]
			  [ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
				  [string]$IP, 
			  [parameter(Mandatory=$false)]
			  [ValidateLength(40,40)]
				  [string]$APIKey,
			  [parameter(Mandatory=$false)]
			  [ValidateScript({$_ -match "^((?!0)\d+)$"})]
				  [string]$Page,
				[parameter(Mandatory=$false)]
				[ValidateNotNullOrEmpty()]
					[hashtable]$FuncInput
		)
		  Process {
			  if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			  $params = @{
				  request = "v2/simple/datashot/$($IP)"
				  APIInfo = "datashot"
				  APIInput = @("$($IP)")
				  APIKeyrequired = $true
			  }
			  if ($page) {$params.add('page',$page)}
			  if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			  }
			  Write-Verbose -message "URL Info : $($params.request)"
			  Invoke-OnypheAPIV2 @params
		  }
	}
	Function Invoke-APIOnypheOnionShot {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-OnypheAPIV2 function and then call it to get the threat info from Onionshot API

	  .DESCRIPTION
	  create several input for Invoke-OnypheAPIV2 function and then call it to get the threat info from Onionshot API
	  
	  .PARAMETER IP
	  -IP string{IP}
	  IP to be used for the Onionshot API usage
	  
	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
	  Set APIKEY as global variable.

	  .PARAMETER Page
	  -page string{page number}
	  go directly to a specific result page (1 to 1000)
		  
	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  get all onionshot for IP 178.250.241.22
	  C:\PS> Invoke-APIOnypheOnionshot -IP 178.250.241.22

	  .EXAMPLE
	  get all onionshot for IP 178.250.241.22 and set the api key
	  C:\PS> Invoke-APIOnypheOnionshot -IP 178.250.241.22 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#>
	  [cmdletbinding()]
	  Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
				[string]$IP, 
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateScript({$_ -match "^((?!0)\d+)$"})]
				[string]$Page,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
	  )
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "v2/simple/onionshot/$($IP)"
				APIInfo = "onionshot"
				APIInput = @("$($IP)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV2 @params
		}
    }
    Function Invoke-APIOnypheGeoloc {
	<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the Geoloc info from Geoloc API
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the Geoloc info from Geoloc API
		  
		  .PARAMETER IP
		  -IP string{IP}
		  IP to be used for the geoloc API usage
		  
		  .OUTPUTS
		  TypeName: PSOnyphe
		  
		  .EXAMPLE
		  get geoloc info for IP 8.8.8.8
		  C:\PS> Invoke-APIOnypheGeoloc -IP 8.8.8.8
	#> 
  [cmdletbinding()]
	Param (
		  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		  [Alias("input")]
		  [ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
			  [string]$IP,
		  [parameter(Mandatory=$false)]
		  [ValidateLength(40,40)]
			  [string]$APIKey,
		  [parameter(Mandatory=$false)]
		  [ValidateScript({$_ -match "^((?!0)\d+)$"})]
			  [string]$Page,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
	)
	process {
		 if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null} 
		 $params = @{
			  request = "v2/simple/geoloc/$($IP)"
			  APIInfo = "geoloc"
			  APIInput = @("$($IP)")
			  APIKeyrequired = $true
		  }
		  if ($page) {$params.add('page',$page)}
		  if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		  }
		  Write-Verbose -message "URL Info : $($params.request)"
		  Invoke-OnypheAPIV2 @params
	}
	}
	Function Invoke-APISummaryOnypheIP {
	<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an IP from Geoloc Summary/IP API
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an IP from Geoloc Summary/IP API
		  
		  .PARAMETER IP
		  -IP string{IP}
		  IP to be used for the Summary/IP API usage

		  .PARAMETER APIKEY
		 -APIKey string{APIKEY}
		 Set APIKEY as global variable.

	      .PARAMETER Page
	      -page string{page number}
	      go directly to a specific result page (1 to 1000)

		  .OUTPUTS
		  TypeName: PSOnyphe
		  
		  .EXAMPLE
		  get all onyphe info for IP 8.8.8.8
		  C:\PS> Invoke-APISummaryOnypheIP -IP 8.8.8.8

		  .EXAMPLE
		  get all onyphe info for IP 8.8.8.8 and set the API Key
		  C:\PS> Invoke-APISummaryOnypheIP -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	#> 
		[cmdletbinding()]
		Param (
			  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			  [Alias("input")]
			  [ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
				  [string]$IP,
			  [parameter(Mandatory=$false)]
			  [ValidateLength(40,40)]
				  [string]$APIKey,
			  [parameter(Mandatory=$false)]
			  [ValidateScript({$_ -match "^((?!0)\d+)$"})]
				  [string]$Page,
				[parameter(Mandatory=$false)]
				[ValidateNotNullOrEmpty()]
					[hashtable]$FuncInput
		)
		process {
			 if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null} 
			 $params = @{
				  request = "v2/summary/ip/$($IP)"
				  APIInfo = "summary/ip"
				  APIInput = @("$($IP)")
				  APIKeyrequired = $true
			  }
			  if ($page) {$params.add('page',$page)}
			  if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			  }
			  Write-Verbose -message "URL Info : $($params.request)"
			  Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-APISummaryOnypheHostname {
	<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an hostname from Geoloc Summary/hostname API
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an hostname from Geoloc Summary/hostname API
		  
		  .PARAMETER Hostname
		  -Hostname string{Hostname}
		  Hostname to be used for the Summary/hostname API usage

		  .PARAMETER APIKEY
		 -APIKey string{APIKEY}
		 Set APIKEY as global variable.

	      .PARAMETER Page
	      -page string{page number}
	      go directly to a specific result page (1 to 1000)

		  .OUTPUTS
		  TypeName: PSOnyphe
		  
		  .EXAMPLE
		  get all onyphe info for hostname www.perdu.com
		  C:\PS> Invoke-APISummaryOnypheHostname -Hostname www.perdu.com

		  .EXAMPLE
		  get all onyphe info for hostname www.perdu.com and set the API Key
		  C:\PS> Invoke-APISummaryOnypheHostname -Hostname www.perdu.com -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	#> 
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$")})]
				[string]$Hostname, 
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateScript({$_ -match "^((?!0)\d+)$"})]
				[string]$Page,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "v2/summary/hostname/$($Hostname)"
				APIInfo = "summary/hostname"
				APIInput = @("$($Hostname)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-APISummaryOnypheDomain {
	<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an internet domain from Geoloc Summary/domain API
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an internet domain from Geoloc Summary/domain API
		  
		  .PARAMETER Domain
		  -Domain string{Domain}
		  Domain to be used for the Summary/domain API API usage

		  .PARAMETER APIKEY
		 -APIKey string{APIKEY}
		 Set APIKEY as global variable.

	      .PARAMETER Page
	      -page string{page number}
	      go directly to a specific result page (1 to 1000)

		  .OUTPUTS
		  TypeName: PSOnyphe
		  
		  .EXAMPLE
		  get all onyphe info for domain perdu.com
		  C:\PS> Invoke-APISummaryOnypheDomain -Domain perdu.com

		  .EXAMPLE
		  get all onyphe info for domain perdu.com and set the API Key
		  C:\PS> Invoke-APISummaryOnypheDomain -Domain perdu.com -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	#> 
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$")})]
				[string]$Domain, 
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateScript({$_ -match "^((?!0)\d+)$"})]
				[string]$Page,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "v2/summary/domain/$($Domain)"
				APIInfo = "summary/domain"
				APIInput = @("$($Domain)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-APIBulkSummaryOnypheIP {
		<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an array of IPs based on a file input from Bulk/ip API
		  .DESCRIPTION
		  reate several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an array of IPs based on a file input from Bulk/ip API
		  
		  .PARAMETER FilePath
		  -FilePath string{full path to an existing text file}
		  full path to input file to send to onyphe API

		  .PARAMETER OutFile
		  -OutFile string{full path to a new file for exporting json data}
		  full path to output file used to write json data from Onyphe

		  .PARAMETER APIKEY
		  -APIKey string{APIKEY}
		  Set APIKEY as global variable.

		  .OUTPUTS
		  TypeName: PSOnyphe
		  
		  .EXAMPLE
		  export all info available as JSON for all IPs contained in listip.txt
		  C:\PS> Invoke-APIBulkSummaryOnypheIP -FilePath .\listip.txt

		  .EXAMPLE
		  export all info available as JSON for all IPs contained in listip.txt and set the API Key
		  C:\PS> Invoke-APIBulkSummaryOnypheIP -FilePath .\listip.txt -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	#>
		[cmdletbinding()]
		Param (
			  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			  [Alias("input")]
			  [ValidateScript({(test-path $_)})]
				  [string]$FilePath,
			  [parameter(Mandatory=$true)]
			  [ValidateScript({!(test-path $_)})]
				  [string]$OutFile,
			  [parameter(Mandatory=$false)]
			  [ValidateLength(40,40)]
				  [string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		process {
			 if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null} 
			 $params = @{
				  request = "v2/bulk/summary/ip"
				  APIInfo = "bulk/summary/ip"
				  APIInput = @("File:$($filepath)")
				  file = $FilePath
				  APIKeyrequired = $true
				  Stream = $true
				  OutFile = $OutFile
			  }
			  if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			  }
			  Write-Verbose -message "URL Info : $($params.request)"
			  write-verbose -message "File uploaded to Onyphe API : $($FilePath)"
			  write-verbose -message "JSON Data exported to : $($OutFile)"
			  Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-APIBulkSummaryOnypheHostname {
		<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an array of hostnames based on a file input from Bulk/hostname API
		  .DESCRIPTION
		  reate several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an array of hostnames based on a file input from Bulk/hostname API
		  
		  .PARAMETER FilePath
		  -FilePath string{full path to an existing text file}
		  full path to input file to send to onyphe API

		  .PARAMETER OutFile
		  -OutFile string{full path to a new file for exporting json data}
		  full path to output file used to write json data from Onyphe

		  .PARAMETER APIKEY
		 -APIKey string{APIKEY}
		 Set APIKEY as global variable.

		  .OUTPUTS
		  TypeName: PSOnyphe
		  
		  .EXAMPLE
		  export all info available as JSON for all hosts contained in listhost.txt
		  C:\PS> Invoke-APIBulkSummaryOnypheHostname -FilePath .\listhost.txt

		  .EXAMPLE
		  export all info available as JSON for all hosts contained in listhost.txt and set the API Key
		  C:\PS> Invoke-APIBulkSummaryOnypheHostname -FilePath .\listhost.txt -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	#>
		[cmdletbinding()]
		Param (
			  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			  [Alias("input")]
			  [ValidateScript({(test-path $_)})]
					[string]$FilePath,
			[parameter(Mandatory=$true)]
			[ValidateScript({!(test-path $_)})]
				[string]$OutFile,
			  [parameter(Mandatory=$false)]
			  [ValidateLength(40,40)]
				  [string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		process {
			 if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null} 
			 $params = @{
				  request = "v2/bulk/summary/hostname"
				  APIInfo = "bulk/summary/hostname"
				  APIInput = @("File:$($filepath)")
				  file = $FilePath
				  APIKeyrequired = $true
				  Stream = $true
				  OutFile = $OutFile
			  }
			  if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			  }
			  Write-Verbose -message "URL Info : $($params.request)"
			  write-verbose -message "File uploaded to Onyphe API : $($FilePath)"
			  write-verbose -message "JSON Data exported to : $($OutFile)"
			  Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-APIBulkSummaryOnypheDomain {
		<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an array of domains based on a file input from Bulk/domain API
		  .DESCRIPTION
		  reate several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an array of domains based on a file input from Bulk/domain API
		  
		  .PARAMETER FilePath
		  -FilePath string{full path to an existing text file}
		  full path to input file to send to onyphe API

		  .PARAMETER OutFile
		  -OutFile string{full path to a new file for exporting json data}
		  full path to output file used to write json data from Onyphe

		  .PARAMETER APIKEY
		 -APIKey string{APIKEY}
		 Set APIKEY as global variable.

		  .OUTPUTS
		  TypeName: PSOnyphe
		  
		  .EXAMPLE
		  export all info available as JSON for all domains contained in listdom.txt
		  C:\PS> Invoke-APIBulkSummaryOnypheDomain -FilePath .\listdom.txt

		  .EXAMPLE
		  export all info available as JSON for all domains contained in listdom.txt and set the API Key
		  C:\PS> Invoke-APIBulkSummaryOnypheDomain -FilePath .\listdom.txt -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	#>
		[cmdletbinding()]
		Param (
			  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			  [Alias("input")]
			  [ValidateScript({(test-path $_)})]
					[string]$FilePath,
			[parameter(Mandatory=$true)]
			[ValidateScript({!(test-path $_)})]
				[string]$OutFile,
			  [parameter(Mandatory=$false)]
			  [ValidateLength(40,40)]
				  [string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput
		)
		process {
			 if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null} 
			 $params = @{
				  request = "v2/bulk/summary/domain"
				  APIInfo = "bulk/summary/domain"
				  APIInput = @("File:$($filepath)")
				  file = $FilePath
				  APIKeyrequired = $true
				  Stream = $true
				  OutFile = $OutFile
			  }
			  if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			  }
			  Write-Verbose -message "URL Info : $($params.request)"
			  write-verbose -message "File uploaded to Onyphe API : $($FilePath)"
			  write-verbose -message "JSON Data exported to : $($OutFile)"
			  Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-OnypheAPIV2 {
	[cmdletbinding()]
	Param (
		  [parameter(Mandatory=$true)]
		  [ValidateNotNullOrEmpty()]  
			  [string[]]$request,
		  [parameter(Mandatory=$false)]
		  [ValidateNotNullOrEmpty()]  
			  [string[]]$data,
		  [parameter(Mandatory=$false)]
		  [ValidateNotNullOrEmpty()]  
			  [string]$file,
		  [parameter(Mandatory=$false)]
		  [Validateset("GET","POST")]
			  [string]$Method = "GET",
		  [parameter(Mandatory=$true)]
		  [ValidateNotNullOrEmpty()]  
			  [string[]]$APIInfo,
		  [parameter(Mandatory=$true)]
		  [ValidateNotNullOrEmpty()]  
			  [string[]]$APIInput,
		  [parameter(Mandatory=$true)]
			  [Bool]$APIKeyrequired,
		  [parameter(mandatory=$false)]
		  [ValidateNotNullOrEmpty()]
		  	  [hashtable]$FuncInput,
		  [parameter(Mandatory=$false)]
		  [ValidateScript({$_ -match "^((?!0)\d+)$"})] 
			  [string[]]$page,
		  [parameter(Mandatory=$false)]
			  [switch]$UseBetaFeatures,
		  [parameter(Mandatory=$false)]
			  [switch]$Stream,
		  [parameter(Mandatory=$false)]
		  	  [string]$OutFile
	)
	Process {
	  if ($UseBetaFeatures) {
		  $script:onypheurl = "https://test.onyphe.io/api/"
		  write-verbose -message "using beta Onyphe service - https://test.onyphe.io"
	  } else {
		  $script:onypheurl = "https://www.onyphe.io/api/"
		  write-verbose -message "using production Onyphe service - https://www.onyphe.io"
	  }
	  $script:DateRequest = get-date
	  if (($APIKeyrequired)-and(!$global:OnypheAPIKey)) {
		  write-verbose -message "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
		  throw "Please provide an APIKey with -APIKEY parameter"
	  }
	  try {
		  $fullonypheurl = "$($onypheurl)$($request)"
		  if ($page) {
			  $fullonypheurl = "$($fullonypheurl)?page=$($page)"
		  }
		  if ($global:OnypheProxyParams) {
			  $params = $global:OnypheProxyParams.clone()
			  If (!$params.UseBasicParsing){
				  $params.add('UseBasicParsing', $true)
			  }
			  If (!$params.URI) {
				  $params.add('URI', "$($fullonypheurl)")
			  } Else {
				  $params['URI'] = "$($fullonypheurl)"
			  }
		  } Else {
			  $params = @{}
			  $params.add('UseBasicParsing', $true)
			  $params.add('URI', "$($fullonypheurl)")
		  }
		  if ($UseBetaFeatures) {
			  if ($host.Version.Major -lt 6) {
				  try {
				  if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
					  $certCallback = @"
							  using System;
							  using System.Net;
							  using System.Net.Security;
							  using System.Security.Cryptography.X509Certificates;
							  public class ServerCertificateValidationCallback
							  {
									  public static void Ignore()
									  {
											  if(ServicePointManager.ServerCertificateValidationCallback ==null)
											  {
													  ServicePointManager.ServerCertificateValidationCallback += 
															  delegate
															  (
																	  Object obj, 
																	  X509Certificate certificate, 
																	  X509Chain chain, 
																	  SslPolicyErrors errors
															  )
															  {
																	  return true;
															  };
											  }
									  }
							  }
"@
						  Add-Type $certCallback
				  }
				  [ServerCertificateValidationCallback]::Ignore()
				  } catch {
					  throw "impossible to add a new type, check your PowerShell Constrained Language settings or run PowerShell as Admin"
				  }
			  } else {
				  $params.add('SkipCertificateCheck', $true)
			  }
		  }
		  if ($data) {
			  $params.add('Method','Post')
			  $params.add('Body', $data)
			  $params.add('ContentType', 'application/json') 
		  }
		  if ($file) {
			$params.add('Method','Post')
			$params.add('Infile', $file)
			$params.add('ContentType', 'application/json') 
		  }
		  if (($Method -eq "POST") -and !$params.Method) {
			  $params.add('Method','Post') 
		  }
		  if ($APIKeyrequired) {
			  $params.add('Headers', @{'Authorization' = 'apikey {0}' -f $global:OnypheAPIKey}) 
		  }
		  if ($Stream -and $OutFile) {
			$params.add('OutFile', $OutFile)
		  }
		  write-verbose -message "Request Headers : $($params.Headers | out-string)"
		  $onypheresult = invoke-webrequest @params
	  } catch {
			  write-verbose -message "Not able to use onyphe online service - KO"
			  write-verbose -message "Error Type: $($_.Exception.GetType().FullName)"
			  write-verbose -message "Error Message: $($_.Exception.Message)"
			  write-verbose -message "HTTP error code:$($_.Exception.Response.StatusCode.Value__)"
			  write-verbose -message "HTTP error message:$($_.Exception.Response.StatusDescription)"
			  $errorcode = $_.Exception.Response.StatusCode.value__
			  if (($errorcode -eq 429) -or ($errorcode -eq 200) -or ($errorcode -eq 400)) {
				  if ($_.ErrorDetails.Message) {
					  $errorvalue = $_.ErrorDetails.Message | Convertfrom-Json
				  } elseif (get-member -InputOnypheObject $_.Exception.Response -MemberType Method | Where-Object {$_.name -eq "GetResponseStream"}){
					$result = $_.Exception.Response.GetResponseStream()
					$reader = New-Object System.IO.StreamReader($result)
					$reader.BaseStream.Position = 0
					$httpbody = $reader.ReadToEnd()
					$errorvalue = $httpbody | Convertfrom-Json
				  } else {
					$errorvalue = [PSCustomObject]@{}
				  }
			  } else {
				  $errorvalue = [PSCustomObject]@{
					  Count = 0
					  error = ""
					  myip = 0
					  results = ''
					  'cli-error_results' = "$($_.Exception.GetType().FullName) - $($_.Exception.Message) : $($onypheresult.Content)"
					  status = "ko"
					  took = 0
					  total = 0
				  }
			  }
	  }
	  if ((-not $errorvalue) -and $onypheresult.Content) {
			write-verbose -message "Response Headers : $($onypheresult.Headers | out-string)"  
			write-verbose -message "Web Content : $($onypheresult.Content)"
			$reqresult = $onypheresult.Content
	   } else {
		$reqresult = $null
	   }
	   if ($errorvalue) {
			  $errorvalue.PSObject.TypeNames.Insert(0,"PSOnyphe")
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_info' -Value $APIInfo
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_input' -Value $APIInput
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_version' -Value "2"
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-key_required' -Value $APIKeyrequired
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-Request_Date' -Value $script:DateRequest
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-func_input' -value $FuncInput
			  $defaultDisplaySet = $errorvalue.psobject.properties.name | Where-Object {$_ -notlike "cli-*"}
			  $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet",[string[]]$defaultDisplaySet)
			  $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
			  $errorvalue | Add-Member MemberSet PSStandardMembers $PSStandardMembers
			  $errorvalue
		} elseif ($reqresult) {
				$tempobj = $reqresult | Convertfrom-Json
				$tempobj.PSObject.TypeNames.Insert(0,"PSOnyphe")
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-API_info' -Value $APIInfo
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-API_input' -Value $APIInput
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-API_version' -Value "2"
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-key_required' -Value $APIKeyrequired
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-Request_Date' -Value $script:DateRequest
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-func_input' -value $FuncInput
				$defaultDisplaySet = $tempobj.psobject.properties.name | Where-Object {$_ -notlike "cli-*"}
				$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet",[string[]]$defaultDisplaySet)
				$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
				$tempobj | Add-Member MemberSet PSStandardMembers $PSStandardMembers
				$tempobj
		}
	  }
	}
	Function Export-OnypheInfoToFile {
	<#
		.SYNOPSIS 
		Export psobject containing Onyphe info to files

		.DESCRIPTION
		Export psobject containing Onyphe info to files
		One root folder is created and a dedicated csv file is created by category.
		Note : for the datascan category, the data attribute content is exported in a separated text file to be more readable.
		Note 2 : in this version, there is an issue if you pipe a psobject containing an array of onyphe result to the function. to be investigated.

		.PARAMETER tofolder
		-tofolcer string{target folder}
		path to the target folder where you want to export onyphe data

		.PARAMETER InputOnypheObject
		-InputOnypheObject $obj{output of Get-OnypheInfo or Get-OnypheInfoFromCSV functions}
		look for information about my public IP

		.PARAMETER csvdelimiter
		-csvdelimiter string{csv separator}
		set your csv separator. default is ;
			
		.OUTPUTS
		none
		
		.EXAMPLE
		Exporting onyphe results containing into $onypheresult object to flat files in folder C:\temp
		C:\PS> Export-OnypheInfoToFile -tofolder C:\temp -InputOnypheObject $onypheresult

		.EXAMPLE
		Exporting onyphe results containing into $onypheresult object to flat files in folder C:\temp using ',' as csv separator
		C:\PS> Export-OnypheInfoToFile -tofolder C:\temp -InputOnypheObject $onypheresult -csvdelimiter ","
	#>
  [cmdletbinding()]
  Param (
  [parameter(Mandatory=$true)]
  [ValidateScript({test-path "$($_)"})]
		$tofolder,
  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
  [ValidateScript({($_ -is [System.Management.Automation.PSCustomObject]) -or ($_ -is [Deserialized.System.Management.Automation.PSCustomObject])})]
		[array]$InputOnypheObject,
  [parameter(Mandatory=$false)]
    $csvdelimiter
  )
  process {
	if (!$csvdelimiter) {$csvdelimiter = ";"}
	$ticks = (get-date).ticks.ToString()
	If ($InputOnypheObject.'cli-API_info') {
		$tmpinputobject = [Management.Automation.PSSerializer]::Serialize($InputOnypheObject)
		$InputOnypheObject = [Management.Automation.PSSerializer]::DeSerialize($tmpinputobject)
	} else {
		throw "invalid Onyphe PSObject provided"
	}
	foreach ($result in $InputOnypheObject) {
	  $tempfolder = $null
	  $tempattrib = $result.'cli-API_input' -replace ("[{0}]"-f (([System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object {[regex]::Escape($_)}) -join '|')),'_'
	  $tempfolder = "Onyphe-result-$($tempattrib)"
	  $tempfolder = join-path $tofolder $tempfolder
	  if (!(test-path $tempfolder)) {mkdir $tempfolder -force | out-null}
	  $ticks = (get-date).ticks.ToString()
	  $result | Export-Csv -NoTypeInformation -path "$($tempfolder)\$($ticks)_request_info.csv" -delimiter $csvdelimiter
	  if ($result.ip) {$ip = $result.ip.tostring()}
	  switch ($result.results.'@category') {
		  'geoloc' {
			  $filteredobj = $result.results | where-object {$_.'@category' -eq 'geoloc'} | sort-object -property country
			  $tempfilename = join-path $tempfolder "$($ticks)_$($ip)_Geoloc.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'inetnum' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'inetnum'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_inetnum.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'synscan' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'synscan'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_synscan.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'resolver'{
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'resolver'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_resolver.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'threatlist' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'threatlist'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_threatlist.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'pastries' {
			  $filteredobj = $result.results | where-object {$_.'@category' -eq 'pastries'} | sort-object -property seen_date
			  $tempfilename = join-path $tempfolder "$($ticks)_$($ip)_Pastries.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			  foreach ($contentresult in $filteredobj) {
				  if ($contentresult.ip.count -gt 1) {
					  $ip = "multips-$($contentresult.ip[0].Replace(":","-"))"
					  $allip = $contentresult.ip -join ","
				  } else {
					  $ip = $contentresult.ip
				  }
				  $tempfilecontentresult = "$($ticks)_$($ip)_pastries_$($contentresult.key).txt"
					$tempcontentexportfile = join-path $tempfolder $tempfilecontentresult
				  if ($allip) {
					  set-content -path $tempcontentexportfile -value "########### info ip ###########"
					  add-content -path $tempcontentexportfile -value $allip
					  add-content -path $tempcontentexportfile -value "########### info ip ###########"
				  }
				  $contentresult.content | add-content -path $tempcontentexportfile
			  }
		  }
		  'sniffer' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'sniffer'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_Sniffer.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'datascan' {
			  $filteredobj = $result.results | where-object {$_.'@category' -eq 'datascan'} | sort-object -property seen_date
			  $tempfilename = join-path $tempfolder "$($ticks)_$($ip)_datascan.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			  foreach ($dataresult in $filteredobj) {
				  if ($dataresult.ip.count -gt 1) {
					  $ip = "multips-$($dataresult.ip[0].Replace(":","-"))"
					  $allip = $dataresult.ip -join ","
				  } else {
					  $ip = $dataresult.ip
				  }
				  $tempfiledataresult = "$($ticks)_$($ip)_$($dataresult.port)_$($dataresult.protocol).txt"
					$tempdataexportfile = join-path $tempfolder $tempfiledataresult
				  if ($allip) {
					  set-content -path $tempdataexportfile -value "########### info ip ###########"
					  add-content -path $tempdataexportfile -value $allip
					  add-content -path $tempdataexportfile -value "########### info ip ###########"
				  }
				  $dataresult.data | add-content -path $tempdataexportfile
			  }
		  }
		  'onionscan' {
			  $filteredobj = $result.results | where-object {$_.'@category' -eq 'onionscan'} | sort-object -property seen_date
			  $tempfilename = join-path $tempfolder "$($ticks)_$($ip)_onionscan.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			  foreach ($dataresult in $filteredobj) {
				  if ($dataresult.ip.count -gt 1) {
					  $ip = "multips-$($dataresult.ip[0].Replace(":","-"))"
					  $allip = $dataresult.ip -join ","
				  } else {
					  $ip = $dataresult.ip
				  }
				  $tempfiledataresult = "$($ticks)_$($ip)_$($dataresult.port)_$($dataresult.protocol).txt"
				  $tempdataexportfile = join-path $tempfolder $tempfiledataresult
					if ($allip) {
					  set-content -path $tempdataexportfile -value "########### info ip ###########"
					  add-content -path $tempdataexportfile -value $allip
					  add-content -path $tempdataexportfile -value "########### info ip ###########"
				  }
				  $dataresult.data | add-content -path $tempdataexportfile
			  }
			}
			'ctl' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'ctl'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_ctl.csv"
			  	$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			}
			'datashot' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'datashot'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_datashot.csv"
				$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
				Export-OnypheDataShot -tofolder $tempfolder -InputOnypheObject $result
			}
			'vulnscan' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'vulnscan'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_vulnscan.csv"
			  	$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			}
			'topsite' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'topsite'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_topsite.csv"
			  	$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			}
	  }
	}
  }
	}
	Function Get-ScriptDirectory {
	<#
		.SYNOPSIS 
		retrieve current script directory

		.DESCRIPTION
		retrieve current script directory
	#>
		[cmdletbinding()]
		Param ()
		if ($psISE) {
			$ScriptPath = Split-Path -Parent $psISE.CurrentFile.FullPath
		} elseif($PSVersionTable.PSVersion.Major -gt 3) {
			$ScriptPath = $PSScriptRoot
		} else {
			$ScriptPath = split-path -parent $MyInvocation.MyCommand.Path
		}
		$ScriptPath
	}
	Function Set-OnypheAPIKey {
  <#
		.SYNOPSIS 
		set and remove onyphe API key as global variable

		.DESCRIPTION
		set and remove onyphe API key as global variable
		
		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.

		.PARAMETER MasterPassword
		-MasterPassword SecureString{Password}
		Use a passphrase for encryption purpose.

		.PARAMETER EncryptKeyInLocalFile
		-EncryptKeyInLocalFile
		Store APIKey in encrypted value on local drive
		
		.PARAMETER Remove
		-Remove
		Remove your current APIKEY from global variable.
		
		.OUTPUTS
		none
		
		.EXAMPLE
		Set your API key as global variable so it will be used automatically by all use-onyphe functions
		C:\PS> Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		
		.EXAMPLE
		Remove your API key set as global variable
		C:\PS> Set-OnypheAPIKey -remove

		.EXAMPLE
		Store your API key on hard drive
		C:\PS> Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -MasterPassword (ConvertTo-SecureString -String "YourP@ssw0rd" -AsPlainText -Force) -EncryptKeyInLocalFile
  #>
  [cmdletbinding()]
  Param (
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$Remove,
		[parameter(Mandatory=$false)]
			[switch]$EncryptKeyInLocalFile,
		[parameter(Mandatory=$false)]
			[securestring]$MasterPassword
  )
  process {
	if ($Remove.IsPresent) {
		$global:OnypheAPIKey = $Null
	  } Else {
		$global:OnypheAPIKey = $APIKey
		If ($EncryptKeyInLocalFile.IsPresent) {
			If (!$MasterPassword -or !$APIKey) {
				Write-warning "Please provide a valid Master Password to protect the API Key storage on disk and a valid API Key"
				throw 'no api key or master password'
			} Else {
				[Security.SecureString]$SecureKeyString = ConvertTo-SecureString -String $APIKey -AsPlainText -Force
				$SaltBytes = New-Object byte[] 32
				$RNG = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
				$RNG.GetBytes($SaltBytes)
				$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword
				$Rfc2898Deriver = New-Object System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $SaltBytes
				$KeyBytes  = $Rfc2898Deriver.GetBytes(32)
				$EncryptedString = $SecureKeyString | ConvertFrom-SecureString -key $KeyBytes
				$ObjConfigOnyphe = @{
					Salt = $SaltBytes
					EncryptedAPIKey = $EncryptedString
				}
				$FolderName = 'Use-Onyphe'
				$ConfigName = 'Use-Onyphe-Config.xml'
				if (!$home) {
					$global:home = $env:userprofile
				}
				if (!(Test-Path -Path "$($home)\$FolderName")) {
					New-Item -ItemType directory -Path "$($home)\$FolderName" | Out-Null
				}
				if (test-path "$($home)\$FolderName\$ConfigName") {
					Remove-item -Path "$($home)\$FolderName\$ConfigName" -Force | out-null
				}
				$ObjConfigOnyphe | Export-Clixml "$($home)\$FolderName\$ConfigName"
			}	
		}
	  }
  }
	}
	Function Import-OnypheEncryptedIKey {
  <#
		.SYNOPSIS 
		import onyphe API key as global variable from encrypted local config file

		.DESCRIPTION
		import onyphe API key as global variable from encrypted local config file
		
		.PARAMETER MasterPassword
		-MasterPassword SecureString{Password}
		Use a passphrase for encryption purpose.
		
		.OUTPUTS
		none
		
		.EXAMPLE
		set API Key as global variable using encrypted key hosted in local xml file previously generated with Set-OnypheAPIKey
		C:\PS> Import-OnypheEncryptedIKey -MasterPassword (ConvertTo-SecureString -String "YourP@ssw0rd" -AsPlainText -Force)
  #>
    [CmdletBinding()]
    Param(
      [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [securestring]$MasterPassword
	)
	process {
		$FolderName = 'Use-Onyphe'
		$ConfigName = 'Use-Onyphe-Config.xml'
		if (!$home) {
			$global:home = $env:userprofile
		}
        if (!(Test-Path "$($home)\$($FolderName)\$($ConfigName)")){
			throw 'Configuration file has not been set, Set-OnypheAPIKey to configure the API Keys.'
        }
		$ObjConfigOnyphe = Import-Clixml "$($home)\$($FolderName)\$($ConfigName)"
        $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword
		try {
			$Rfc2898Deriver = New-Object System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $ObjConfigOnyphe.Salt
			$KeyBytes  = $Rfc2898Deriver.GetBytes(32)
			$SecString = ConvertTo-SecureString -Key $KeyBytes $ObjConfigOnyphe.EncryptedAPIKey
			$SecureStringToBSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecString)
			$APIKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto($SecureStringToBSTR)
			$global:OnypheAPIKey = $APIKey
		} catch {
			throw "Not able to set correctly your API Key, your passphrase my be incorrect"
			write-error -message "Error Type: $($_.Exception.GetType().FullName)"
			write-error -message "Error Message: $($_.Exception.Message)"
		}
	}
	}
	Function Get-OnypheSearchFilters {
  <#
		.SYNOPSIS 
		Get filters available for search APIs of Onyphe

		.DESCRIPTION
		Get filters available for search APIs of Onyphe
		
		.OUTPUTS
		filters as string
		
		.EXAMPLE
		Get filters available for search APIs of Onyphe
		C:\PS> Get-OnypheSearchFilters
  #>
	$XMLFilePath = join-path (Get-ScriptDirectory) "Onyphe-Data-Model.xml"
	if (test-path $XMLFilePath) {
		$SearchFilters = Import-Clixml -Path $XMLFilePath
		$SearchFilters.filters
	}
	}
	Function Get-OnypheSearchCategories {
	<#
	  .SYNOPSIS 
	  Get category available for search APIs of Onyphe
  
	  .DESCRIPTION
	  Get category available for search APIs of Onyphe
	  
	  .OUTPUTS
	  filters as string
	  
	  .EXAMPLE
	  Get category available for search APIs of Onyphe
	  C:\PS> Get-OnypheSearchCategories
	#>
	  $XMLFilePath = join-path (Get-ScriptDirectory) "Onyphe-Data-Model.xml"
	  if (test-path $XMLFilePath) {
		  $SearchFilters = Import-Clixml -Path $XMLFilePath
		  ($SearchFilters.apis | Where-Object {$_ -like "search/*"}) -replace "search/",""
	  }
	}
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
			$XMLFilePath = join-path (Get-ScriptDirectory) "Onyphe-Data-Model.xml"
			if (test-path $XMLFilePath) {
				$SearchFilters = Import-Clixml -Path $XMLFilePath
				($SearchFilters.functions | Where-Object {$_ -like "-*"}) -replace "-",""
			}
	}
	Function Get-OnypheCliFacets {
	<#
	  .SYNOPSIS 
	  Get facets available for stats on local Onyphe PS Object
  
	  .DESCRIPTION
	  Get facets available for stats on local Onyphe PS Object
	  
	  .OUTPUTS
	  facets as string
	  
	  .EXAMPLE
	  Get facets available for stats on local Onyphe PS Object
	  C:\PS> Get-OnypheCliFacets
	#>
	  $XMLFilePath = join-path (Get-ScriptDirectory) "Onyphe-Data-Model.xml"
	  if (test-path $XMLFilePath) {
			$SearchFilters = Import-Clixml -Path $XMLFilePath
			$SearchFilters.filters
	  }
  	}
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
	  $XMLFilePath = join-path (Get-ScriptDirectory) "Onyphe-Data-Model.xml"
	  if (test-path $XMLFilePath) {
			$SearchFilters = Import-Clixml -Path $XMLFilePath
			$Apis = @($SearchFilters.apis | Where-Object {($_ -like "simple/*") -and ($_ -notlike "simple/resolver/*") -and ($_ -notlike "simple/datascan/*")}) -replace "simple/","" 
			$Apis += ($SearchFilters.apis | Where-Object {$_ -like "simple/resolver/*"}) -replace "simple/resolver/","resolver"
			$Apis += ($SearchFilters.apis | Where-Object {$_ -like "simple/datascan/*"}) -replace "simple/datascan/","datascan"
		  $Apis
	  }
	}
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
		  $XMLFilePath = join-path (Get-ScriptDirectory) "Onyphe-Data-Model.xml"
		  if (test-path $XMLFilePath) {
				$SearchFilters = Import-Clixml -Path $XMLFilePath
				$Apis = @($SearchFilters.apis | Where-Object {($_ -like "summary/*")}) -replace "summary/",""
			  $Apis
		  }
	}
	Function Set-OnypheProxy {
	<#
	  .SYNOPSIS 
	  Set an internet proxy to use onyphe web api
  
	  .DESCRIPTION
	  Set an internet proxy to use onyphe web api

	  .PARAMETER DirectNoProxy
	  -DirectNoProxy
	  Remove proxy and configure Onyphe powershell functions to use a direct connection
	
	  .PARAMETER Proxy
	  -Proxy{Proxy}
	  Set the proxy URL

	  .PARAMETER ProxyCredential
	  -ProxyCredential{ProxyCredential}
	  Set the proxy credential to be authenticated with the internet proxy set

	  .PARAMETER ProxyUseDefaultCredentials
	  -ProxyUseDefaultCredentials
	  Use current security context to be authenticated with the internet proxy set

	  .PARAMETER AnonymousProxy
	  -AnonymousProxy
	  No authentication (open proxy) with the internet proxy set

	  .OUTPUTS
	  none
	  
	  .EXAMPLE
	  Remove Internet Proxy and set a direct connection
	  C:\PS> Set-OnypheProxy -DirectNoProxy

	  .EXAMPLE
	  Set Internet Proxy and with manual authentication
	  $credentials = get-credential 
	  C:\PS> Set-OnypheProxy -Proxy "http://myproxy:8080" -ProxyCredential $credentials

	  .EXAMPLE
	  Set Internet Proxy and with automatic authentication based on current security context
	  C:\PS> Set-OnypheProxy -Proxy "http://myproxy:8080" -ProxyUseDefaultCredentials

	  .EXAMPLE
	  Set Internet Proxy and with no authentication 
	  C:\PS> Set-OnypheProxy -Proxy "http://myproxy:8080" -AnonymousProxy
	#>
	[cmdletbinding()]
	Param (
	  [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
		  [switch]$DirectNoProxy,
	  [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
	    [string]$Proxy,
	  [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
	    [Management.Automation.PSCredential]$ProxyCredential,
	  [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
		  [Switch]$ProxyUseDefaultCredentials,
	  [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
		  [Switch]$AnonymousProxy
	)
	if ($DirectNoProxy.IsPresent){
		$global:OnypheProxyParams = $null
	} ElseIf ($Proxy) {
		$global:OnypheProxyParams = @{}
		$OnypheProxyParams.Add('Proxy', $Proxy)
		if ($ProxyCredential){
			$OnypheProxyParams.Add('ProxyCredential', $ProxyCredential)
			If ($OnypheProxyParams.ProxyUseDefaultCredentials) {$OnypheProxyParams.Remove('ProxyUseDefaultCredentials')}
		} Elseif ($ProxyUseDefaultCredentials.IsPresent){
			$OnypheProxyParams.Add('ProxyUseDefaultCredentials', $ProxyUseDefaultCredentials)
			If ($OnypheProxyParams.ProxyCredential) {$OnypheProxyParams.Remove('ProxyCredential')}
		} ElseIf ($AnonymousProxy.IsPresent) {
			If ($OnypheProxyParams.ProxyUseDefaultCredentials) {$OnypheProxyParams.Remove('ProxyUseDefaultCredentials')}
			If ($OnypheProxyParams.ProxyCredential) {$OnypheProxyParams.Remove('ProxyCredential')}
		}
	}
  	}
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
				if ($tmp[1].contains(",")) {
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
		$params = @{
			request = [System.Uri]::EscapeURIString("v2/search/category:$($SearchType) $($NewSearchValue)")
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
		if ($UseBetaFeatures) {
			$params.add('UseBetaFeatures', $true)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	}
	}
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
					if ($tmp[1].contains(",")) {
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
			$params = @{
				request = [System.Uri]::EscapeURIString("v2/export/category:$($SearchType) $($NewSearchValue)")
				APIInfo = "export/$($SearchType)"
				APIKeyrequired = $true
				APIInput = $APIInput
				Stream = $true
				OutFile = $OutFile
			}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			if ($UseBetaFeatures) {
				$params.add('UseBetaFeatures', $true)
			}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV2 @params
		}
	}
	Function Invoke-APIOnypheListAlert {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-OnypheAPIv2 function and then call it to list alert already set from alert/list API
  
	  .DESCRIPTION
	  create several input for Invoke-OnypheAPIv2 function and then call it to list alert already set from alert/list API
	  	  
	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
		Set APIKEY as global variable.
		
		.PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe
	  
	  .OUTPUTS
	   TypeName: PSOnyphe

	  .EXAMPLE
	  get alert set and set api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	  C:\PS> Invoke-APIOnypheListAlert -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	  .EXAMPLE
	  get alert set
	  C:\PS> Invoke-APIOnypheListAlert
	#>
	[cmdletbinding()]
	Param ( 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$UseBetaFeatures,
		[parameter(mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
	)  
	  Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/alert/list/"
			APIInfo = "alert/list"
			APIInput = "none"
			APIKeyrequired = $true
		}
		if ($UseBetaFeatures) {
			$params.add("UseBetaFeatures", $true)
		}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	  }
	}
	Function Invoke-APIOnypheDelAlert {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-OnypheAPIv2 function and then call it to delete an alert already create using alert/del API
  
	  .DESCRIPTION
	  create several input for Invoke-OnypheAPIv2 function and then call it to delete an alert already create using alert/del API
	  	  
	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
	  Set APIKEY as global variable.
	  
	  .PARAMETER AlertID
	  -AlertID string{ID}
	   mandatory input containing the ID of the alert to be deleted
		
	  .PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe
	  
	  .OUTPUTS
	   TypeName: PSOnyphe

	  .EXAMPLE
	  Delete Onyphe Alert with ID 0 and set api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	  C:\PS> Invoke-APIOnypheDelAlert -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -AlertID 0

	  .EXAMPLE
	  Delete Onyphe Alert with ID 0
	  C:\PS> Invoke-APIOnypheDelAlert -AlertID 0
	#>
	[cmdletbinding()]
	Param ( 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$UseBetaFeatures,
		[parameter(Mandatory=$true)]
		[ValidateScript({($_ -match "^[0-9]*$")})]
			[string]$AlertID,
		[parameter(mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
	) 
	  Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/alert/del/$($AlertID)"
			APIInfo = "alert/del"
			APIInput = "$($AlertID)"
			Method = "POST"
			APIKeyrequired = $true
		}
		if ($UseBetaFeatures) {
			$params.add("UseBetaFeatures", $true)
		}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	  }
	}
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
	[cmdletbinding()]
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
				if ($tmp[1].contains(",")) {
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
		Invoke-OnypheAPIV2 @params
	  }
	}
	Function Update-OnypheFacetsFilters {
	<#
	  .SYNOPSIS 
	  Update Onyphe-Data-Model.xml local file containing a cache of available APIs, functions, filters from user API
  
	  .DESCRIPTION
	  Update Onyphe-Data-Model.xml local file containing a cache of available APIs, functions, filters from user API
	  
	  .OUTPUTS
		none
		
		.PARAMETER APIKEY
	  -APIKey string{APIKEY}
		Set APIKEY as global variable
		
		.PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe
	  
	  .EXAMPLE
	  Update Onyphe-Data-Model.xml local file containing a cache of available APIs, functions, filters from user API
	  C:\PS> Update-OnypheFacetsFilters
	#>
	[cmdletbinding()]
	Param ( 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$UseBetaFeatures
	)  
	  Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			if ($UseBetaFeatures) {
				$params = @{
					UseBetaFeatures = $true
				}
			} else {
				$params = @{}
			}
			$XMLFilePath = join-path (Get-ScriptDirectory) "Onyphe-Data-Model.xml"
			if (test-path $XMLFilePath) {
				Write-Verbose -message "file Onyphe-Data-Model.xml already exists, removing the old file"
				Remove-Item -Path $XMLFilePath -Force
			}
			write-verbose -Message "generating new file from Onyphe User info"
			(Get-OnypheUserInfo @params).results | Select-Object -Property apis,filters,functions | Export-Clixml -Force -Path $XMLFilePath
		}
	}
	Function Export-OnypheDataShot {
	<#
	  .SYNOPSIS 
	  Export encoded base64 jpg file from a datashot category object
  
	  .DESCRIPTION
	  Export encoded base64 jpg file from a datashot category object
	  
	  .OUTPUTS
	  jpg file
	  
	  .EXAMPLE
	  Export all screenshots available in powershell object $temp into C:\temp folder
	  C:\PS> Export-OnypheDataShot -tofolder C:\temp -InputOnypheObject $temp
	#>
		[cmdletbinding()]
		Param (
			[parameter(Mandatory=$true)]
			[ValidateScript({test-path "$($_)"})]
				[string]$tofolder,
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -is [System.Management.Automation.PSCustomObject]) -or ($_ -is [Deserialized.System.Management.Automation.PSCustomObject])})]
				[array]$InputOnypheObject
			)
			Process {
				$ticks = (get-date).ticks.ToString()
				foreach ($result in $InputOnypheObject) {
					$datashotsfilter = $result.results | Where-Object {($_.'@category' -eq 'datashot') -or ($_.'@category' -eq 'onionshot')}
					foreach ($datashot in $datashotsfilter) {
						if ($datashot.app.screenshot.image) {
							$file = "$($ticks)_$($datashot.datamd5)_$((Get-Random -Maximum 999).tostring()).jpg"
							$fullfilepath = join-path $tofolder $file
							if ($host.Version.Major -ge 6) {
								[System.Convert]::FromBase64String($datashot.app.screenshot.image) | Set-Content $fullfilepath -AsByteStream -Force
							} else {
								[System.Convert]::FromBase64String($datashot.app.screenshot.image) | Set-Content $fullfilepath -Encoding Byte -Force
							}
						}
					}
				}
			}
	}

	New-Alias -Name Update-OnypheLocalData -value Update-OnypheFacetsFilters
	New-Alias -Name Get-Onyphe -Value Get-OnypheInfo
	New-Alias -Name Get-OnypheFromCSV -Value Get-OnypheInfoFromCSV
	New-Alias -Name Search-Onyphe -Value Search-OnypheInfo
	New-Alias -Name Get-OnypheAlert -Value Get-OnypheAlertInfo
	New-Alias -Name Set-OnypheAlert -Value Set-OnypheAlertInfo
	New-Alias -Name Export-Onyphe -Value Export-OnypheInfo

	Export-ModuleMember -Function  Get-OnypheUserInfo, Search-OnypheInfo, Get-OnypheInfo, Get-OnypheInfoFromCSV, Export-OnypheInfoToFile, Export-OnypheDataShot,
									Invoke-APIOnypheExport, Invoke-APIOnypheGeoloc, Invoke-APIOnypheTopSite, Invoke-APIOnypheVulnscan, Invoke-APIOnypheOnionShot, Invoke-APIOnypheDataShot, Invoke-APIOnypheOnionScan, Invoke-APIOnypheCtl, Invoke-APIOnypheSniffer, Invoke-APIOnypheUser, Invoke-APIOnypheSearch, Invoke-APIOnypheDataScan, Invoke-APIOnypheDatascanDataMd5, 
									Invoke-APIOnypheResolver, Invoke-APIOnypheResolverForward, Invoke-APIOnypheInetnum, Invoke-APIOnyphePastries, Invoke-APIOnypheResolverReverse, Invoke-APIOnypheSynScan, Invoke-APIOnypheThreatlist, Invoke-APIOnypheListAlert, 
									Invoke-APISummaryOnypheIP, Invoke-APISummaryOnypheHostname, Invoke-APISummaryOnypheDomain,
									Invoke-APIBulkSummaryOnypheIP, Invoke-APIBulkSummaryOnypheHostname, Invoke-APIBulkSummaryOnypheDomain, Export-OnypheBulkInfo,
									Invoke-OnypheAPIV2, 
									Invoke-APIOnypheAddAlert, Invoke-APIOnypheDelAlert,
									Export-OnypheInfo,
									Get-OnypheSummaryAPIName, Get-OnypheSummary,
									Get-OnypheSearchFunctions, Get-OnypheSearchCategories, Get-OnypheSearchFilters, Get-ScriptDirectory, Set-OnypheAPIKey, Update-OnypheFacetsFilters, Get-OnypheCliFacets, Get-OnypheStatsFromObject, Set-OnypheProxy, Import-OnypheEncryptedIKey, Get-OnypheSimpleAPIName, Get-OnypheAlertInfo, Set-OnypheAlertInfo,
	Export-ModuleMember -Alias Update-OnypheLocalData, Get-Onyphe, Search-Onyphe, Get-OnypheFromCSV, Get-OnypheAlert, Set-OnypheAlert, Export-Onyphe