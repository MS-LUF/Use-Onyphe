#
# Created by: lucas.cueff[at]lucas-cueff.com
#
# v0.7 : 
# - split Invoke-WebonypheRequest into several sub functions to simplify evolutions : Invoke-APIOnypheDataScan, Invoke-APIOnypheForward, Invoke-APIOnypheGeoloc, Invoke-APIOnypheIP, Invoke-APIOnypheInetnum, Invoke-APIOnypheMyIP, Invoke-APIOnyphePastries, Invoke-APIOnypheReverse, Invoke-APIOnypheSynScan, Invoke-APIOnypheThreatlist, Invoke-Onyphe
# - remove multithreading feature
# - correct data scan bug : api can be used with IP or datastring now
# - add new property to get date of the request
# Released on: 01/2018
#
#'(c) 2017 lucas-cueff.com - Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).'

<#
	.SYNOPSIS 
	commandline interface to use onyphe.io web service

	.DESCRIPTION
	use-onyphe.psm1 module provides a commandline interface to onyphe.io web service.
	
	.EXAMPLE
	C:\PS> import-module use-onyphe.psm1
#>

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
	if (!$csvdelimiter) {$csvdelimiter = ";"}
	$Script:Result = @()
	$FromcsvType = $fromcsv | Get-Member | Select-Object -ExpandProperty TypeName -Unique
	if (!$global:OnypheAPIKey) {
		if (!$APIKEY) {
			if ($debug -or $verbose) {
				write-warning "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
			}
			$errorvalue = @()
			$errorvalue += "Please provide an APIKey with -APIKEY parameter"
		} Else {
			Set-OnypheAPIKey -APIKEY $APIKey | out-null
		} 
	}
	if ($errorvalue) {return $errorvalue}
	if (($FromcsvType -eq 'System.String') -and (test-path $fromcsv)) {
			$csvcontent = import-csv $fromcsv -delimiter $csvdelimiter
		} ElseIf (($FromcsvType -eq 'System.Management.Automation.PSCustomObject') -and $fromcsv.ip) {
			$csvcontent = $fromcsv
		} Else {
			if ($debug -or $verbose) {
				write-warning "provide a valid csv file as input or valid System.Management.Automation.PSCustomObject object"
				write-warning "please use the following column in your file : ip, searchtype, datascanstring"
			}
			$errorvalue = @()
			$errorvalue += "please provide a valid csv file as input or valid System.Management.Automation.PSCustomObject object"
			return $errorvalue
		}
		foreach ($entry in $csvcontent) {
			If (($entry.searchtype -ne 'DataScan') -and ($entry.searchtype -ne '') -and $entry.ip) {
				$Script:Result += Get-OnypheInfo -IP $entry.ip -searchtype $entry.searchtype -wait 3
			} ElseIf (($entry.searchtype -eq 'DataScan') -and ($entry.datascanstring -or $entry.ip)) {
				if ($entry.ip) {
					$Script:Result += Get-OnypheInfo -IP $entry.ip -searchtype $entry.searchtype -wait 3
				} else {
					$Script:Result += Get-OnypheInfo -searchtype $entry.searchtype -datascanstring $entry.datascanstring -wait 3
				}
			} Else {
				If ($entry.ip) {
					$Script:Result += Get-OnypheInfo -IP $entry.ip -wait 3
				}
			}
		}
	return $Script:Result
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
	
	.OUTPUTS
	TypeName: System.Management.Automation.PSCustomObject
	
	count            : 32
	error            : 0
	myip             : 86.246.69.187
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
    [int]$wait
  )
	if ($wait) {start-sleep -s $wait}
	if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
	if ($IP) {
		return Invoke-APIOnypheIP -IP $IP
	}
	If ($searchtype) {
		switch ($searchtype) {
			"Geoloc" {
				return Invoke-APIOnypheGeoloc -IP $IP
			}
			"Inetnum" {
				return Invoke-APIOnypheInetnum -IP $IP -APIKEY $global:OnypheAPIKey
			}
			"Pastries" {
				return Invoke-APIOnyphePastries -IP $IP -APIKEY $global:OnypheAPIKey
			}
			"SynScan" {
				return Invoke-APIOnypheSynScan -IP $IP -APIKEY $global:OnypheAPIKey
			}
			"Reverse" {
				return Invoke-APIOnypheReverse -IP $IP -APIKEY $global:OnypheAPIKey
			}
			"Forward" {
				return Invoke-APIOnypheForward -IP $IP -APIKEY $global:OnypheAPIKey
			}
			"Threatlist" {
				return Invoke-APIOnypheThreatlist -IP $IP -APIKEY $global:OnypheAPIKey
			}
			"DataScan" {
				If ($IP) {
					return Invoke-APIOnypheDataScan -IP $IP -APIKEY $APIKey
				} Else {
					return Invoke-APIOnypheDataScan -DataScanString $DataScanString -APIKEY $APIKey
				}
			}
		}
	}
	If ($MyIP.IsPresent -eq $true) {
		return Invoke-APIOnypheMyIP
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
	[string[]]$APIKey
  )
	Begin {
		$script:DateRequest = get-date
		if (!$global:OnypheAPIKey) {
			if (!$APIKEY) {
				if ($debug -or $verbose) {
					write-warning "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
				}
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
			} Else {
				Set-OnypheAPIKey -APIKEY $APIKey | out-null
			}
		}
	} Process {
			if ($errorvalue) {
				return $errorvalue
			} Else {
				$request = "inetnum/$($IP)?apikey=$($global:OnypheAPIKey)"
				$APIInfo = "inetnum"
				$APIInput = @("$($IP)")
				$APIKeyrequired = $true
			}
	} End {
		if (!$errorvalue) {
			return Invoke-Onyphe -request $request -APIInfo $APIInfo -APIInput $APIInput -APIKeyrequired $APIKeyrequired
		}
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
	[string[]]$APIKey
  )
	Begin {
		$script:DateRequest = get-date
		if (!$global:OnypheAPIKey) {
			if (!$APIKEY) {
				if ($debug -or $verbose) {
					write-warning "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
				}
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
			} Else {
				Set-OnypheAPIKey -APIKEY $APIKey | out-null
			}
		}
	} Process {
			if ($errorvalue) {
				return $errorvalue
			} Else {
				$request = "pastries/$($IP)?apikey=$($global:OnypheAPIKey)"
				$APIInfo = "patries"
				$APIInput = @("$($IP)")
				$APIKeyrequired = $true
			}
	} End {
		if (!$errorvalue) {
			return Invoke-Onyphe -request $request -APIInfo $APIInfo -APIInput $APIInput -APIKeyrequired $APIKeyrequired
		}
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
	[string[]]$APIKey
  )
	Begin {
		$script:DateRequest = get-date
		if (!$global:OnypheAPIKey) {
			if (!$APIKEY) {
				if ($debug -or $verbose) {
					write-warning "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
				}
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
			} Else {
				Set-OnypheAPIKey -APIKEY $APIKey | out-null
			}
		}
	} Process {
			if ($errorvalue) {
				return $errorvalue
			} Else {
				$request = "synscan/$($IP)?apikey=$($global:OnypheAPIKey)"
				$APIInfo = "synscan"
				$APIInput = @("$($IP)")
				$APIKeyrequired = $true
			}
	} End {
		if (!$errorvalue) {
			return Invoke-Onyphe -request $request -APIInfo $APIInfo -APIInput $APIInput -APIKeyrequired $APIKeyrequired
		}
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
	[string[]]$APIKey
  )
	Begin {
		$script:DateRequest = get-date
		if (!$global:OnypheAPIKey) {
			if (!$APIKEY) {
				if ($debug -or $verbose) {
					write-warning "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
				}
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
			} Else {
				Set-OnypheAPIKey -APIKEY $APIKey | out-null
			}
		}
	} Process {
			if ($errorvalue) {
				return $errorvalue
			} Else {
				$request = "reverse/$($IP)?apikey=$($global:OnypheAPIKey)"
				$APIInfo = "reverse"
				$APIInput = @("$($IP)")
				$APIKeyrequired = $true
			}
	} End {
		if (!$errorvalue) {
			return Invoke-Onyphe -request $request -APIInfo $APIInfo -APIInput $APIInput -APIKeyrequired $APIKeyrequired
		}
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
	
	.PARAMETER Remove
	-Remove
	Remove your current APIKEY from global variable.
	
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
	[string[]]$APIKey
  )
	Begin {
		$script:DateRequest = get-date
		if (!$global:OnypheAPIKey) {
			if (!$APIKEY) {
				if ($debug -or $verbose) {
					write-warning "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
				}
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
			} Else {
				Set-OnypheAPIKey -APIKEY $APIKey | out-null
			}
		}
	} Process {
			if ($errorvalue) {
				return $errorvalue
			} Else {
				$request = "forward/$($IP)?apikey=$($global:OnypheAPIKey)"
				$APIInfo = "forward"
				$APIInput = @("$($IP)")
				$APIKeyrequired = $true
			}
	} End {
		if (!$errorvalue) {
			return Invoke-Onyphe -request $request -APIInfo $APIInfo -APIInput $APIInput -APIKeyrequired $APIKeyrequired
		}
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
	[string[]]$APIKey
  )
	Begin {
		$script:DateRequest = get-date
		if (!$global:OnypheAPIKey) {
			if (!$APIKEY) {
				if ($debug -or $verbose) {
					write-warning "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
				}
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
			} Else {
				Set-OnypheAPIKey -APIKEY $APIKey | out-null
			}
		}
	} Process {
			if ($errorvalue) {
				return $errorvalue
			} Else {
				$request = "threatlist/$($IP)?apikey=$($global:OnypheAPIKey)"
				$APIInfo = "threatlist"
				$APIInput = @("$($IP)")
				$APIKeyrequired = $true
			}
	} End {
		if (!$errorvalue) {
			return Invoke-Onyphe -request $request -APIInfo $APIInfo -APIInput $APIInput -APIKeyrequired $APIKeyrequired
		}
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
    [String[]]$DataScanString
  )
	Begin {
		$script:DateRequest = get-date
		if (!$global:OnypheAPIKey) {
			if (!$APIKEY) {
				if ($debug -or $verbose) {
					write-warning "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
				}
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
			} Else {
				Set-OnypheAPIKey -APIKEY $APIKey | out-null
			}
		}
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
			if ($errorvalue) {
				return $errorvalue
			} Else {
				If ($IP) {
					$request = "datascan/$($IP)?apikey=$($global:OnypheAPIKey)"
					$APIInput = "$($IP)"
				} Else {
					$request = "datascan/$($DatascanString)?apikey=$($global:OnypheAPIKey)"
					$APIInput = "$($DatascanString)"
				}
				$APIInfo = "datascan"
				$APIKeyrequired = $true
			}
	} End {
		if (!$errorvalue) {
			return Invoke-Onyphe -request $request -APIInfo $APIInfo -APIInput $APIInput -APIKeyrequired $APIKeyrequired
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
	[string[]]$APIKey
  )
	Begin {
		$script:DateRequest = get-date
		if (!$global:OnypheAPIKey) {
			if (!$APIKEY) {
				if ($debug -or $verbose) {
					write-warning "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
				}
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
			} Else {
				Set-OnypheAPIKey -APIKEY $APIKey | out-null
			}
		}
	} Process {
			if ($errorvalue) {
				return $errorvalue
			} Else {
				$request = "ip/$($IP)?apikey=$($global:OnypheAPIKey)"
				$APIInfo = "ip"
				$APIInput = @("$($IP)")
				$APIKeyrequired = $true
			}
	} End {
		if (!$errorvalue) {
			return Invoke-Onyphe -request $request -APIInfo $APIInfo -APIInput $APIInput -APIKeyrequired $APIKeyrequired
		}
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
	$request = "myip/"
	$APIInfo = "myip"
	$APIInput = "none"
	$APIKeyrequired = $false
	return Invoke-Onyphe -request $request -APIInfo $APIInfo -APIInput $APIInput -APIKeyrequired $APIKeyrequired			
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
	$request = "geoloc/$($IP)"
	$APIInfo = "geoloc"
	$APIInput = @("$($IP)")
	$APIKeyrequired = $false
	return Invoke-Onyphe -request $request -APIInfo $APIInfo -APIInput $APIInput -APIKeyrequired $APIKeyrequired
}

function Invoke-Onyphe {
  [cmdletbinding()]
  Param (
  [parameter(Mandatory=$true)]
    [string[]]$request,
  [parameter(Mandatory=$true)]
	[string[]]$APIInfo,
  [parameter(Mandatory=$true)]
    [string[]]$APIInput,
  [parameter(Mandatory=$true)]
	[Bool[]]$APIKeyrequired
  )
  Begin {
		$script:onypheurl = "https://www.onyphe.io/api/"
		$script:DateRequest = get-date
  } Process {
		try {
			$onypheresult = invoke-webrequest "$($onypheurl)$($request)"
		} catch {
			if ($debug -or $verbose) {
				write-warning "Not able to use onyphe online service - KO"
				write-warning "Error Type: $($_.Exception.GetType().FullName)"
				write-warning "Error Message: $($_.Exception.Message)"
				write-warning "HTTP error code:$($_.Exception.Response.StatusCode.Value__)"
				write-warning "HTTP error message:$($_.Exception.Response.StatusDescription)"
			}
		   $errorvalue = @()
		   $errorvalue += [PSCustomObject]@{
				Count = 0
				error = $_.Exception.Response.StatusCode.Value__
				myip = 0
				results = ''
				'cli-error_results' = "$($_.Exception.Response.StatusDescription)"
				status = "ko"
				took = 0
				total = 0
				'cli-API_info' = $APIInfo
				'cli-API_input' = $APIInput
				'cli-key_required' = $APIKeyrequired
				'cli-Request_Date' = $script:DateRequest
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
				if ($debug -or $verbose) {
					write-warning "unable to convert result into a powershell object - json error"
					write-warning "Error Type: $($_.Exception.GetType().FullName)"
					write-warning "Error Message: $($_.Exception.Message)"
				}
				$errorvalue = @()
				$errorvalue += [PSCustomObject]@{
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
		if ($temp) {return $temp}
		if ($errorvalue) {return $errorvalue}
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
  [ValidateScript({(($_ | Get-Member | Select-Object -ExpandProperty TypeName -Unique) -eq 'System.Management.Automation.PSCustomObject') -or (($_ | Get-Member | Select-Object -ExpandProperty TypeName -Unique) -eq 'Selected.RSJob')})]
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
			$tempfilename = join-path $tempfolder "$($ticks)_Geoloc.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'inetnum' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'inetnum'} | sort-object -property seen_date | Select-Object *,@{Name='cli-information';Expression={[string]::join(",",($_.information))}} -ExcludeProperty information
			$tempfilename = join-path $tempfolder "$($ticks)_inetnum.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'synscan' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'synscan'} | sort-object -property seen_date
			$tempfilename = join-path $tempfolder "$($ticks)_synscan.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'resolver'{
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'resolver'} | sort-object -property seen_date
			$tempfilename = join-path $tempfolder "$($ticks)_resolver.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'threatlist' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'threatlist'} | sort-object -property seen_date
			$tempfilename = join-path $tempfolder "$($ticks)_threatlist.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'pastries' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'pastries'} | sort-object -property seen_date | Select-Object *,@{Name='cli-URL';Expression={"https://pastebin.com/$($_.key)"}},@{Name='cli-domain';Expression={[string]::join(",",($_.domain))}},@{Name='cli-hostname';Expression={[string]::join(",",($_.hostname))}},@{Name='cli-ip';Expression={[string]::join(",",($_.ip))}} -ExcludeProperty ip,hostname,domain
			$tempfilename = join-path $tempfolder "$($ticks)_Pastries.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		}
		'datascan' {
			$filteredobj = $result.results | where-object {$_.'@category' -eq 'datascan'} | sort-object -property seen_date
			$filteredobjfull = $result.results | where-object {$_.'@category' -eq 'datascan'} | sort-object -property seen_date | Select-Object -ExcludeProperty data
			$tempfilename = join-path $tempfolder "$($ticks)_datascan.csv"
			$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			foreach ($dataresult in $filteredobjfull) {
				$temptimestamp = $dataresult.'@timestamp' -replace ":","_"
				$tempfiledataresult = "$($ticks)_$($temptimestamp)_$($dataresult.port)_$($dataresult.protocol).txt"
				$tempdataexportfile = join-path $tempfolder $tempfiledataresult
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
	
	.PARAMETER Remove
	-Remove
	Remove your current APIKEY from global variable.
	
	.OUTPUTS
	apikey set as string
	
	.EXAMPLE
	Set your API key as global variable so it will be used automatically by all use-onyphe functions
	C:\PS> Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Remove your API key set as global variable
	C:\PS> Set-OnypheAPIKey -remove

  #>
  [cmdletbinding()]
  Param (
    [parameter(Mandatory=$false)]
    [ValidateLength(40,40)]
	[string[]]$APIKey,
	[parameter(Mandatory=$false)]
	[switch]$Remove
  )
  if ($Remove.IsPresent) {
	$global:OnypheAPIKey = $Null
  } Else {
	$global:OnypheAPIKey = $APIKey
	return $global:OnypheAPIKey
  }
}

Export-ModuleMember -Function Get-OnypheInfo, Get-OnypheInfoFromCSV, Get-ScriptDirectory, Set-OnypheAPIKey, Export-OnypheInfoToFile,Invoke-APIOnypheDataScan, Invoke-APIOnypheForward, Invoke-APIOnypheGeoloc, Invoke-APIOnypheIP, Invoke-APIOnypheInetnum, Invoke-APIOnypheMyIP, Invoke-APIOnyphePastries, Invoke-APIOnypheReverse, Invoke-APIOnypheSynScan, Invoke-APIOnypheThreatlist, Invoke-Onyphe
