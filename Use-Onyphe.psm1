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
# Released on: 08/2018
#
#'(c) 2018 lucas-cueff.com - Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).'

<#
	.SYNOPSIS 
	commandline interface to use onyphe.io web service

	.DESCRIPTION
	use-onyphe.psm1 module provides a commandline interface to onyphe.io web service.
	
	.EXAMPLE
	C:\PS> import-module use-onyphe.psm1
#>

function Get-OnypheStatsFromObject {
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
		[ValidateScript({(($_ | Get-Member | Select-Object -ExpandProperty TypeName -Unique) -eq 'System.Management.Automation.PSCustomObject')})]
			$inputobject,
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
		#$ParameterAttribute2.Position = 2
		$AttributeCollection2.Add($ParameterAttribute2)
		$arrSet =  Get-OnypheCliFacets
		$ValidateSetAttribute2 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		$AttributeCollection2.Add($ValidateSetAttribute2)
		$RuntimeParameter2 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFilter, [string], $AttributeCollection2)
		$RuntimeParameterDictionary.Add($ParameterNameFilter, $RuntimeParameter2)
		
		return $RuntimeParameterDictionary
	}
	Begin {
		$Facets = $PsBoundParameters[$ParameterNameFilter]
		if (!$Facets -and !$AdvancedFacets) {
			Write-Verbose -Message "both AdvancedFacets and Facets options are empty, please use at least one of this parameter to set the facets to be used for the stats"
			throw "Please provide a valid facets option"
		}
	} Process {
		$script:results = @()
		$script:TemplateFacetObject = new-object psobject
		$TemplateFacetObject | Add-Member -MemberType NoteProperty -Name 'Onyphe-Facet' $null
		$TemplateFacetObject | Add-Member -MemberType NoteProperty -Name 'Onyphe-Property-value' $null
		$TemplateFacetObject | Add-Member -MemberType NoteProperty -Name 'Onyphe-Property-Count' $null
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
	} End {
		return $results
	}
}
function Get-OnypheInfoFromCSV {
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
	cli-API_input    : {93.184.208.0}
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
		[string[]]$APIKey,
	[parameter(Mandatory=$false)]
    	$csvdelimiter
    )
	$Script:Result = @()
	if ($APIKey) {
		Set-OnypheAPIKey -APIKEY $APIKey | out-null
	}
 	if (!$csvdelimiter) {$csvdelimiter = ";"}
	$FromcsvType = $fromcsv | Get-Member | Select-Object -ExpandProperty TypeName -Unique
	if (($FromcsvType -eq 'System.String') -and (test-path $fromcsv)) {
			$csvcontent = import-csv $fromcsv -delimiter $csvdelimiter
	} ElseIf (($FromcsvType -eq 'System.Management.Automation.PSCustomObject') -and $fromcsv.'API-Input-IP') {
		$csvcontent = $fromcsv
	} Else {
		write-verbose -message "provide a valid csv file as input or valid System.Management.Automation.PSCustomObject object"
		write-verbose -message "please use the following column in your file : ip, searchtype, datascanstring"
		$errorvalue = @()
		$errorvalue += "please provide a valid csv file as input or valid System.Management.Automation.PSCustomObject object"
	}
	if (!$errorvalue) {
		$APISearchEntries = $csvcontent | where-object {$_.API -eq "Search"}
		foreach ($entry in $APISearchEntries) {
			$tmparray = $entry.'Search-Request'.split("+")
			$Script:Result += Search-OnypheInfo -AdvancedSearch $tmparray -SearchType $entry.'Search-Type' -wait 3
		}
		$APIOtherEntriesDataScan = $csvcontent | where-object {($_.API -ne "Search") -and ($_.API -eq "DataScan")}
		foreach ($entry in $APIOtherEntriesDataScan) {
			if ($entry.'API-Input-IP') {
				write-debug -message "Get-OnypheInfo -IP $($entry.'API-Input-IP') -searchtype &($entry.API) -wait 3"
				$Script:Result += Get-OnypheInfo -IP $entry.'API-Input-IP' -searchtype $entry.API -wait 3
			} 
			if ($entry.'API-Input-Other') {
				$Script:Result += Get-OnypheInfo -searchtype $entry.API -datascanstring $entry.'API-Input-Other' -wait 3
			}
		}
		$APIOtherEntries = $csvcontent | where-object {($_.API -ne "Search") -and ($_.API -ne "DataScan")}
		foreach ($entry in $APIOtherEntries) {
			If (($entry.API -ne "Ip") -and ($entry.'API-Input-IP')) {
				$Script:Result += Get-OnypheInfo -IP $entry.'API-Input-IP' -searchtype $entry.API -wait 3
			} Else {
				If ($entry.'API-Input-IP') {
					$Script:Result += Get-OnypheInfo -IP $entry.'API-Input-IP' -wait 3
				}
			}
		}
	}
	if ($Script:Result) {
		return $Script:Result
	} else {
		return $errorvalue
	}
}

