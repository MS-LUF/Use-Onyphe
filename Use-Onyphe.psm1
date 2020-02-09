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
# Released on: 02/2020
# v0.99 :
# - replace $env:appdata with $home for Linux and Powershell Core compatibility
# - create new function to request APIv2 (Invoke-OnypheAPIV2) and managing api key as new header etc...
# - rename previous function to request APIv1 (Invoke-OnypheAPIV1) and fix Net.WebException management for Powershell core
# - create new functions to deal with Onyphe Alert APIs (Invoke-APIOnypheListAlert, Invoke-APIOnypheDelAlert, Invoke-APIOnypheAddAlert)
# - create new functions for managing the Onyphe Alert (Get-OnypheAlertInfo, Set-OnypheAlertInfo)
#
#'(c) 2018-2020 lucas-cueff.com - Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).'

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
	
	.PARAMETER inputobject
	-inputobject PSCustomObject{Onyphe result PSCustomObject}
	Onyphe object used for the stat
	
	.PARAMETER AdvancedFacets
	-AdvancedFacets ARRAY{list of onyphe objects' properties}
	Onyphe result object's property requested for the stat (results = on object per property requested)

	.PARAMETER Facets
	-Facets string{onyphe objects' property}
	Onyphe result object's property requested for the stat
	
	.OUTPUTS
   	TypeName : System.Management.Automation.PSCustomObject

	Name        MemberType   Definition
	----        ----------   ----------
	Equals      Method       bool Equals(System.Object obj)
	GetHashCode Method       int GetHashCode()
	GetType     Method       type GetType()
	ToString    Method       string ToString()
	Average     NoteProperty double Average=1
	Count       NoteProperty int Count=10
	Max         NoteProperty double Max=1
	Min         NoteProperty double Min=1
	Stats       NoteProperty Object[] Stats=System.Object[]
	Sum         NoteProperty double Sum=10
		
	.EXAMPLE
	Search SynScan info and request stats for 'ip','port','tag' and 'organization' properties
	C:\PS> Search-OnypheInfo -AdvancedSearch @('country:FR','port:23','os:Linux') -SearchType synscan | Get-OnypheStatsFromObject -AdvancedFacets @('ip','port','tag','organization')

	.EXAMPLE
	Search SynScan info and request stats for 'ip' property
	C:\PS> $onypheobj = Search-OnypheInfo -AdvancedSearch @('country:FR','port:23','os:Linux') -SearchType synscan
	C:\PS> Get-OnypheStatsFromObject -Facets 'ip' -inputobject $onypheobj
#>
	[cmdletbinding()]
	Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[ValidateScript({$_ -is [System.Management.Automation.PSCustomObject]})]
			[array]$inputobject,
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
				$tmp = $inputobject.results."$($Facet)" | sort-object | get-unique
				$script:AllFacetObjects = @()
				foreach ($object in $tmp) {
					$tmpobj = $script:TemplateFacetObject | Select-Object *
					$tmpobj.'Onyphe-Property-value' = $object
					if (($inputobject.results | Where-Object {$_."$($Facet)" -eq "$($object)"}).count) {
						$tmpobj.'Onyphe-Property-Count' = ($inputobject.results | Where-Object {$_."$($Facet)" -eq "$($object)"}).count
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
			$tmp = $inputobject.results."$($Facets)" | sort-object | get-unique
			foreach ($object in $tmp) {
				$tmpobj = $script:TemplateFacetObject | Select-Object *
				$tmpobj.'Onyphe-Property-value' = $object
				if (($inputobject.results | Where-Object {$_."$($Facets)" -eq "$($object)"}).count) {
					$tmpobj.'Onyphe-Property-Count' = ($inputobject.results | Where-Object {$_."$($Facets)" -eq "$($object)"}).count
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
	
	count            : 28
	error            : 0
	myip             : 192.168.6.66
	results          : {@{@category=inetnum; @timestamp=2018-01-14T02:37:32.000Z; @type=ip; country=US; ipv6=false;
					netname=EU-EDGECASTEU-20080602; seen_date=2018-01-14; source=RIPE; subnet=93.184.208.0/20},
					@{@category=inetnum; @timestamp=2018-01-14T02:37:32.000Z; @type=ip; country=EU;
					information=System.Object[]; ipv6=false; netname=EDGECAST-NETBLK-03; seen_date=2018-01-14;
					source=RIPE; subnet=93.184.208.0/24}, @{@category=inetnum; @timestamp=2018-01-07T02:37:24.000Z;
					@type=ip; country=US; ipv6=false; netname=EU-EDGECASTEU-20080602; seen_date=2018-01-07;
					source=RIPE; subnet=93.184.208.0/20}, @{@category=inetnum; @timestamp=2018-01-07T02:37:24.000Z;
					@type=ip; country=EU; information=System.Object[]; ipv6=false; netname=EDGECAST-NETBLK-03;
					seen_date=2018-01-07; source=RIPE; subnet=93.184.208.0/24}...}
	status           : ok
	took             : 0.437
	total            : 28
	cli-API_info     : {inetnum}
	cli-API_input    : {192.168.6.66}
	cli-key_required : {True}
	cli-Request_Date : 14/01/2018 20:51:06
	
	.EXAMPLE
	Request info for several IP information from a csv formated file and your API key is already set as global variable
	C:\PS> Get-onypheinfo -fromcsv .\input.csv
	
	.EXAMPLE
	Request info for several IP information from a csv formated file and set the API key as global variable
	C:\PS> Get-onypheinfo -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	.EXAMPLE
	Request info for several IP information from a csv formated file using ',' separator and set the API key as global variable
	C:\PS> Get-onypheinfo -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -csvdelimiter ","
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
		$APIEntries = $csvcontent | where-object {$_.API -ne "Search"}
		foreach ($entry in $APIEntries) {
				$Script:Result += Get-OnypheInfo -searchtype $entry.API -SearchValue $entry.'API-Input' -wait 3
		}
		$Script:Result
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
	 
	 count            : 32
	 error            : 0
	 myip             : 192.168.6.66
	 results          : {@{@category=geoloc; @timestamp=2017-12-20T13:43:12.000Z; @type=ip; asn=AS15169; city=; country=US;
						country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
						longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}, @{@category=inetnum;
						@timestamp=1970-01-01T00:00:00.000Z; @type=ip; country=US; information=System.Object[];
						netname=Undisclosed; seen_date=1970-01-01; source=Undisclosed; subnet=Undisclosed},
						@{@category=pastries; @timestamp=2017-12-20T12:21:40.000Z; @type=pastebin; domain=System.Object[];
						hostname=System.Object[]; ip=System.Object[]; key=cnRxq9LP; seen_date=2017-12-20},
						@{@category=pastries; @timestamp=2017-12-20T09:35:16.000Z; @type=pastebin; domain=System.Object[];
						hostname=System.Object[]; ip=System.Object[]; key=AjfnLBLE; seen_date=2017-12-20}...}
	 status           : ok
	 took             : 0.107
	 total            : 3556
	 cli-API_info     : ip
	 cli-API_input    : {8.8.8.8}
	 cli-key_required : True
	 cli-Request_Date : 14/01/2018 20:45:08
		 
	 .EXAMPLE
	 AdvancedSearch with multiple criteria/filters
	 Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
	 C:\PS> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan
 
	 .EXAMPLE
	 simple search with one filter/criteria
	 Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	 C:\PS> Search-OnypheInfo -SearchValue RU -SearchType threatlist -SearchFilter country
 
	 .EXAMPLE
	 AdvancedSearch with multiple criteria/filters and set the API key
	 Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
	 C:\PS> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	 
	 .EXAMPLE
	 simple search with one filter/criteria and request page 2 of the results
	 Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	 C:\PS> Search-OnypheInfo -SearchValue RU -SearchType threatlist -SearchFilter country -page "2"

	 .EXAMPLE
	 simple search with one filter/criteria and use a server filter to retrieve only objects indexed since 2 month
	 Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	 C:\PS> Search-OnypheInfo -SearchValue RU -SearchType threatlist -SearchFilter country -FilterFunction monthago -FilterValue "2"

	.EXAMPLE
	 filter the result and show me only the answer with os property not null for threatlist category for all Russia
	 C:\PS> Search-OnypheInfo -SearchValue RU -SearchType threatlist -SearchFilter country -FilterFunction exist -FilterValue os

	 .EXAMPLE
     filter the results using multiple filters (only os property known and from all organization like *company*) for tcp port 3389 opened in russia
	 C:\PS> search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan
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
	main function/cmdlet - Get IP information from onyphe.io web service using dedicated subfunctions by searchtype

	.DESCRIPTION
	main function/cmdlet - Get IP information from onyphe.io web service using dedicated subfunctions by searchtype
	send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

	.PARAMETER myip
	-Myip
	look for information about my public IP
	
	.PARAMETER searchtype string (ctl,datascan,forward,geoloc,inetnum,ip,md5,myip,onionscan,pastries,resolver,reverse,sniffer,synscan,threatlist,forward,reverse)
	-SearchValue string -searchtype Inetnum -APIKey string{APIKEY}
	look for an ip address in onyphe database
	-SearchValue string -searchtype Threatlist -APIKey string{APIKEY}
	look for threat info about a specific IP in onyphe database.
	-SearchValue string -searchtype Pastries -APIKey string{APIKEY}
	look for an pastbin data about a specific IP in onyphe database.
	-SearchValue string -searchtype Synscan -APIKey string{APIKEY}
	look for open ports info for a specific IP in onyphe database.
	-SearchValue string -searchtype ip -APIKey string{APIKEY}
	get all information available for a specific IP in onyphe database.
	
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
	
	count            : 32
	error            : 0
	myip             : 192.168.6.66
	results          : {@{@category=geoloc; @timestamp=2017-12-20T13:43:12.000Z; @type=ip; asn=AS15169; city=; country=US;
					   country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
					   longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}, @{@category=inetnum;
					   @timestamp=1970-01-01T00:00:00.000Z; @type=ip; country=US; information=System.Object[];
					   netname=Undisclosed; seen_date=1970-01-01; source=Undisclosed; subnet=Undisclosed},
					   @{@category=pastries; @timestamp=2017-12-20T12:21:40.000Z; @type=pastebin; domain=System.Object[];
					   hostname=System.Object[]; ip=System.Object[]; key=cnRxq9LP; seen_date=2017-12-20},
					   @{@category=pastries; @timestamp=2017-12-20T09:35:16.000Z; @type=pastebin; domain=System.Object[];
					   hostname=System.Object[]; ip=System.Object[]; key=AjfnLBLE; seen_date=2017-12-20}...}
	status           : ok
	took             : 0.107
	total            : 3556
	cli-API_info     : ip
	cli-API_input    : {8.8.8.8}
	cli-key_required : True
	cli-Request_Date : 14/01/2018 20:45:08

	.EXAMPLE
	Request all information available for ip 192.168.1.5
	C:\PS> Get-OnypheInfo -searchtype ip -SearchValue "192.168.1.5" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Looking for my public ip address
	C:\PS> Get-OnypheInfo -myip
	
	.EXAMPLE
	Request geoloc information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Geoloc
	
	.EXAMPLE
	Request dns reverse information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Reverse -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	request IIS keyword datascan information
	C:\PS> Get-OnypheInfo -searchtype DataScan -SearchValue "IIS" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	request datascan information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype DataScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request pastebin content information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	.EXAMPLE
	Request pastebin content information for ip 8.8.8.8 and see page 2 of results
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -page "2"
	
	.EXAMPLE
	Request dns forward information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Forward -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request threatlist information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Threatlist -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request inetnum information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Inetnum -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request synscan information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype SynScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"	
#>
  [cmdletbinding()]
  Param (
	[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[string[]]$SearchValue,
	[parameter(Mandatory=$false)]
		[switch]$MyIP,
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
		$arrSet =  Get-OnypheAPIName
		$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		$AttributeCollection.Add($ValidateSetAttribute)
		$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
		$RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
		return $RuntimeParameterDictionary
 }
	process {
		$SearchType = $PsBoundParameters[$ParameterNameType]
		if (!($SearchType -and $SearchValue)) {
			throw "Please provide a valid searchvalue and search type parameters"
		}
		if ($wait) {start-sleep -s $wait}
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		If ($MyIP.IsPresent -eq $true) {
			Invoke-APIOnypheMyIP
		} elseIf ($searchtype) {
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
				throw "-SearchValue parameter must be used with -Searchtype"
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
	 
	Name             MemberType   Definition
	----             ----------   ----------
	Equals           Method       bool Equals(System.Object obj)
	GetHashCode      Method       int GetHashCode()
	GetType          Method       type GetType()
	ToString         Method       string ToString()
	cli-API_info     NoteProperty string[] cli-API_info=System.String[]
	cli-API_input    NoteProperty string[] cli-API_input=System.String[]
	cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
	cli-Request_Date NoteProperty datetime cli-Request_Date=23/01/2018 11:33:17
	count            NoteProperty int count=1
	error            NoteProperty int error=0
	myip             NoteProperty string myip=192.168.6.66
	results          NoteProperty Object[] results=System.Object[]
	status           NoteProperty string status=ok
	took             NoteProperty string took=0.001
	total            NoteProperty int total=1

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
		Invoke-APIOnypheUser @params
	}
	}
	#v0.99
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
	 
			Name             MemberType   Definition                                                                                                                                                                                                                                       
			----             ----------   ----------
			Equals           Method       bool Equals(System.Object obj)
			GetHashCode      Method       int GetHashCode()
			GetType          Method       type GetType()
			ToString         Method       string ToString()
			cli-API_info     NoteProperty string[] cli-API_info=System.String[]
			cli-API_input    NoteProperty string[] cli-API_input=System.String[]
			cli-API_version  NoteProperty string cli-API_version=2
			cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
			cli-Request_Date NoteProperty datetime cli-Request_Date=27/12/2019 12:20:36
			count            NoteProperty long count=2
			error            NoteProperty long error=0
			myip             NoteProperty string myip=8.8.8.8
			results          NoteProperty Object[] results=System.Object[]
			status           NoteProperty string status=ok
			took             NoteProperty string took=0.000
			total            NoteProperty long total=2
		 
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
			 #fixing issue with convertfrom-json and APIv2
			 if ($results.count -eq 2) {
				 if ($results[0].results) {
					 $results = $results[0]
				} else {
					$results = $results[1]
				}
			 }
			 #end of fix
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
	#v0.99
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
	 
			Name             MemberType   Definition                                                                                                                                                                                                                                       
			----             ----------   ----------
			Equals           Method       bool Equals(System.Object obj)
			GetHashCode      Method       int GetHashCode()
			GetType          Method       type GetType()
			ToString         Method       string ToString()
			cli-API_info     NoteProperty string[] cli-API_info=System.String[]
			cli-API_input    NoteProperty string[] cli-API_input=System.String[]
			cli-API_version  NoteProperty string cli-API_version=2
			cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
			cli-Request_Date NoteProperty datetime cli-Request_Date=27/12/2019 12:24:24
			error            NoteProperty long error=0
			message          NoteProperty string message=Success
			myip             NoteProperty string myip=8.8.8.8
			status           NoteProperty string status=ok
		 
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
			[parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
			[ValidateScript({($_ -is [System.Management.Automation.PSCustomObject]) -and ($_.'cli-API_info')})]
				$InputOnypheObject
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
				}
			} elseif ($InputOnypheObject) {
				if (!$AlertName -and !$AlertMail) {
					throw "please use AlertName, AlertMail and AlertAction parameters when using InputOnypheObject parameter"
				} else {
					$params = @{
						InputOnypheObject = $InputOnypheObject
						AlertName = $AlertName
						AlertEmail = $AlertMail
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
	  create several input for Invoke-Onyphe function and then call it to get the user account info from user API
  
	  .DESCRIPTION
	  create several input for Invoke-Onyphe function and then call it to get the user account info from user API
	  	  
	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
		Set APIKEY as global variable.
		
		.PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe
	  
	  .OUTPUTS
		 TypeName : System.Management.Automation.PSCustomObject

	    Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=23/01/2018 11:33:17
		count            NoteProperty int count=1
		error            NoteProperty int error=0
		myip             NoteProperty string myip=192.168.6.66
		results          NoteProperty Object[] results=System.Object[]
		status           NoteProperty string status=ok
		took             NoteProperty string took=0.001
		total            NoteProperty int total=1
  
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
		[parameter(Mandatory=$false,Position=10)]
			[switch]$UseBetaFeatures
	)  
	  Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "user/"
				APIInfo = "user"
				APIInput = "none"
				APIKeyrequired = $true
			}
			if ($UseBetaFeatures) {
				$params.add("UseBetaFeatures", $true)
			}
			Write-Verbose -message "URL Info : $($params.request)"  
			Invoke-OnypheAPIV1 @params
		}
    }
	Function Invoke-APIOnypheInetnum {
  <#
	.SYNOPSIS 
	create several input for Invoke-Onyphe function and then call it to get the inetnum info from inetnum API

	.DESCRIPTION
	create several input for Invoke-Onyphe function and then call it to get the inetnum info from inetnum API
	
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
	   TypeName : System.Management.Automation.PSCustomObject

	Name             MemberType   Definition
	----             ----------   ----------
	Equals           Method       bool Equals(System.Object obj)
	GetHashCode      Method       int GetHashCode()
	GetType          Method       type GetType()
	ToString         Method       string ToString()
	cli-API_info     NoteProperty string[] cli-API_info=System.String[]
	cli-API_input    NoteProperty string[] cli-API_input=System.String[]
	cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
	cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
	count            NoteProperty int count=1
	error            NoteProperty int error=0
	myip             NoteProperty string myip=192.168.6.66
	results          NoteProperty Object[] results=System.Object[]
	status           NoteProperty string status=ok
	took             NoteProperty string took=0.001305
	total            NoteProperty int total=1
	
	count            : 28
	error            : 0
	myip             : 192.168.6.66
	results          : {@{@category=inetnum; @timestamp=2018-01-14T02:37:32.000Z; @type=ip; country=US; ipv6=false;
					netname=EU-EDGECASTEU-20080602; seen_date=2018-01-14; source=RIPE; subnet=93.184.208.0/20},
					@{@category=inetnum; @timestamp=2018-01-14T02:37:32.000Z; @type=ip; country=EU;
					information=System.Object[]; ipv6=false; netname=EDGECAST-NETBLK-03; seen_date=2018-01-14;
					source=RIPE; subnet=93.184.208.0/24}, @{@category=inetnum; @timestamp=2018-01-07T02:37:24.000Z;
					@type=ip; country=US; ipv6=false; netname=EU-EDGECASTEU-20080602; seen_date=2018-01-07;
					source=RIPE; subnet=93.184.208.0/20}, @{@category=inetnum; @timestamp=2018-01-07T02:37:24.000Z;
					@type=ip; country=EU; information=System.Object[]; ipv6=false; netname=EDGECAST-NETBLK-03;
					seen_date=2018-01-07; source=RIPE; subnet=93.184.208.0/24}...}
	status           : ok
	took             : 1.314
	total            : 28
	cli-API_info     : {inetnum}
	cli-API_input    : {93.184.208.0}
	cli-key_required : {True}
	cli-Request_Date : 14/01/2018 20:45:08

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
			[string[]]$IP, 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string[]]$Page
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "inetnum/$($IP)"
			APIInfo = "inetnum"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV1 @params
	}
	}
	Function Invoke-APIOnyphePastries {
  <#
	.SYNOPSIS 
	create several input for Invoke-Onyphe function and then call it to get the pastries (pastebin) info from pastries API

	.DESCRIPTION
	create several input for Invoke-Onyphe function and then call it to get the pastries (pastebin) info from pastries API
	
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
	   TypeName : System.Management.Automation.PSCustomObject

	Name             MemberType   Definition
	----             ----------   ----------
	Equals           Method       bool Equals(System.Object obj)
	GetHashCode      Method       int GetHashCode()
	GetType          Method       type GetType()
	ToString         Method       string ToString()
	cli-API_info     NoteProperty string[] cli-API_info=System.String[]
	cli-API_input    NoteProperty string[] cli-API_input=System.String[]
	cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
	cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
	count            NoteProperty int count=1
	error            NoteProperty int error=0
	myip             NoteProperty string myip=192.168.6.66
	results          NoteProperty Object[] results=System.Object[]
	status           NoteProperty string status=ok
	took             NoteProperty string took=0.001305
	total            NoteProperty int total=1
	
	count            : 100
	error            : 0
	myip             : 192.168.6.66
	results          : {@{@category=pastries; @timestamp=2018-01-14T06:24:45.000Z; @type=pastebin; domain=System.Object[]
					hostname=System.Object[]; ip=System.Object[]; key=4AVhGheK; seen_date=2018-01-14},
					@{@category=pastries; @timestamp=2018-01-14T06:24:08.000Z; @type=pastebin; domain=System.Object[];
					hostname=System.Object[]; ip=System.Object[]; key=g6Tm4CaF; seen_date=2018-01-14},
					@{@category=pastries; @timestamp=2018-01-14T01:51:29.000Z; @type=pastebin; domain=System.Object[];
					hostname=System.Object[]; ip=System.Object[]; key=qB6HvymP; seen_date=2018-01-14},
					@{@category=pastries; @timestamp=2018-01-14T00:57:35.000Z; @type=pastebin; domain=System.Object[];
					hostname=System.Object[]; ip=System.Object[]; key=138rguxt; seen_date=2018-01-14}...}
	status           : ok
	took             : 0.086
	total            : 3043
	cli-API_info     : {patries}
	cli-API_input    : {8.8.8.8}
	cli-key_required : {True}
	cli-Request_Date : 14/01/2018 20:45:08

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
			[string[]]$Page
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "pastries/$($IP)"
			APIInfo = "patries"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV1 @params
	}
	}
	Function Invoke-APIOnypheSynScan {
    <#
	.SYNOPSIS 
	create several input for Invoke-Onyphe function and then call it to get the syn scan info from synscan API

	.DESCRIPTION
	create several input for Invoke-Onyphe function and then call it to get the syn scan info from synscan API
	
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
	   TypeName : System.Management.Automation.PSCustomObject

	Name             MemberType   Definition
	----             ----------   ----------
	Equals           Method       bool Equals(System.Object obj)
	GetHashCode      Method       int GetHashCode()
	GetType          Method       type GetType()
	ToString         Method       string ToString()
	cli-API_info     NoteProperty string[] cli-API_info=System.String[]
	cli-API_input    NoteProperty string[] cli-API_input=System.String[]
	cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
	cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
	count            NoteProperty int count=1
	error            NoteProperty int error=0
	myip             NoteProperty string myip=192.168.6.66
	results          NoteProperty Object[] results=System.Object[]
	status           NoteProperty string status=ok
	took             NoteProperty string took=0.001305
	total            NoteProperty int total=1
	
	count            : 76
	error            : 0
	myip             : 192.168.6.6
	results          : {@{@category=synscan; @timestamp=2017-11-26T23:47:45.000Z; @type=port-53; asn=AS15169; country=US;
					ip=8.8.8.8; location=37.7510,-97.8220; organization=Google LLC; os=Linux; port=53;
					seen_date=2017-11-26}, @{@category=synscan; @timestamp=2017-11-26T22:47:46.000Z; @type=port-53;
					asn=AS15169; country=US; ip=8.8.8.8; location=37.7510,-97.8220; organization=Google LLC; os=Linux;
					port=53; seen_date=2017-11-26}, @{@category=synscan; @timestamp=2017-11-26T22:47:42.000Z;
					@type=port-53; asn=AS15169; country=US; ip=8.8.8.8; location=37.7510,-97.8220; organization=Google
					LLC; os=Linux; port=53; seen_date=2017-11-26}, @{@category=synscan;
					@timestamp=2017-11-26T22:47:31.000Z; @type=port-53; asn=AS15169; country=US; ip=8.8.8.8;
					location=37.7510,-97.8220; organization=Google LLC; os=Linux; port=53; seen_date=2017-11-26}...}
	status           : ok
	took             : 0.029
	total            : 76
	cli-API_info     : {synscan}
	cli-API_input    : {8.8.8.8}
	cli-key_required : {True}
	cli-Request_Date : 14/01/2018 20:45:08

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
			[string[]]$Page
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "synscan/$($IP)"
			APIInfo = "synscan"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV1 @params
	}
	}
	Function Invoke-APIOnypheSniffer {
	<#
	.SYNOPSIS 
	create several input for Invoke-Onyphe function and then call it to get the IP sniffer info from sniffer API

	.DESCRIPTION
	create several input for Invoke-Onyphe function and then call it to get the IP sniffer info from sniffer API
	
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
	   TypeName : System.Management.Automation.PSCustomObject

		Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=04/03/2019 22:04:40
		count            NoteProperty long count=10
		error            NoteProperty long error=0
		max_page         NoteProperty long max_page=3
		myip             NoteProperty string myip=192.168.6.66
		page             NoteProperty long page=1
		results          NoteProperty Object[] results=System.Object[]
		status           NoteProperty string status=ok
		took             NoteProperty string took=0.034
		total            NoteProperty long total=28
	
		count            : 10
		error            : 0
		max_page         : 3
		myip             : 192.168.6.66
		page             : 1
		results          : {@{@category=sniffer; @timestamp=04/03/2019 13:27:53; @type=doc; asn=AS20952; city=Witham;
											country=GB; data=\x1b\x81\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00
											CKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x00\x00!\x00\x01; datamd5=70b95a08c5a052f5f8353bc75d1b7912;
											destport=137; ip=217.138.28.194; ipv6=false; location=51.8149,0.6454; organization=Venus Business
											Communications Limited; seen_date=2019-03-04; srcport=137; subnet=217.138.28.128/25;
											tag=System.Object[]; transport=udp; type=udpdata}, @{@category=sniffer; @timestamp=02/03/2019
											17:34:37; @type=doc; asn=AS20952; city=Witham; country=GB;
											data=Ni\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00 CKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x00\x00!\x00\x01;
											datamd5=35191f8ac64683f9564b6b0fc6e27847; destport=137; ip=217.138.28.194; ipv6=false;
											location=51.8149,0.6454; organization=Venus Business Communications Limited; seen_date=2019-03-02;
											srcport=137; subnet=217.138.28.128/25; tag=System.Object[]; transport=udp; type=udpdata},
											@{@category=sniffer; @timestamp=01/03/2019 23:52:39; @type=doc; asn=AS20952; city=Witham;
											country=GB; data=\x1e\xe8\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00
											CKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x00\x00!\x00\x01; datamd5=9f8536314d5eafdb06c99897fffb8aa8;
											destport=137; ip=217.138.28.194; ipv6=false; location=51.8149,0.6454; organization=Venus Business
											Communications Limited; seen_date=2019-03-01; srcport=137; subnet=217.138.28.128/25;
											tag=System.Object[]; transport=udp; type=udpdata}, @{@category=sniffer; @timestamp=28/02/2019
											18:08:53; @type=doc; asn=AS20952; city=Witham; country=GB;
											data=\x18\x99\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00
											CKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x00\x00!\x00\x01; datamd5=83a75a375d30691bc1cb164f2955f406;
											destport=137; ip=217.138.28.194; ipv6=false; location=51.8194,0.6718; organization=Venus Business
											Communications Limited; seen_date=2019-02-28; srcport=137; subnet=217.138.0.0/16;
											tag=System.Object[]; transport=udp; type=udpdata}...}
		status           : ok
		took             : 0.011
		total            : 28
		cli-API_info     : {sniffer}
		cli-API_input    : {217.138.28.194}
		cli-key_required : {True}
		cli-Request_Date : 04/03/2019 22:05:23

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
				[string[]]$Page
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "sniffer/$($IP)"
				APIInfo = "sniffer"
				APIInput = @("$($IP)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV1 @params
		}
	}
	Function Invoke-APIOnypheCtl {
	<#
	.SYNOPSIS 
	create several input for Invoke-Onyphe function and then call it to get the CTL (certificate transparancy) info from ctl API

	.DESCRIPTION
	create several input for Invoke-Onyphe function and then call it to get the CTL (certificate transparancy) info from ctl API
	
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
	   TypeName : System.Management.Automation.PSCustomObject

		Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=04/03/2019 22:04:40
		count            NoteProperty long count=10
		error            NoteProperty long error=0
		max_page         NoteProperty long max_page=3
		myip             NoteProperty string myip=192.168.6.66
		page             NoteProperty long page=1
		results          NoteProperty Object[] results=System.Object[]
		status           NoteProperty string status=ok
		took             NoteProperty string took=0.034
		total            NoteProperty long total=28
	
		count            : 1
		error            : 0
		max_page         : 1
		myip             : 192.168.6.66
		page             : 1
		results          : {@{@category=ctl; @timestamp=15/02/2019 21:28:05; @type=doc; ca=false; country=FR;
											domain=fnac.com; extkeyusage=System.Object[]; fingerprint=; host=portaltv-int;
											hostname=System.Object[]; ip=80.12.18.251; issuer=; keyusage=System.Object[]; organization=Orange;
											publickey=; seen_date=2019-02-15; serial=01:81:e1:48:b1:9b:1e:4f:bc:5f:fc:99:e7:73:7d:da;
											signature=; source=Cloudflare Nimbus 2019; subdomains=q5ntv.orange.fr; subject=; tld=fr; validity=;
											version=v3; wildcard=false}}
		status           : ok
		took             : 0.024
		total            : 1
		cli-API_info     : {ctl}
		cli-API_input    : {orange.fr}
		cli-key_required : {True}
		cli-Request_Date : 05/03/2019 15:31:48

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
				[string[]]$Page
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "ctl/$($Domain)"
				APIInfo = "ctl"
				APIInput = @("$($Domain)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV1 @params
		}
	}
	Function Invoke-APIOnypheMD5 {
	<#
	.SYNOPSIS 
	create several input for Invoke-Onyphe function and then call it to get info from onyphe md5 signature

	.DESCRIPTION
	create several input for Invoke-Onyphe function and then call it to get info from onyphe md5 signature
	
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
	   TypeName : System.Management.Automation.PSCustomObject

		Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=04/03/2019 22:04:40
		count            NoteProperty long count=10
		error            NoteProperty long error=0
		max_page         NoteProperty long max_page=3
		myip             NoteProperty string myip=192.168.6.66
		page             NoteProperty long page=1
		results          NoteProperty Object[] results=System.Object[]
		status           NoteProperty string status=ok
		took             NoteProperty string took=0.034
		total            NoteProperty long total=28
	
		count            : 10
		error            : 0
		max_page         : 1000
		myip             : 192.168.6.66
		page             : 1
		results          : {@{@category=datascan; @timestamp=05/03/2019 13:25:40; @type=doc; app=; asn=AS36352; city=Buffalo;
											country=US; cpe=System.Object[]; data=SSH-2.0-OpenSSH_7.4\x0d
											; datamd5=7a1f20cae067b75a52bc024b83ee4667; device=; domain=colocrossing.com;
											host=104-168-71-162-host; ip=104.168.71.162; ipv6=false; location=42.8864,-78.8781;
											organization=ColoCrossing; port=22; product=OpenSSH; productvendor=OpenBSD; productversion=7.4;
											protocol=ssh; protocolversion=2.0; reverse=104-168-71-162-host.colocrossing.com;
											seen_date=2019-03-05; source=sniffer; subnet=104.168.70.0/23; tag=System.Object[]; tld=com;
											tls=false; transport=tcp}, @{@category=datascan; @timestamp=05/03/2019 12:08:44; @type=doc; app=;
											asn=AS27715; country=BR; cpe=System.Object[]; data=SSH-2.0-OpenSSH_7.4\x0d
											; datamd5=7a1f20cae067b75a52bc024b83ee4667; device=; domain=hospedagemdesites.ws; host=gagarin0303;
											hostname=System.Object[]; ip=191.252.118.55; ipv6=false; location=-22.8305,-43.2192;
											organization=Locaweb Serviços de Internet S/A; port=22; product=OpenSSH; productvendor=OpenBSD;
											productversion=7.4; protocol=ssh; protocolversion=2.0; reverse=gagarin0303.hospedagemdesites.ws;
											seen_date=2019-03-05; source=datascan; subnet=191.252.112.0/20; tag=System.Object[]; tld=ws;
											tls=false; transport=tcp}, @{@category=datascan; @timestamp=05/03/2019 12:08:44; @type=doc; app=;
											asn=AS45090; city=Beijing; country=CN; cpe=System.Object[]; data=SSH-2.0-OpenSSH_7.4\x0d
											; datamd5=7a1f20cae067b75a52bc024b83ee4667; device=; ip=119.29.173.149; ipv6=false;
											location=39.9288,116.3889; organization=Shenzhen Tencent Computer Systems Company Limited; port=22;
											product=OpenSSH; productvendor=OpenBSD; productversion=7.4; protocol=ssh; protocolversion=2.0;
											seen_date=2019-03-05; source=datascan; subnet=119.29.128.0/17; tag=System.Object[]; tls=false;
											transport=tcp}, @{@category=datascan; @timestamp=05/03/2019 12:08:44; @type=doc; app=; asn=AS45090;
											country=CN; cpe=System.Object[]; data=SSH-2.0-OpenSSH_7.4\x0d
											; datamd5=7a1f20cae067b75a52bc024b83ee4667; device=; ip=62.234.10.225; ipv6=false;
											location=39.9289,116.3883; organization=Shenzhen Tencent Computer Systems Company Limited; port=22;
											product=OpenSSH; productvendor=OpenBSD; productversion=7.4; protocol=ssh; protocolversion=2.0;
											seen_date=2019-03-05; source=datascan; subnet=62.234.0.0/16; tag=System.Object[]; tls=false;
											transport=tcp}...}
		status           : ok
		took             : 0.259
		total            : 1942240
		cli-API_info     : {md5}
		cli-API_input    : {7a1f20cae067b75a52bc024b83ee4667}
		cli-key_required : {True}
		cli-Request_Date : 05/03/2019 16:48:12

	.EXAMPLE
	get md5 info for 7a1f20cae067b75a52bc024b83ee4667 hash
	C:\PS> Invoke-APIOnypheMd5 -MD5 7a1f20cae067b75a52bc024b83ee4667

	.EXAMPLE
	get md5 info for 7a1f20cae067b75a52bc024b83ee4667 hash and set the api key
	C:\PS> Invoke-APIOnypheMd5 -MD5 7a1f20cae067b75a52bc024b83ee4667 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "^[a-f0-9]{32}$")})]
				[string[]]$MD5, 
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateScript({$_ -match "^((?!0)\d+)$"})]
				[string[]]$Page
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "md5/$($MD5)"
				APIInfo = "md5"
				APIInput = @("$($MD5)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV1 @params
		}
	}
	Function Invoke-APIOnypheOnionScan {
	<#
		.SYNOPSIS 
		create several input for Invoke-Onyphe function and then call it to get info for a .onion link using OnionScan API

		.DESCRIPTION
		create several input for Invoke-Onyphe function and then call it to get info for a .onion link using OnionScan API
		
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
			TypeName : System.Management.Automation.PSCustomObject

			Name             MemberType   Definition
			----             ----------   ----------
			Equals           Method       bool Equals(System.Object obj)
			GetHashCode      Method       int GetHashCode()
			GetType          Method       type GetType()
			ToString         Method       string ToString()
			cli-API_info     NoteProperty string[] cli-API_info=System.String[]
			cli-API_input    NoteProperty string[] cli-API_input=System.String[]
			cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
			cli-Request_Date NoteProperty datetime cli-Request_Date=04/03/2019 22:04:40
			count            NoteProperty long count=10
			error            NoteProperty long error=0
			max_page         NoteProperty long max_page=3
			myip             NoteProperty string myip=192.168.6.66
			page             NoteProperty long page=1
			results          NoteProperty Object[] results=System.Object[]
			status           NoteProperty string status=ok
			took             NoteProperty string took=0.034
			total            NoteProperty long total=28
		
			count            : 10
			error            : 0
			max_page         : 1000
			myip             : 192.168.6.66
			page             : 1
			results          : {}
			status           : ok
			took             : 0.259
			total            : 1942240
			cli-API_info     : {OnionScan}
			cli-API_input    : {vlp4uw5ui22ljlg7.onion}
			cli-key_required : {True}
			cli-Request_Date : 05/03/2019 16:48:12

		.EXAMPLE
		get md5 info for vlp4uw5ui22ljlg7.onion URL
		C:\PS> Invoke-APIOnypheOnionScan -Onion "vlp4uw5ui22ljlg7.onion"

		.EXAMPLE
		get md5 info for vlp4uw5ui22ljlg7.onion URL and set the api key
		C:\PS> Invoke-APIOnypheOnionScan -Onion "vlp4uw5ui22ljlg7.onion" -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "[a-z2-7]{16}\.onion") -or ($_ -match "[a-z2-7]{56}\.onion")})]
				[string[]]$Onion, 
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateScript({$_ -match "^((?!0)\d+)$"})]
				[string[]]$Page
		)
		Process {
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "onionscan/$($Onion)"
				APIInfo = "onionscan"
				APIInput = @("$($Onion)")
				APIKeyrequired = $true
			}
			if ($page) {$params.add('page',$page)}
			Write-Verbose -message "URL Info : $($params.request)"
			Invoke-OnypheAPIV1 @params
		}
	}
	Function Invoke-APIOnypheReverse {
  <#
		.SYNOPSIS 
		create several input for Invoke-Onyphe function and then call it to get the reverse dns info from reverse API

		.DESCRIPTION
		create several input for Invoke-Onyphe function and then call it to get the reverse dns info from reverse API
		
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
			TypeName : System.Management.Automation.PSCustomObject

		Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
		count            NoteProperty int count=1
		error            NoteProperty int error=0
		myip             NoteProperty string myip=192.168.6.66
		results          NoteProperty Object[] results=System.Object[]
		status           NoteProperty string status=ok
		took             NoteProperty string took=0.001305
		total            NoteProperty int total=1

		count            : 59
		error            : 0
		myip             : 192.168.6.66
		results          : {@{@category=resolver; @timestamp=2018-01-13T15:26:54.000Z; @type=reverse; domain=google.com;
						ip=8.8.8.8; ipv6=false; reverse=google-public-dns-a.google.com; seen_date=2018-01-13},
						@{@category=resolver; @timestamp=2018-01-13T15:26:54.000Z; @type=reverse; domain=google.com;
						ip=8.8.8.8; ipv6=false; reverse=google-public-dns-a.google.com; seen_date=2018-01-13},
						@{@category=resolver; @timestamp=2018-01-10T07:39:04.000Z; @type=reverse; domain=google.com;
						ip=8.8.8.8; ipv6=false; reverse=google-public-dns-a.google.com; seen_date=2018-01-10},
						@{@category=resolver; @timestamp=2018-01-10T07:39:04.000Z; @type=reverse; domain=google.com;
						ip=8.8.8.8; ipv6=false; reverse=google-public-dns-a.google.com; seen_date=2018-01-10}...}
		status           : ok
		took             : 0.056
		total            : 59
		cli-API_info     : {reverse}
		cli-API_input    : {8.8.8.8}
		cli-key_required : {True}
		cli-Request_Date : 14/01/2018 20:45:08
		
		.EXAMPLE
		get reverse dns info info for IP 8.8.8.8
		C:\PS> Invoke-APIOnypheReverse -IP 8.8.8.8

		.EXAMPLE
		get reverse dns info info for IP 8.8.8.8 ans set the api key
		C:\PS> Invoke-APIOnypheReverse -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
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
			[string[]]$Page
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "reverse/$($IP)"
			APIInfo = "reverse"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV1 @params
	}
	}
	Function Invoke-APIOnypheForward {
  <#
		.SYNOPSIS 
		create several input for Invoke-Onyphe function and then call it to get the dns forwarder info from forward API

		.DESCRIPTION
		create several input for Invoke-Onyphe function and then call it to get the dns forwarder info from forward API
		
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
			TypeName : System.Management.Automation.PSCustomObject

		Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
		count            NoteProperty int count=1
		error            NoteProperty int error=0
		myip             NoteProperty string myip=192.168.6.66
		results          NoteProperty Object[] results=System.Object[]
		status           NoteProperty string status=ok
		took             NoteProperty string took=0.001305
		total            NoteProperty int total=1

		count            : 16
		error            : 0
		myip             : 192.168.6.66
		results          : {@{@category=resolver; @timestamp=2018-01-09T15:27:41.000Z; @type=forward; domain=bot.nu;
						forward=bot.nu; ip=8.8.8.8; ipv6=false; seen_date=2018-01-09}, @{@category=resolver;
						@timestamp=2018-01-09T15:27:41.000Z; @type=forward; domain=bot.nu; forward=bot.nu; ip=8.8.8.8;
						ipv6=false; seen_date=2018-01-09}, @{@category=resolver; @timestamp=2018-01-03T16:20:06.000Z;
						@type=forward; domain=bot.nu; forward=bot.nu; ip=8.8.8.8; ipv6=0; seen_date=2018-01-03},
						@{@category=resolver; @timestamp=2018-01-03T16:20:06.000Z; @type=forward; domain=bot.nu;
						forward=bot.nu; ip=8.8.8.8; ipv6=0; seen_date=2018-01-03}...}
		status           : ok
		took             : 0.023
		total            : 16
		cli-API_info     : {forward}
		cli-API_input    : {8.8.8.8}
		cli-key_required : {True}
		cli-Request_Date : 14/01/2018 20:45:08
		
		.EXAMPLE
		get all info for IP 8.8.8.8
		C:\PS> Invoke-APIOnypheForward -IP 8.8.8.8

		.EXAMPLE
		get all info for IP 8.8.8.8 ans set the api key
		C:\PS> Invoke-APIOnypheForward -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
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
			[string[]]$Page
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "forward/$($IP)"
			APIInfo = "forward"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV1 @params
	}
	}
	Function Invoke-APIOnypheThreatlist {
  <#
		.SYNOPSIS 
		create several input for Invoke-Onyphe function and then call it to get the threat info from threatlist API

		.DESCRIPTION
		create several input for Invoke-Onyphe function and then call it to get the threat info from threatlist API
		
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
			TypeName : System.Management.Automation.PSCustomObject

		Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
		count            NoteProperty int count=1
		error            NoteProperty int error=0
		myip             NoteProperty string myip=192.168.6.66
		results          NoteProperty Object[] results=System.Object[]
		status           NoteProperty string status=ok
		took             NoteProperty string took=0.001305
		total            NoteProperty int total=1
		
		count            : 19
		error            : 0
		myip             : 192.168.6.66
		results          : {@{@category=threatlist; @timestamp=2018-01-14T07:45:15.000Z; @type=ip; ipv6=false;
						seen_date=2018-01-14; subnet=178.250.241.22/32; threatlist=Abuse.ch - Zeus bad IPs},
						@{@category=threatlist; @timestamp=2018-01-14T07:45:15.000Z; @type=ip; ipv6=false;
						seen_date=2018-01-14; subnet=178.250.241.22/32; threatlist=Abuse.ch - Zeus IPs},
						@{@category=threatlist; @timestamp=2018-01-14T07:45:15.000Z; @type=ip; ipv6=false;
						seen_date=2018-01-14; subnet=178.250.241.22/32; threatlist=EmergingThreats - Spamhaus, DShield and
						Abuse.ch}, @{@category=threatlist; @timestamp=2018-01-13T07:45:13.000Z; @type=ip; ipv6=false;
						seen_date=2018-01-13; subnet=178.250.241.22/32; threatlist=EmergingThreats - Spamhaus, DShield and
						Abuse.ch}...}
		status           : ok
		took             : 0.023
		total            : 19
		cli-API_info     : {threatlist}
		cli-API_input    : {178.250.241.22}
		cli-key_required : {True}
		cli-Request_Date : 14/01/2018 20:45:08

		.EXAMPLE
		get all threat info for IP 178.250.241.22
		C:\PS> Invoke-APIOnypheThreatlist -IP 178.250.241.22

		.EXAMPLE
		get all threat info for IP 178.250.241.22 and set the api key
		C:\PS> Invoke-APIOnypheThreatlist -IP 178.250.241.22 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
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
			[string[]]$Page
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "threatlist/$($IP)"
			APIInfo = "threatlist"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV1 @params
	}
	}
	Function Invoke-APIOnypheDataScan {
  <#
		.SYNOPSIS 
		create several input for Invoke-Onyphe function and then call it to get the data scan info from datascan API

		.DESCRIPTION
		create several input for Invoke-Onyphe function and then call it to get the data scan info from datascan API
		
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
			TypeName : System.Management.Automation.PSCustomObject

		Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
		count            NoteProperty int count=1
		error            NoteProperty int error=0
		myip             NoteProperty string myip=192.168.6.66
		results          NoteProperty Object[] results=System.Object[]
		status           NoteProperty string status=ok
		took             NoteProperty string took=0.001305
		total            NoteProperty int total=1
		
		count            : 1
		error            : 0
		myip             : 192.168.6.66
		results          : {@{@category=datascan; @timestamp=2018-01-05T02:21:45.000Z; @type=http; asn=AS10201; country=IN;
						data=HTTP/1.0 302 Moved Temporarily
						Date: Sat, 06 Jan 2018 02:13:01 GMT
						Server: PanWeb Server/ -
						ETag: "73829-130d-57651d79"
						Connection: close
						Pragma: no-cache
						Location: /php/login.php
						Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
						Content-Length: 0
						Content-Type: text/html
						Expires: Thu, 19 Nov 1981 08:52:00 GMT
						X-FRAME-OPTIONS: SAMEORIGIN
						Set-Cookie: PHPSESSID=73ebc70421adc9c46219dd68d722bb8b; path=/; HttpOnly

						; datamd5=beddae472d600e9e25787353ed4e5f21; ip=27.251.29.154; ipv6=false; location=20.0000,77.0000;
						organization=Dishnet Wireless Limited. Broadband Wireless; port=80; product=PanWeb Server;
						productversion= - ; protocol=http; seen_date=2018-01-05}}
		status           : ok
		took             : 0.013
		total            : 1
		cli-API_info     : {datascan}
		cli-API_input    : {27.251.29.154}
		cli-key_required : {True}
		cli-Request_Date : 14/01/2018 20:45:08

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
			[string[]]$IPOrDataScanString,
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string[]]$Page
  )
	Process {
		$script:DateRequest = get-date
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "datascan/$($IPOrDataScanString)"
			APIInput = "$($IPOrDataScanString)"
			APIInfo = "datascan"
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV1 @params
	}
	}
	Function Invoke-APIOnypheIP {
  <#
		.SYNOPSIS 
		create several input for Invoke-Onyphe function and then call it to get all info for an IP from IP API

		.DESCRIPTION
		create several input for Invoke-Onyphe function and then call it to get all info for an IP from IP API
		
		.PARAMETER IP
		-IP string{IP}
		IP to be used for the IP API usage
		
		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable

		.PARAMETER Page
		-page string{page number}
		go directly to a specific result page (1 to 1000)
		
		.OUTPUTS
			TypeName : System.Management.Automation.PSCustomObject

		Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
		count            NoteProperty int count=1
		error            NoteProperty int error=0
		myip             NoteProperty string myip=192.168.6.66
		results          NoteProperty Object[] results=System.Object[]
		status           NoteProperty string status=ok
		took             NoteProperty string took=0.001305
		total            NoteProperty int total=1
		
		count            : 32
		error            : 0
		myip             : 192.168.6.66
		results          : {@{@category=geoloc; @timestamp=2018-01-13T10:30:19.000Z; @type=ip; asn=AS15169; city=; country=US;
						country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
						longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}, @{@category=inetnum;
						@timestamp=1970-01-01T00:00:00.000Z; @type=ip; country=US; information=System.Object[];
						netname=Undisclosed; seen_date=1970-01-01; source=Undisclosed; subnet=Undisclosed},
						@{@category=pastries; @timestamp=2018-01-13T00:05:30.000Z; @type=pastebin; domain=System.Object[];
						hostname=System.Object[]; ip=System.Object[]; key=uL3KBwQb; seen_date=2018-01-13},
						@{@category=pastries; @timestamp=2018-01-12T23:38:24.000Z; @type=pastebin; domain=System.Object[];
						hostname=System.Object[]; ip=System.Object[]; key=d08TpvqK; seen_date=2018-01-12}...}
		status           : ok
		took             : 0.166
		total            : 3221
		cli-API_info     : {ip}
		cli-API_input    : {8.8.8.8}
		cli-key_required : {True}
		cli-Request_Date : 14/01/2018 20:45:08
		
		.EXAMPLE
		get all info for IP 8.8.8.8
		C:\PS> Invoke-APIOnypheIP -IP 8.8.8.8

		.EXAMPLE
		get all info for IP 8.8.8.8 ans set the api key
		C:\PS> Invoke-APIOnypheIP -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
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
			[string[]]$Page
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "ip/$($IP)"
			APIInfo = "ip"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV1 @params
	}			
	}
	Function Invoke-APIOnypheMyIP {
	<#
		.SYNOPSIS 
		create several input for Invoke-Onyphe function and then call it to get current public ip from MyIP API

		.DESCRIPTION
		create several input for Invoke-Onyphe function and then call it to get current public ip from MyIP API
			
		.OUTPUTS
				TypeName : System.Management.Automation.PSCustomObject

		Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
		count            NoteProperty int count=1
		error            NoteProperty int error=0
		myip             NoteProperty string myip=192.168.6.66
		status           NoteProperty string status=ok
		
		error            : 0
		myip             : 192.168.6.66
		status           : ok
		cli-API_info     : {myip}
		cli-API_input    : {none}
		cli-key_required : {False}
		cli-Request_Date : 14/01/2018 20:45:08
		
		.EXAMPLE
		get your current public ip
		C:\PS> Invoke-APIOnypheMyIP
  #>
  [cmdletbinding()]
  param ()
  process {
	$params = @{
		request = "myip/"
		APIInfo = "myip"
		APIInput = "none"
		APIKeyrequired = $false
	} 
	Write-Verbose -message "URL Info : $($params.request)"
	Invoke-OnypheAPIV1 @params
  }			
	}
	Function Invoke-APIOnypheGeoloc {
  <#
		.SYNOPSIS 
		create several input for Invoke-Onyphe function and then call it to get the Geoloc info from Geoloc API

		.DESCRIPTION
		create several input for Invoke-Onyphe function and then call it to get the Geoloc info from Geoloc API
		
		.PARAMETER IP
		-IP string{IP}
		IP to be used for the geoloc API usage
		
		.OUTPUTS
			TypeName : System.Management.Automation.PSCustomObject

		Name             MemberType   Definition
		----             ----------   ----------
		Equals           Method       bool Equals(System.Object obj)
		GetHashCode      Method       int GetHashCode()
		GetType          Method       type GetType()
		ToString         Method       string ToString()
		cli-API_info     NoteProperty string[] cli-API_info=System.String[]
		cli-API_input    NoteProperty string[] cli-API_input=System.String[]
		cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
		cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
		count            NoteProperty int count=1
		error            NoteProperty int error=0
		myip             NoteProperty string myip=192.168.6.66
		results          NoteProperty Object[] results=System.Object[]
		status           NoteProperty string status=ok
		took             NoteProperty string took=0.001305
		total            NoteProperty int total=1

		count            : 1
		error            : 0
		myip             : 192.168.6.66
		results          : {@{@category=geoloc; @timestamp=2018-01-13T10:18:52.000Z; @type=ip; asn=AS15169; city=; country=US;
						country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
						longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}}
		status           : ok
		took             : 0.013426
		total            : 1
		cli-API_info     : {geoloc}
		cli-API_input    : {8.8.8.8}
		cli-key_required : {False}
		cli-Request_Date : 14/01/2018 20:45:08
		
		.EXAMPLE
		get geoloc info for IP 8.8.8.8
		C:\PS> Invoke-APIOnypheGeoloc -IP 8.8.8.8
  #> 
[cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
			[string[]]$IP
  )
  process {
		$params = @{
			request = "geoloc/$($IP)"
			APIInfo = "geoloc"
			APIInput = @("$($IP)")
			APIKeyrequired = $false
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV1 @params
  }
	}
	#v0.99
	Function Invoke-OnypheAPIV1 {
  [cmdletbinding()]
  Param (
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]  
			[string[]]$request,
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]  
			[string[]]$APIInfo,
		[parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]  
			[string[]]$APIInput,
		[parameter(Mandatory=$true)]
			[Bool[]]$APIKeyrequired,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})] 
			[string[]]$page,
		[parameter(Mandatory=$false)]
			[switch]$UseBetaFeatures
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
		if ($page -and $APIKeyrequired) {
				$fullonypheurl = "$($fullonypheurl)?apikey=$($global:OnypheAPIKey)&page=$($page)"
		}
		elseif ($page -and ($APIKeyrequired -eq $false)) {
			$fullonypheurl = "$($fullonypheurl)?page=$($page)"
		} 
		elseif ($APIKeyrequired -and !$page) {
			$fullonypheurl = "$($fullonypheurl)?apikey=$($global:OnypheAPIKey)"
		}
		if ($global:OnypheProxyParams) {
			$params = $global:OnypheProxyParams
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
		$onypheresult = invoke-webrequest @params
	} catch {
			write-verbose -message "Not able to use onyphe online service - KO"
			write-verbose -message "Error Type: $($_.Exception.GetType().FullName)"
			write-verbose -message "Error Message: $($_.Exception.Message)"
			write-verbose -message "HTTP error code:$($_.Exception.Response.StatusCode.Value__)"
			write-verbose -message "HTTP error message:$($_.Exception.Response.StatusDescription)"
			$errorcode = $_.Exception.Response.StatusCode.value__
			if (($errorcode -eq 429) -or ($errorcode -eq 200)) {
				if ($_.ErrorDetails.Message) {
					$errorvalue = $_.ErrorDetails.Message | Convertfrom-Json
				} 
				elseif (get-member -InputObject $_.Exception.Response -MemberType Method | Where-Object {$_.name -eq "GetResponseStream"}){
				  $result = $_.Exception.Response.GetResponseStream()
				  $reader = New-Object System.IO.StreamReader($result)
				  $reader.BaseStream.Position = 0
				  $httpbody = $reader.ReadToEnd()
				  $errorvalue = $httpbody | Convertfrom-Json
				}
				else {
				  $errorvalue = [PSCustomObject]@{}
				}
				$errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_info' -Value $APIInfo
				$errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_input' -Value $APIInput
				$errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_version' -Value "1"
				$errorvalue | add-member -MemberType NoteProperty -Name 'cli-key_required' -Value $APIKeyrequired
				$errorvalue | add-member -MemberType NoteProperty -Name 'cli-Request_Date' -Value $script:DateRequest
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
					'cli-API_info' = $APIInfo
					'cli-API_input' = $APIInput
					'cli-API_version' = "1"
					'cli-key_required' = $APIKeyrequired
					'cli-Request_Date' = $script:DateRequest
				}
			}
		}
		if (-not $errorvalue) {
			try {
				write-verbose "Web Content : $($onypheresult.Content)"
				$temp = $onypheresult.Content | convertfrom-json
				$temp | add-member -MemberType NoteProperty -Name 'cli-API_info' -Value $APIInfo
				$temp | add-member -MemberType NoteProperty -Name 'cli-API_input' -Value $APIInput
				$temp | add-member -MemberType NoteProperty -Name 'cli-API_version' -value "1"
				$temp | add-member -MemberType NoteProperty -Name 'cli-key_required' -Value $APIKeyrequired
				$temp | add-member -MemberType NoteProperty -Name 'cli-Request_Date' -Value $script:DateRequest
			} catch {
				write-verbose -message "unable to convert result into a powershell object - json error"
				write-verbose -message "Error Type: $($_.Exception.GetType().FullName)"
				write-verbose -message "Error Message: $($_.Exception.Message)"
				$errorvalue = [PSCustomObject]@{
					Count = 0
					error = ""
					myip = 0
					results = ''
					'cli-error_results' = "$($_.Exception.GetType().FullName) - $($_.Exception.Message) : $($onypheresult.Content)"
					status = "ko"
					took = 0
					total = 0
					'cli-API_info' = $APIInfo
					'cli-API_input' = $APIInput
					'cli-API_version' = "1"
					'cli-key_required' = $APIKeyrequired
					'cli-Request_Date' = $script:DateRequest
				}
			}
		}
		if ($errorvalue) {
			$errorvalue
		} elseif ($temp) {
			$temp
		}
	}
	}
	#v0.99
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
		  [parameter(Mandatory=$false)]
		  [ValidateScript({$_ -match "^((?!0)\d+)$"})] 
			  [string[]]$page,
		  [parameter(Mandatory=$false)]
			  [switch]$UseBetaFeatures
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
		  
		  if (($Method -eq "POST") -and !$params.Method) {
			  $params.add('Method','Post') 
		  }
		  if ($APIKeyrequired) {
			  $params.Headers
			  $params.add('Headers', @{'Authorization' = 'apikey {0}' -f $global:OnypheAPIKey}) 
		  }
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
				  } 
				  elseif (get-member -InputObject $_.Exception.Response -MemberType Method | Where-Object {$_.name -eq "GetResponseStream"}){
					$result = $_.Exception.Response.GetResponseStream()
					$reader = New-Object System.IO.StreamReader($result)
					$reader.BaseStream.Position = 0
					$httpbody = $reader.ReadToEnd()
					$errorvalue = $httpbody | Convertfrom-Json
				  }
				  else {
					$errorvalue = [PSCustomObject]@{}
				  }
				  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_info' -Value $APIInfo
				  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_input' -Value $APIInput
				  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_version' -Value "2"
				  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-key_required' -Value $APIKeyrequired
				  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-Request_Date' -Value $script:DateRequest
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
					  'cli-API_info' = $APIInfo
					  'cli-API_input' = $APIInput
					  'cli-API_version' = "2"
					  'cli-key_required' = $APIKeyrequired
					  'cli-Request_Date' = $script:DateRequest
				  }
			  }
		  }
		  if (-not $errorvalue) {
			  try {
				  write-verbose "Web Content : $($onypheresult.Content)"
				  $temp = $onypheresult.Content | convertfrom-json
				  $temp | add-member -MemberType NoteProperty -Name 'cli-API_info' -Value $APIInfo
				  $temp | add-member -MemberType NoteProperty -Name 'cli-API_input' -Value $APIInput
				  $temp | add-member -MemberType NoteProperty -Name 'cli-API_version' -Value "2"
				  $temp | add-member -MemberType NoteProperty -Name 'cli-key_required' -Value $APIKeyrequired
				  $temp | add-member -MemberType NoteProperty -Name 'cli-Request_Date' -Value $script:DateRequest
			  } catch {
				  write-verbose -message "unable to convert result into a powershell object - json error"
				  write-verbose -message "Error Type: $($_.Exception.GetType().FullName)"
				  write-verbose -message "Error Message: $($_.Exception.Message)"
				  $errorvalue = [PSCustomObject]@{
					  Count = 0
					  error = ""
					  myip = 0
					  results = ''
					  'cli-error_results' = "$($_.Exception.GetType().FullName) - $($_.Exception.Message) : $($onypheresult.Content)"
					  status = "ko"
					  took = 0
					  total = 0
					  'cli-API_info' = $APIInfo
					  'cli-API_input' = $APIInput
					  'cli-API_version' = "2"
					  'cli-key_required' = $APIKeyrequired
					  'cli-Request_Date' = $script:DateRequest
				  }
			  }
		  }
		  if ($errorvalue) {
			  $errorvalue
		  } elseif ($temp) {
			  $temp
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

		.PARAMETER inputobject
		-inputobject $obj{output of Get-OnypheInfo or Get-OnypheInfoFromCSV functions}
		look for information about my public IP

		.PARAMETER csvdelimiter
		-csvdelimiter string{csv separator}
		set your csv separator. default is ;
			
		.OUTPUTS
		none
		
		.EXAMPLE
		Exporting onyphe results containing into $onypheresult object to flat files in folder C:\temp
		C:\PS> Export-OnypheInfoToFile -tofolder C:\temp -inputobject $onypheresult

		.EXAMPLE
		Exporting onyphe results containing into $onypheresult object to flat files in folder C:\temp using ',' as csv separator
		C:\PS> Export-OnypheInfoToFile -tofolder C:\temp -inputobject $onypheresult -csvdelimiter ","
	#>
  [cmdletbinding()]
  Param (
  [parameter(Mandatory=$true)]
  [ValidateScript({test-path "$($_)"})]
		$tofolder,
  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
  [ValidateScript({($_ -is [System.Management.Automation.PSCustomObject]) -or ($_ -is [Deserialized.System.Management.Automation.PSCustomObject])})]
		[array]$inputobject,
  [parameter(Mandatory=$false)]
    $csvdelimiter
  )
  process {
	if (!$csvdelimiter) {$csvdelimiter = ";"}
	$ticks = (get-date).ticks.ToString()
	If (($inputobject | Get-Member | Select-Object -ExpandProperty TypeName -Unique) -eq 'System.Management.Automation.PSCustomObject') {
		export-clixml -depth 1000 -path "$($env:temp)\$($ticks).xml" -InputObject $inputobject
		$inputobject = Import-Clixml -Path "$($env:temp)\$($ticks).xml"
		Remove-Item "$($env:temp)\$($ticks).xml" -Force
	}
	foreach ($result in $inputobject) {
	  $tempfolder = $null
	  $tempattrib = $result.'cli-API_input' -replace ("[{0}]"-f (([System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object {[regex]::Escape($_)}) -join '|')),'_'
	  $tempfolder = "Onyphe-result-$($tempattrib)"
	  $tempfolder = join-path $tofolder $tempfolder
	  if (!(test-path $tempfolder)) {mkdir $tempfolder -force | out-null}
	  $ticks = (get-date).ticks.ToString()
	  $result | Export-Csv -NoTypeInformation -path "$($tempfolder)\$($ticks)_request_info.csv" -delimiter $csvdelimiter
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
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)ctl.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			}
			'datashot' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'datashot'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_datashot.csv"
				$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
				Export-OnypheDataShot -tofolder $tempfolder -inputobject $result
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
	Split-Path -Parent $PSCommandPath
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
		  ($SearchFilters.apis | Where-Object {$_ -like "*/search/*"}) -replace "/api/search/",""
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
	Function Get-OnypheAPIName {
	<#
	  .SYNOPSIS 
	  Get API available for Onyphe
  
	  .DESCRIPTION
	  Get API available for Onyphe
	  
	  .OUTPUTS
	  API as string
	  
	  .EXAMPLE
	  Get API available for Onyphe
	  C:\PS> Get-OnypheAPIName
	#>
	  $XMLFilePath = join-path (Get-ScriptDirectory) "Onyphe-Data-Model.xml"
	  if (test-path $XMLFilePath) {
			$SearchFilters = Import-Clixml -Path $XMLFilePath
			$Apis = @($SearchFilters.apis -replace "/api/","" | Where-Object {($_ -notlike "*/*") -and ($_ -ne "search") -and ($_ -ne "user")})
			$Apis += ($SearchFilters.apis | Where-Object {$_ -like "*/resolver/*"}) -replace "/api/resolver/",""
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
	#v0.99
	Function Invoke-APIOnypheSearch {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-Onyphe function and then call it to search info from search APIs

	  .DESCRIPTION
	  create several input for Invoke-Onyphe function and then call it to to search info from search APIs

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
	     TypeName : System.Management.Automation.PSCustomObject

			Name             MemberType   Definition
			----             ----------   ----------
			Equals           Method       bool Equals(System.Object obj)
			GetHashCode      Method       int GetHashCode()
			GetType          Method       type GetType()
			ToString         Method       string ToString()
			cli-API_info     NoteProperty string[] cli-API_info=System.String[]
			cli-API_input    NoteProperty string[] cli-API_input=System.String[]
			cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
			cli-Request_Date NoteProperty datetime cli-Request_Date=15/08/2018 15:05:25
			count            NoteProperty int count=10
			error            NoteProperty int error=0
			max_page         NoteProperty decimal max_page=1000,0
			myip             NoteProperty string myip=192.168.6.66
			page             NoteProperty int page=1000
			results          NoteProperty Object[] results=System.Object[]
			status           NoteProperty string status=ok
			took             NoteProperty string took=0.066
			total            NoteProperty int total=157611

			count            : 10
			error            : 0
			max_page         : 1000,0
			myip             : 192.168.6.66
			page             : 1000
			results          : {@{@category=inetnum; @timestamp=2018-08-12T01:35:21.000Z; @type=ip; asn=AS16276; country=GB;
							information=System.Object[]; ipv6=false; location=51.4964,-0.1224; netname=reduk2; organization=OVH
							SAS; seen_date=2018-08-12; source=RIPE; subnet=213.32.105.0/26}, @{@category=inetnum;
							@timestamp=2018-08-12T01:35:21.000Z; @type=ip; asn=AS16276; country=FR;
							information=System.Object[]; ipv6=false; location=48.8582,2.3387; netname=OVH_121297930;
							organization=OVH SAS; seen_date=2018-08-12; source=RIPE; subnet=149.202.133.104/30},
							@{@category=inetnum; @timestamp=2018-08-12T01:35:21.000Z; @type=ip; asn=AS16276; country=FR;
							information=System.Object[]; ipv6=false; location=48.8582,2.3387; netname=OVH_121298047;
							organization=OVH SAS; seen_date=2018-08-12; source=RIPE; subnet=149.202.133.108/30},
							@{@category=inetnum; @timestamp=2018-08-12T01:35:21.000Z; @type=ip; asn=AS16276; country=FR;
							information=System.Object[]; ipv6=false; location=48.8582,2.3387; netname=OVH_121298490;
							organization=OVH SAS; seen_date=2018-08-12; source=RIPE; subnet=51.254.51.84/30}...}
			status           : ok
			took             : 0.066
			total            : 157611
			cli-API_info     : {search/inetnum}
			cli-API_input    : {organization:"OVH SAS"}
			cli-key_required : {True}
			cli-Request_Date : 15/08/2018 15:05:25
	  
	  .EXAMPLE
	  AdvancedSearch with multiple criteria/filters
	  Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
	  C:\PS> Invoke-APIOnypheSearch -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan

	  .EXAMPLE
	  simple search with one filter/criteria
	  Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	  C:\PS> Invoke-APIOnypheSearch -SearchValue RU -SearchType threatlist -SearchFilter country
	#>
	[cmdletbinding()]
    param(
		[parameter(Mandatory=$false)]
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
			[Array]$AdvancedFilter
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
			request = [System.Uri]::EscapeURIString("search/$($SearchType)/$($NewSearchValue)")
			APIInfo = "search/$($SearchType)"
			APIKeyrequired = $true
			APIInput = $APIInput
		}
		if ($page) {
			$params.add('page',$page)
		}
		if ($UseBetaFeatures) {
			$params.add('UseBetaFeatures', $true)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV1 @params
	}
	}
	#v0.99
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
		 TypeName : System.Management.Automation.PSCustomObject

			Name             MemberType   Definition                                                                                                                                                                                                                                       
			----             ----------   ----------
			Equals           Method       bool Equals(System.Object obj)
			GetHashCode      Method       int GetHashCode()
			GetType          Method       type GetType()
			ToString         Method       string ToString()
			cli-API_info     NoteProperty string[] cli-API_info=System.String[]
			cli-API_input    NoteProperty string[] cli-API_input=System.String[]
			cli-API_version  NoteProperty string cli-API_version=2
			cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
			cli-Request_Date NoteProperty datetime cli-Request_Date=27/12/2019 12:20:36
			count            NoteProperty long count=2
			error            NoteProperty long error=0
			myip             NoteProperty string myip=8.8.8.8
			results          NoteProperty Object[] results=System.Object[]
			status           NoteProperty string status=ok
			took             NoteProperty string took=0.000
			total            NoteProperty long total=2

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
		[parameter(Mandatory=$false,Position=10)]
			[switch]$UseBetaFeatures
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
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	  }
	}
	#v0.99
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
		 TypeName : System.Management.Automation.PSCustomObject

			Name             MemberType   Definition                                                                                                                                                                                                                                       
			----             ----------   ----------
			Equals           Method       bool Equals(System.Object obj)
			GetHashCode      Method       int GetHashCode()
			GetType          Method       type GetType()
			ToString         Method       string ToString()
			cli-API_info     NoteProperty string[] cli-API_info=System.String[]
			cli-API_input    NoteProperty string[] cli-API_input=System.String[]
			cli-API_version  NoteProperty string cli-API_version=2
			cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
			cli-Request_Date NoteProperty datetime cli-Request_Date=27/12/2019 12:22:38
			error            NoteProperty long error=0
			message          NoteProperty string message=Success
			myip             NoteProperty string myip=8.8.8.8
			status           NoteProperty string status=ok

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
		[parameter(Mandatory=$false,Position=10)]
			[switch]$UseBetaFeatures,
		[parameter(Mandatory=$true)]
		[ValidateScript({($_ -match "^[0-9]*$")})]
			[string]$AlertID
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
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	  }
	}
	#v0.99
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

	  .PARAMETER SearchType
	  -SearchType STRING{Get-OnypheSearchCategories}
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
		 TypeName : System.Management.Automation.PSCustomObject

			Name             MemberType   Definition                                                                                                                                                                                                                                       
			----             ----------   ----------
			Equals           Method       bool Equals(System.Object obj)
			GetHashCode      Method       int GetHashCode()
			GetType          Method       type GetType()
			ToString         Method       string ToString()
			cli-API_info     NoteProperty string[] cli-API_info=System.String[]
			cli-API_input    NoteProperty string[] cli-API_input=System.String[]
			cli-API_version  NoteProperty string cli-API_version=2
			cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
			cli-Request_Date NoteProperty datetime cli-Request_Date=27/12/2019 12:24:24
			error            NoteProperty long error=0
			message          NoteProperty string message=Success
			myip             NoteProperty string myip=8.8.8.8
			status           NoteProperty string status=ok
  
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
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			$InputOnypheObject
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
		}
		if ($InputOnypheObject.'cli-API_input' -and $InputOnypheObject.'cli-API_info') {
			if ($InputOnypheObject.'cli-API_info' -like "search*") {
				$Data | add-member -MemberType NoteProperty -Name query -Value "category:$(($InputOnypheObject.'cli-API_info' -split "/")[($InputOnypheObject.'cli-API_info' -split "/").count -1]) $($InputOnypheObject.'cli-API_input')"
			}
		} else {
			$Data | add-member -MemberType NoteProperty -Name query -Value "category:$($SearchType) $($NewSearchValue)"
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
	  C:\PS> Export-OnypheDataShot -tofolder C:\temp -inputobject $temp
	#>
		[cmdletbinding()]
		Param (
			[parameter(Mandatory=$true)]
			[ValidateScript({test-path "$($_)"})]
				$tofolder,
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[ValidateScript({($_ -is [System.Management.Automation.PSCustomObject]) -or ($_ -is [Deserialized.System.Management.Automation.PSCustomObject])})]
				[array]$inputobject
			)
			Process {
				$ticks = (get-date).ticks.ToString()
				foreach ($result in $inputobject) {
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

	Export-ModuleMember -Function  Get-OnypheUserInfo, Search-OnypheInfo, Get-OnypheInfo, Get-OnypheInfoFromCSV, Export-OnypheInfoToFile, Export-OnypheDataShot,
									Invoke-APIOnypheMD5, Invoke-APIOnypheOnionScan, Invoke-APIOnypheCtl, Invoke-APIOnypheSniffer, Invoke-APIOnypheUser, Invoke-APIOnypheSearch, Invoke-APIOnypheDataScan, Invoke-APIOnypheForward, Invoke-APIOnypheGeoloc, Invoke-APIOnypheIP, Invoke-APIOnypheInetnum, Invoke-APIOnypheMyIP, Invoke-APIOnyphePastries, Invoke-APIOnypheReverse, Invoke-APIOnypheSynScan, Invoke-APIOnypheThreatlist, Invoke-APIOnypheListAlert, Invoke-OnypheAPIV1, Invoke-OnypheAPIV2, Invoke-APIOnypheAddAlert, Invoke-APIOnypheDelAlert,
									Get-OnypheSearchFunctions, Get-OnypheSearchCategories, Get-OnypheSearchFilters, Get-ScriptDirectory, Set-OnypheAPIKey, Update-OnypheFacetsFilters, Get-OnypheCliFacets, Get-OnypheStatsFromObject, Set-OnypheProxy, Import-OnypheEncryptedIKey, Get-OnypheAPIName, Get-OnypheAlertInfo, Set-OnypheAlertInfo,
	Export-ModuleMember -Alias Update-OnypheLocalData, Get-Onyphe, Search-Onyphe, Get-OnypheFromCSV, Get-OnypheAlert, Set-OnypheAlert