function Search-OnypheInfo {
	<#
	 .SYNOPSIS 
	 main function/cmdlet - Search for IP information on onyphe.io web service using search API
 
	 .DESCRIPTION
	 main function/cmdlet - Search for IP information on onyphe.io web service using search API
	 send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
 
	 .PARAMETER AdvancedSearch
	 -AdvancedSearch ARRAY{filter:value,filter:value}
	 Search with multiple criterias
 
	 .PARAMETER SimpleSearchValue
	 -SimpleSearchValue STRING{value}
	 string to be searched with -SimpleSearchFilter parameter
 
	 .PARAMETER SimpleSearchFilter
	 -SimpleSearchFilter STRING{Get-OnypheSearchFilters}
	 Filter to be used with string set with SimpleSearchValue parameter
 
	 .PARAMETER SearchType
	 -SearchType STRING{Get-OnypheSearchCategories}
	 Search Type or Category
	 
	 .PARAMETER APIKey
	 -APIKey string{APIKEY}
	 set your APIKEY to be able to use Onyphe API.
 
	 .PARAMETER Page
	 -page string{page number}
	 go directly to a specific result page (1 to 1000)
 
	 .PARAMETER Wait
	 -Wait int{second}
	 wait for x second before sending the request to manage rate limiting restriction
	 
	 .OUTPUTS
	 TypeName: System.Management.Automation.PSCustomObject
	 
	 count            : 32
	 error            : 0
	 myip             : 90.245.80.180
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
	 C:\PS> Search-OnypheInfo -SimpleSearchValue RU -SearchType threatlist -SimpleSearchFilter country
 
	 .EXAMPLE
	 AdvancedSearch with multiple criteria/filters and set the API key
	 Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
	 C:\PS> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	 
	 .EXAMPLE
	 simple search with one filter/criteria and request page 2 of the results
	 Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	 C:\PS> Search-OnypheInfo -SimpleSearchValue RU -SearchType threatlist -SimpleSearchFilter country -page "2"
	 
 #>
	 [cmdletbinding()]
	 param(
		 [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false,Position=4)]
		 [ValidateNotNullOrEmpty()]  
			 [string]$SimpleSearchValue,
		 [parameter(Mandatory=$false,Position=1)] 
		 [ValidateNotNullOrEmpty()]
		     [Array]$AdvancedSearch,
		 [parameter(Mandatory=$false)]
		 [ValidateLength(40,40)]
		     [string[]]$APIKey,
		 [parameter(Mandatory=$false)]
		 [ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
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
		 $arrSet = Get-OnypheSearchCategories
		 $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
		 $AttributeCollection.Add($ValidateSetAttribute)
		 $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
		 $RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
		 
		 $ParameterNameFilter = 'SimpleSearchFilter'
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
		 
		 return $RuntimeParameterDictionary
	 }
	 Begin {
		 $SearchType = $PsBoundParameters[$ParameterNameType]
		 $SearchFilter = $PsBoundParameters[$ParameterNameFilter]
		 if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	 } Process {
		 if ($wait) {start-sleep -s $wait}
		 if ($AdvancedSearch) {
			 $params = @{
				AdvancedSearch = $AdvancedSearch
				SearchType = $SearchType
			 }
		} else {
			$params = @{
				SimpleSearchValue = $SimpleSearchValue
				SearchType = $SearchType
				SimpleSearchFilter = $SearchFilter
			}
		}
		if ($Page) {
			$params.add('Page', $page)
		}
	 } End {
			return Invoke-APIOnypheSearch @params
	 }
 }

function Get-OnypheInfo {
   <#
	.SYNOPSIS 
	main function/cmdlet - Get IP information from onyphe.io web service using dedicated subfunctions by searchtype

	.DESCRIPTION
	main function/cmdlet - Get IP information from onyphe.io web service using dedicated subfunctions by searchtype
	send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

	.PARAMETER searchtype Geoloc
	-IP string{IP} -searchtype Geoloc string{IP}
	look for geoloc information about a specfic ip address in onyphe database

	.PARAMETER myip
	-Myip
	look for information about my public IP
	
	.PARAMETER searchtype Inetnum
	-IP string{IP} -searchtype Inetnum -APIKey string{APIKEY}
	look for an ip address in onyphe database

	.PARAMETER searchtype Threatlist
	-IP string{IP} -searchtype Threatlist -APIKey string{APIKEY}
	look for threat info about a specific IP in onyphe database.
	
	.PARAMETER searchtype Pastries
	-IP string{IP} -searchtype Pastries -APIKey string{APIKEY}
	look for an pastbin data about a specific IP in onyphe database.
	
	.PARAMETER searchtype Synscan
	-IP string{IP} -searchtype Synscan -APIKey string{APIKEY}
	look for open ports info for a specific IP in onyphe database.

	.PARAMETER searchtype Reverse
	-IP string{IP} -searchtype Reverse string{IP} -APIKey string{APIKEY}
	look for xxx in onyphe database.

	.PARAMETER searchtype Forward
	-IP string{IP} -searchtype Forward -APIKey string{APIKEY}
	look for xxx in onyphe database.
	
	.PARAMETER searchtype DataScan
	-IP string{IP} -searchtype DataScan -datascanstring string -APIKey string{APIKEY}
	look for xxx in onyphe database.
	
	.PARAMETER datascanstring
	-IP string{IP} -searchtype DataScan -datascanstring string -APIKey string{APIKEY}
	look for an tcp service info for a specific IP in onyphe database.

	.PARAMETER IP
	-IP string{IP} -APIKey string{APIKEY}
	get all information available for a specific IP in onyphe database.
	
	.PARAMETER APIKey
	-APIKey string{APIKEY}
	set your APIKEY to be able to use Onyphe API.

	.PARAMETER Page
	-page string{page number}
	go directly to a specific result page (1 to 1000)

    .PARAMETER Wait
	-Wait int{second}
	wait for x second before sending the request to manage rate limiting restriction
	
	.OUTPUTS
	TypeName: System.Management.Automation.PSCustomObject
	
	count            : 32
	error            : 0
	myip             : 90.245.80.180
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
	C:\PS> Get-OnypheInfo -ip "192.168.1.5" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Looking for my public ip address
	C:\PS> Get-OnypheInfo -myip
	
	.EXAMPLE
	Request geoloc information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -ip "8.8.8.8" -searchtype Geoloc
	
	.EXAMPLE
	Request dns reverse information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -ip "8.8.8.8" -searchtype Reverse -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	request IIS keyword datascan information
	C:\PS> Get-OnypheInfo -searchtype DataScan -datascanstring "IIS" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	request datascan information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo ip "8.8.8.8" -searchtype DataScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request pastebin content information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -ip "8.8.8.8" -searchtype Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	.EXAMPLE
	Request pastebin content information for ip 8.8.8.8 and see page 2 of results
	C:\PS> Get-OnypheInfo -ip "8.8.8.8" -searchtype Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -page "2"
	
	.EXAMPLE
	Request dns forward information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -ip "8.8.8.8" -searchtype Forward -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request threatlist information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -ip "8.8.8.8" -searchtype Threatlist -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request inetnum information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -ip "8.8.8.8" -searchtype Inetnum -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request synscan information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -ip "8.8.8.8" -searchtype SynScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"	
#>
  [cmdletbinding()]
  Param (
  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false)]
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP,
  [parameter(Mandatory=$false)] 
     [ValidateSet('Geoloc','Inetnum','Pastries','SynScan','Reverse','Forward','Threatlist','DataScan')]
     [String]$searchtype, 
  [parameter(Mandatory=$false)]
	[String[]]$DataScanString,
  [parameter(Mandatory=$false)]
	[switch]$MyIP,
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey,
  [parameter(Mandatory=$false)]
  [ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
	[string[]]$Page,
  [parameter(Mandatory=$false)]
    [int]$wait
  )
 	if ($wait) {start-sleep -s $wait}
	if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	$params = @{
		IP = $IP
	}
	if ($Page) {$params.add('Page', $page)}
	If ($searchtype) {
		switch ($searchtype) {
			"Geoloc" {
				If ($Params.Page) {$params.Remove('Page')}
				return Invoke-APIOnypheGeoloc @params
			}
			"Inetnum" {
				return Invoke-APIOnypheInetnum @params
			}
			"Pastries" {
				return Invoke-APIOnyphePastries @params
			}
			"SynScan" {
				return Invoke-APIOnypheSynScan @params
			}
			"Reverse" {
				return Invoke-APIOnypheReverse @params
			}
			"Forward" {
				return Invoke-APIOnypheForward @params
			}
			"Threatlist" {
				return Invoke-APIOnypheThreatlist @params
			}
			"DataScan" {
				If ($IP) {
					return Invoke-APIOnypheDataScan @params
				} Else {
					$params.remove('IP')
					$params.add('DataScanString',$DataScanString)
					return Invoke-APIOnypheDataScan @params
				}
			}
		}
	}
	if ($IP) {
		return Invoke-APIOnypheIP @params
	}
	If ($MyIP.IsPresent -eq $true) {
		return Invoke-APIOnypheMyIP
	}
}

function Get-OnypheUserInfo {
	<#
	 .SYNOPSIS 
	 main function/cmdlet - Get user account information (rate limiting status, requests remaining in pool...) from onyphe.io web service
 
	 .DESCRIPTION
	 main function/cmdlet - Get user account information (rate limiting status, requests remaining in pool...) from onyphe.io web service
	 send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
 	 
	 .PARAMETER APIKey
	 -APIKey string{APIKEY}
	 set your APIKEY to be able to use Onyphe API.

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
	myip             NoteProperty string myip=85.10.100.250
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
	 [string[]]$APIKey,
   [parameter(Mandatory=$false)]
	 [int]$wait
   )
	if ($wait) {start-sleep -s $wait}
	if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	return Invoke-APIOnypheUser
 }

function Invoke-APIOnypheUser {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-Onyphe function and then call it to get the user account info from user API
  
	  .DESCRIPTION
	  create several input for Invoke-Onyphe function and then call it to get the user account info from user API
	  	  
	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
	  Set APIKEY as global variable.
	  
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
		myip             NoteProperty string myip=90.5.90.101
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
	  [string[]]$APIKey
	)
	  Begin {
		  if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	  } Process {
			$params = @{
				request = "user/"
				APIInfo = "user"
				APIInput = "none"
				APIKeyrequired = $true
			}
	  } End {
			Write-Verbose -message "URL Info : $($params.request)"  
			return Invoke-Onyphe @params
	  }
  }

function Invoke-APIOnypheInetnum {
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
	myip             NoteProperty string myip=192.168.1.66
	results          NoteProperty Object[] results=System.Object[]
	status           NoteProperty string status=ok
	took             NoteProperty string took=0.001305
	total            NoteProperty int total=1
	
	count            : 28
	error            : 0
	myip             : 192.168.1.66
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
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP, 
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey,
  [parameter(Mandatory=$false)]
  [ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
	[string[]]$Page
  )
	Begin {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	} Process {
		$params = @{
			request = "inetnum/$($IP)"
			APIInfo = "inetnum"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
	} End {
		Write-Verbose -message "URL Info : $($params.request)"
		return Invoke-Onyphe @params
	}
}

function Invoke-APIOnyphePastries {
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
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP, 
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey,
  [parameter(Mandatory=$false)]
  [ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
	[string[]]$Page
  )
	Begin {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	} Process {
		$params = @{
			request = "pastries/$($IP)"
			APIInfo = "patries"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
	} End {
		Write-Verbose -message "URL Info : $($params.request)"
		return Invoke-Onyphe @params
	}
}

function Invoke-APIOnypheSynScan {
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
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP, 
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey,
  [parameter(Mandatory=$false)]
  [ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
	[string[]]$Page
  )
	Begin {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	} Process {
		$params = @{
			request = "synscan/$($IP)"
			APIInfo = "synscan"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
	} End {
		Write-Verbose -message "URL Info : $($params.request)"
		return Invoke-Onyphe @params
	}
}

function Invoke-APIOnypheReverse {
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
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP, 
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey,
  [parameter(Mandatory=$false)]
  [ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
	[string[]]$Page
  )
	Begin {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	} Process {
		$params = @{
			request = "reverse/$($IP)"
			APIInfo = "reverse"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
	} End {
		Write-Verbose -message "URL Info : $($params.request)"
		return Invoke-Onyphe @params
	}
}

function Invoke-APIOnypheForward {
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
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP, 
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey,
  [parameter(Mandatory=$false)]
  [ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
	[string[]]$Page
  )
	Begin {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	} Process {
		$params = @{
			request = "forward/$($IP)"
			APIInfo = "forward"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
	} End {
		Write-Verbose -message "URL Info : $($params.request)"
		return Invoke-Onyphe @params
	}
}

function Invoke-APIOnypheThreatlist {
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
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP, 
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey,
  [parameter(Mandatory=$false)]
  [ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
	[string[]]$Page
  )
	Begin {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	} Process {
		$params = @{
			request = "threatlist/$($IP)"
			APIInfo = "threatlist"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
	} End {
		Write-Verbose -message "URL Info : $($params.request)"
		return Invoke-Onyphe @params
	}
}

function Invoke-APIOnypheDataScan {
   <#
	.SYNOPSIS 
	create several input for Invoke-Onyphe function and then call it to get the data scan info from datascan API

	.DESCRIPTION
	create several input for Invoke-Onyphe function and then call it to get the data scan info from datascan API
	
	.PARAMETER IP
	-IP string{IP}
	IP to be used for the DataScan API usage

	.PARAMETER DataScanString
	-DataScanString string
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
	C:\PS> Invoke-APIOnypheDataScan -IP 27.251.29.154

	.EXAMPLE
	get all info for info available for PanWeb web server
	C:\PS> Invoke-APIOnypheDataScan -DataScanString "PanWeb"

	.EXAMPLE
	get all data scan info for IP 27.251.29.154 and set the api key
	C:\PS> Invoke-APIOnypheDataScan -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
  #> 
 [cmdletbinding()]
  Param (
  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false)]
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP, 
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey,
  [parameter(Mandatory=$false)]
	[String[]]$DataScanString,
  [parameter(Mandatory=$false)]
  [ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
	[string[]]$Page
  )
	Begin {
		$script:DateRequest = get-date
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		if (!$IP -and !$DataScanString) {
				$errorvalue = [PSCustomObject]@{
								Count = 0
								error = ""
								myip = 0
								results = ''
								'cli-error_results' = "Please provide an IP or string to use the API"
								status = "ko"
								took = 0
								total = 0
								'cli-API_info' = $APIInfo
								'cli-API_input' = $APIInput
								'cli-key_required' = $APIKeyrequired
								'cli-Request_Date' = $script:DateRequest
								}
		}
	} Process {
		if (!$errorvalue) {
			If ($IP) {
				$params = @{
					request = "datascan/$($IP)"
					APIInput = "$($IP)"
				}
			} Else {
				$params = @{
					request = "datascan/$($DatascanString)"
					APIInput = "$($DatascanString)"
				}
			}
			$params.add('APIInfo',"datascan")
			$params.add('APIKeyrequired',$true)
			if ($page) {$params.add('page',$page)}
		}
	} End {
		if (!$errorvalue) {
			Write-Verbose -message "URL Info : $($params.request)"
			return Invoke-Onyphe @params
		} else {
			return $errorvalue
		}
	}
}

function Invoke-APIOnypheIP {
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
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP, 
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey,
	[parameter(Mandatory=$false)]
	[ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
	   [string[]]$Page
  )
	Begin {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	} Process {
		$params = @{
			request = "ip/$($IP)"
			APIInfo = "ip"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
	} End {
		Write-Verbose -message "URL Info : $($params.request)"
		return Invoke-Onyphe @params
	}			
}

function Invoke-APIOnypheMyIP {
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
	myip             : 75.170.200.100
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
	$params = @{
		request = "myip/"
		APIInfo = "myip"
		APIInput = "none"
		APIKeyrequired = $false
	} 
	Write-Verbose -message "URL Info : $($params.request)"
	return Invoke-Onyphe @params			
}

function Invoke-APIOnypheGeoloc {
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
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP
  )
	$params = @{
		request = "geoloc/$($IP)"
		APIInfo = "geoloc"
		APIInput = @("$($IP)")
		APIKeyrequired = $false
	}
	Write-Verbose -message "URL Info : $($params.request)"
	return Invoke-Onyphe @params
}

function Invoke-Onyphe {
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
  [ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})] 
    [string[]]$page
  )
  Begin {
		$script:onypheurl = "https://www.onyphe.io/api/"
		$script:DateRequest = get-date
		if (($APIKeyrequired)-and(!$global:OnypheAPIKey)) {
			write-verbose -message "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
			$errorvalue = [PSCustomObject]@{
							Count = 0
							error = ""
							myip = 0
							results = ''
							'cli-error_results' = "Please provide an APIKey with -APIKEY parameter"
							status = "ko"
							took = 0
							total = 0
							'cli-API_info' = $APIInfo
							'cli-API_input' = $APIInput
							'cli-key_required' = $APIKeyrequired
							'cli-Request_Date' = $script:DateRequest
							}
		}
  } Process {
		try {
			if (-not $errorvalue) {
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
				$onypheresult = invoke-webrequest @params
				#$onypheresult = invoke-webrequest "$($fullonypheurl)" -UseBasicParsing
			}
		} catch {
			write-verbose -message "Not able to use onyphe online service - KO"
			write-verbose -message "Error Type: $($_.Exception.GetType().FullName)"
			write-verbose -message "Error Message: $($_.Exception.Message)"
			write-verbose -message "HTTP error code:$($_.Exception.Response.StatusCode.Value__)"
			write-verbose -message "HTTP error message:$($_.Exception.Response.StatusDescription)"
			#$errorvalue = @()
			$errorcode = $_.Exception.Response.StatusCode.value__
			$result = $_.Exception.Response.GetResponseStream()
			$reader = New-Object System.IO.StreamReader($result)
			$reader.BaseStream.Position = 0
			$httpbody = $reader.ReadToEnd()
			if (($errorcode -eq 429) -or ($errorcode -eq 200)) {
				$errorvalue = $httpbody | Convertfrom-Json
				$errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_info' -Value $APIInfo
				$errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_input' -Value $APIInput
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
					'cli-key_required' = $APIKeyrequired
					'cli-Request_Date' = $script:DateRequest
				}
			}
		}
		if (-not $errorvalue) {
			try {
				$temp = $onypheresult.Content | convertfrom-json
				$temp | add-member -MemberType NoteProperty -Name 'cli-API_info' -Value $APIInfo
				$temp | add-member -MemberType NoteProperty -Name 'cli-API_input' -Value $APIInput
				$temp | add-member -MemberType NoteProperty -Name 'cli-key_required' -Value $APIKeyrequired
				$temp | add-member -MemberType NoteProperty -Name 'cli-Request_Date' -Value $script:DateRequest
				if ($debug -or $verbose) {
					$temp | add-member -MemberType NoteProperty -Name cli-API_Request -Value "$($request)"
				}
			} catch {
				write-verbose -message "unable to convert result into a powershell object - json error"
				write-verbose -message "Error Type: $($_.Exception.GetType().FullName)"
				write-verbose -message "Error Message: $($_.Exception.Message)"
				#$errorvalue = @()
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
					'cli-key_required' = $APIKeyrequired
					'cli-Request_Date' = $script:DateRequest
				}
			}
		}
	} End {
		if ($errorvalue) {
			return $errorvalue
		}elseif ($temp) {
			return $temp
		}
	}
}

function Export-OnypheInfoToFile {
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
  [ValidateScript({(($_ | Get-Member | Select-Object -ExpandProperty TypeName -Unique) -eq 'System.Management.Automation.PSCustomObject')})]
	$inputobject,
  [parameter(Mandatory=$false)]
    $csvdelimiter
  )
  if (!$csvdelimiter) {$csvdelimiter = ";"}
  foreach ($result in $inputobject) {
	$tempfolder = $null
	$filterbaseobj = $result | Select-Object *,@{Name='cli-API_input_mod';Expression={[string]::join(",",($_.'cli-API_input'))}} -ExcludeProperty results,'cli-API_input','cli-API_info','cli-key_required'
	$tempattrib = $filterbaseobj.'cli-API_input_mod' -replace ("[{0}]"-f (([System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object {[regex]::Escape($_)}) -join '|')),'_'
	$tempfolder = "Onyphe-result-$($tempattrib)"
	$tempfolder = join-path $tofolder $tempfolder
	if (!(test-path $tempfolder)) {mkdir $tempfolder -force | out-null}
	$ticks = (get-date).ticks.ToString()
	$filterbaseobj | Export-Csv -NoTypeInformation -path "$($tempfolder)\$($ticks)_request_info.csv" -delimiter $csvdelimiter
	switch ($result.results.'@category') {
		'geoloc' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'geoloc'} | sort-object -property country
			$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_Geoloc.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'inetnum' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'inetnum'} | sort-object -property seen_date | Select-Object *,@{Name='cli-information';Expression={[string]::join(",",($_.information))}},@{Name='cli-tag';Expression={[string]::join(",",($_.tag))}} -ExcludeProperty tag,information
			$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_inetnum.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'synscan' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'synscan'} | sort-object -property seen_date | Select-Object *,@{Name='cli-tag';Expression={[string]::join(",",($_.tag))}} -ExcludeProperty tag
			$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_synscan.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'resolver'{
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'resolver'} | sort-object -property seen_date | Select-Object *,@{Name='cli-subdomains';Expression={[string]::join(",",($_.subdomains))}},@{Name='cli-tag';Expression={[string]::join(",",($_.tag))}} -ExcludeProperty subdomains,tag
			$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_resolver.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'threatlist' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'threatlist'} | sort-object -property seen_date | Select-Object *,@{Name='cli-tag';Expression={[string]::join(",",($_.tag))}} -ExcludeProperty tag
			$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_threatlist.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'pastries' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'pastries'} | sort-object -property seen_date | Select-Object *,@{Name='cli-tld';Expression={[string]::join(",",($_.tld))}},@{Name='cli-url';Expression={[string]::join(",",($_.url))}},@{Name='cli-subdomains';Expression={[string]::join(",",($_.subdomains))}},@{Name='cli-scheme';Expression={[string]::join(",",($_.scheme))}},@{Name='cli-Key';Expression={"https://pastebin.com/$($_.key)"}},@{Name='cli-domain';Expression={[string]::join(",",($_.domain))}},@{Name='cli-file';Expression={[string]::join(",",($_.file))}},@{Name='cli-host';Expression={[string]::join(",",($_.host))}},@{Name='cli-hostname';Expression={[string]::join(",",($_.hostname))}},@{Name='cli-ip';Expression={[string]::join(",",($_.ip))}},@{Name='cli-tag';Expression={[string]::join(",",($_.tag))}} -ExcludeProperty ip,hostname,domain,scheme,subdomains,url,tld,host,file,content,tag
			$filteredobjfull = $result.results | where-object {$_.'@category' -eq 'pastries'} | sort-object -property seen_date
			$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_Pastries.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			foreach ($contentresult in $filteredobjfull) {
				if ($contentresult.ip.count -gt 1) {
					$ip = "multips-$($contentresult.ip[0].Replace(":","-"))"
					$allip = $contentresult.ip -join ","
				} else {
					$ip = $contentresult.ip
				}
				$temptimestamp = $contentresult.'@timestamp' -replace ":","_"
				$tempfilecontentresult = "$($ticks)_$($temptimestamp)_$($ip)_pastries_$($contentresult.key).txt"
				$tempcontentexportfile = join-path $tempfolder $tempfilecontentresult
				if ($allip) {
					add-content -path $tempcontentexportfile -value "########### info ip ###########"
					add-content -path $tempcontentexportfile -value $allip
					add-content -path $tempcontentexportfile -value "########### info ip ###########"
				}
				$contentresult.content | add-content -path $tempcontentexportfile
			}
		}
		'sniffer' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'sniffer'} | sort-object -property seen_date | Select-Object *,@{Name='cli-tag';Expression={[string]::join(",",($_.tag))}} -ExcludeProperty tag
			$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_Sniffer.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'datascan' {
			$filteredobjfull = $result.results | where-object {$_.'@category' -eq 'datascan'} | sort-object -property seen_date
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'datascan'} | sort-object -property seen_date | Select-Object *,@{Name='cli-tag';Expression={[string]::join(",",($_.tag))}},@{Name='cli-app';Expression={[string]::join(",",($_.app))}} -ExcludeProperty data,app,tag
			$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_datascan.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			foreach ($dataresult in $filteredobjfull) {
				if ($dataresult.ip.count -gt 1) {
					$ip = "multips-$($dataresult.ip[0].Replace(":","-"))"
					$allip = $dataresult.ip -join ","
				} else {
					$ip = $dataresult.ip
				}
				$temptimestamp = $dataresult.'@timestamp' -replace ":","_"
				$tempfiledataresult = "$($ticks)_$($temptimestamp)_$($ip)_$($dataresult.port)_$($dataresult.protocol).txt"
				$tempdataexportfile = join-path $tempfolder $tempfiledataresult
				if ($allip) {
					add-content -path $tempdataexportfile -value "########### info ip ###########"
					add-content -path $tempdataexportfile -value $allip
					add-content -path $tempdataexportfile -value "########### info ip ###########"
				}
				$dataresult.data | add-content -path $tempdataexportfile
			}
		}
		'onionscan' {
			$filteredobjfull = $result.results | where-object {$_.'@category' -eq 'onionscan'} | sort-object -property seen_date
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'onionscan'} | sort-object -property seen_date | Select-Object *,@{Name='cli-tag';Expression={[string]::join(",",($_.tag))}} -ExcludeProperty data,tag
			$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_onionscan.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			foreach ($dataresult in $filteredobjfull) {
				if ($dataresult.ip.count -gt 1) {
					$ip = "multips-$($dataresult.ip[0].Replace(":","-"))"
					$allip = $dataresult.ip -join ","
				} else {
					$ip = $dataresult.ip
				}
				$temptimestamp = $dataresult.'@timestamp' -replace ":","_"
				$tempfiledataresult = "$($ticks)_$($temptimestamp)$($ip)__$($dataresult.port)_$($dataresult.protocol).txt"
				$tempdataexportfile = join-path $tempfolder $tempfiledataresult
				if ($allip) {
					add-content -path $tempdataexportfile -value "########### info ip ###########"
					add-content -path $tempdataexportfile -value $allip
					add-content -path $tempdataexportfile -value "########### info ip ###########"
				}
				$dataresult.data | add-content -path $tempdataexportfile
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
			if (!(Test-Path -Path "$($env:AppData)\$FolderName")) {
				New-Item -ItemType directory -Path "$($env:AppData)\$FolderName" | Out-Null
			}
			if (test-path "$($env:AppData)\$FolderName\$ConfigName") {
				Remove-item -Path "$($env:AppData)\$FolderName\$ConfigName" -Force | out-null
			}
			$ObjConfigOnyphe | Export-Clixml "$($env:AppData)\$FolderName\$ConfigName"
		}	
	}
  }
}

function Import-OnypheEncryptedIKey {
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
		$FolderName = 'Use-Onyphe'
		$ConfigName = 'Use-Onyphe-Config.xml'
        if (!(Test-Path "$($env:AppData)\$($FolderName)\$($ConfigName)")){
			Write-warning 'Configuration file has not been set, Set-OnypheAPIKey to configure the API Keys.'
			throw 'error config file not found'
        }
		$ObjConfigOnyphe = Import-Clixml "$($env:AppData)\$($FolderName)\$($ConfigName)"
        $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword
        $Rfc2898Deriver = New-Object System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $ObjConfigOnyphe.Salt
        $KeyBytes  = $Rfc2898Deriver.GetBytes(32)
        $SecString = ConvertTo-SecureString -Key $KeyBytes $ObjConfigOnyphe.EncryptedAPIKey
        $SecureStringToBSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecString)
        $APIKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto($SecureStringToBSTR)
        $global:OnypheAPIKey = $APIKey
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
		[XML]$SearchFilters = get-content $XMLFilePath
		return $SearchFilters.'use-onyphe'.'data-model'.filter
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
		  [XML]$SearchFilters = get-content $XMLFilePath
		  return $SearchFilters.'use-onyphe'.'data-model'.search
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
		  [XML]$SearchFilters = get-content $XMLFilePath
		  return $SearchFilters.'use-onyphe'.'data-model'.'cli-facet'
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
		  [XML]$SearchFilters = get-content $XMLFilePath
		  return $SearchFilters.'use-onyphe'.'data-model'.api
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
	  create several input for Invoke-Onyphe function and then call it to search info from search APIs

	  .DESCRIPTION
	  create several input for Invoke-Onyphe function and then call it to to search info from search APIs

	  .PARAMETER AdvancedSearch
	  -AdvancedSearch ARRAY{filter:value,filter:value}
	  Search with multiple criterias

	  .PARAMETER SimpleSearchValue
	  -SimpleSearchValue STRING{value}
	  string to be searched with -SimpleSearchFilter parameter

	  .PARAMETER SimpleSearchFilter
	  -SimpleSearchFilter STRING{Get-OnypheSearchFilters}
	  Filter to be used with string set with SimpleSearchValue parameter

	  .PARAMETER SearchType
	  -SearchType STRING{Get-OnypheSearchCategories}
	  Search Type or Category

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
			cli-Request_Date NoteProperty datetime cli-Request_Date=15/08/2018 15:05:25
			count            NoteProperty int count=10
			error            NoteProperty int error=0
			max_page         NoteProperty decimal max_page=1000,0
			myip             NoteProperty string myip=90.92.236.55
			page             NoteProperty int page=1000
			results          NoteProperty Object[] results=System.Object[]
			status           NoteProperty string status=ok
			took             NoteProperty string took=0.066
			total            NoteProperty int total=157611

			count            : 10
			error            : 0
			max_page         : 1000,0
			myip             : 90.92.234.60
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
	  C:\PS> Invoke-APIOnypheSearch -SimpleSearchValue RU -SearchType threatlist -SimpleSearchFilter country
	#>
	[cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false,Position=4)]
		[ValidateNotNullOrEmpty()]  
			[string]$SimpleSearchValue,
        [parameter(Mandatory=$false,Position=1)] 
        [ValidateNotNullOrEmpty()]
		   [Array]$AdvancedSearch,
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
		   [string[]]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^([1-9][0-9]{0,2}|1000)$"})]
		   [string[]]$Page
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
        $arrSet = Get-OnypheSearchCategories
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
        $AttributeCollection.Add($ValidateSetAttribute)
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
        
        $ParameterNameFilter = 'SimpleSearchFilter'
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
        
        return $RuntimeParameterDictionary
	}
	Begin {
        $SearchType = $PsBoundParameters[$ParameterNameType]
		$SearchFilter = $PsBoundParameters[$ParameterNameFilter]
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
    } Process {		
		if ($AdvancedSearch) {
			for ($i=0; $i -lt $AdvancedSearch.length; $i++) {
				$tmp = $null
				$tmp = $AdvancedSearch[$i] -split ":"
				if (($tmp[1] -match "\s") -and ($tmp[1] -notlike "`"*`"")) {$tmp[1] = "`"$($tmp[1])`""}
				$AdvancedSearch[$i] = $tmp -join ":"
			}
			$tmpvalue = $AdvancedSearch -join " "
			$tmpvaluemd = [System.Uri]::EscapeURIString($tmpvalue)
			$params = @{
				request = "search/$($SearchType)/$($tmpvaluemd)"
				APIInput = @("$($tmpvalue)")
			}
		} Else {
			if ($SimpleSearchValue -match "\s"){
				$SimpleSearchValue = "`"$($SimpleSearchValue)`""
				$SimpleSearchValuemd = [System.Uri]::EscapeURIString($SimpleSearchValue)
			} Else {
				$SimpleSearchValuemd = $SimpleSearchValue
			}
			$params = @{
				request = "search/$($SearchType)/$($SearchFilter):$($SimpleSearchValuemd)"
				APIInput = @("$($SearchFilter):$($SimpleSearchValue)")
			}
		}
		$params.add('APIInfo',"search/$($SearchType)")
		$params.add('APIKeyrequired',$true)
		if ($page) {$params.add('page',$page)}
	} End {
		Write-Verbose -message "URL Info : $($params.request)"
		return Invoke-Onyphe @params
	}
}

Export-ModuleMember -Function Get-OnypheCliFacets, Get-OnypheStatsFromObject, Set-OnypheProxy, Import-OnypheEncryptedIKey, Get-OnypheAPIName, Invoke-APIOnypheSearch, Get-OnypheSearchCategories, Get-OnypheSearchFilters, Get-OnypheUserInfo, Invoke-APIOnypheUser, Search-OnypheInfo, Get-OnypheInfo, Get-OnypheInfoFromCSV, Get-ScriptDirectory, Set-OnypheAPIKey, Export-OnypheInfoToFile,Invoke-APIOnypheDataScan, Invoke-APIOnypheForward, Invoke-APIOnypheGeoloc, Invoke-APIOnypheIP, Invoke-APIOnypheInetnum, Invoke-APIOnypheMyIP, Invoke-APIOnyphePastries, Invoke-APIOnypheReverse, Invoke-APIOnypheSynScan, Invoke-APIOnypheThreatlist, Invoke-Onyphe
