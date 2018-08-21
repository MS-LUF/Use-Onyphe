# Use-Onyphe
Simple PowerShell module to use Onyphe.io API

Onyphe.io provides data about IP address space and publicly available information in just one place.

Some of the APIs required an API key. 
To request it : https://www.onyphe.io/login

More info about available APIs :
https://www.onyphe.io/documentation/api

(c) 2018 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).

## Notes version (0.90)
- manage new search APIs
- code refactoring
- fix file export for new categories and properties
- manage proxy connection
- manage API key storage with encryption in a config file
- add paging feature on search and info functions

## install use-onyphe from PowerShell Gallery repository
You can easily install it from powershell gallery repository
https://www.powershellgallery.com/packages/Use-Onyphe/
using a simple powershell command and an internet access :-) 
```
	Install-Module -Name Use-Onyphe
```

## import module from PowerShell 
```
	.SYNOPSIS 
	commandline interface to use onyphe.io web service

	.DESCRIPTION
	use-onyphe.psm1 module provides a commandline interface to onyphe.io web service.
	Require PoshRSJob PowerShell module to use multithreading option of get-onypheinfo function.
	
	.EXAMPLE
	C:\PS> import-module use-onyphe.psm1
```

## module content
### Get-OnypheInfoFromCSV function
```
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
```

### Search-OnypheInfo function
```
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
```

### Get-OnypheInfo function
```
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
```

### Get-OnypheUserInfo function
```
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
```

### Invoke-APIOnypheUser function
```
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
```

### Invoke-APIOnypheInetnum function
```
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
	
```
  
### Invoke-APIOnyphePastries function
```
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

```

### Invoke-APIOnypheSynScan function
```
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

 ```
 
 ### Invoke-APIOnypheReverse function
 ```
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
	
 ```
 
 ### Invoke-APIOnypheForward function
 ```
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

```

### Invoke-APIOnypheThreatlist function
```
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
 ```
 
 ### Invoke-APIOnypheDataScan function
 ```
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

 ```
 
 ### Invoke-APIOnypheIP function
 ```
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
```

### Invoke-APIOnypheMyIP function
```
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
 ```
 
 ### Invoke-APIOnypheGeoloc function
 ```
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
```
 
### Export-OnypheInfoToFile function
```
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
 ```

### Get-ScriptDirectory function
```
	.SYNOPSIS 
	retrieve current script directory

	.DESCRIPTION
	retrieve current script directory
```

### Set-OnypheAPIKey function
```
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

```

### Import-OnypheEncryptedIKey function
```
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
```

### Get-OnypheSearchFilters function
```
	.SYNOPSIS 
	Get filters available for search APIs of Onyphe

	.DESCRIPTION
	Get filters available for search APIs of Onyphe
	
	.OUTPUTS
	filters as string
	
	.EXAMPLE
	Get filters available for search APIs of Onyphe
	C:\PS> Get-OnypheSearchFilters
```

### Get-OnypheSearchCategories function
```
	  .SYNOPSIS 
	  Get category available for search APIs of Onyphe
  
	  .DESCRIPTION
	  Get category available for search APIs of Onyphe
	  
	  .OUTPUTS
	  filters as string
	  
	  .EXAMPLE
	  Get category available for search APIs of Onyphe
	  C:\PS> Get-OnypheSearchCategories
```

### Get-OnypheAPIName function
```
	  .SYNOPSIS 
	  Get API available for Onyphe
  
	  .DESCRIPTION
	  Get API available for Onyphe
	  
	  .OUTPUTS
	  API as string
	  
	  .EXAMPLE
	  Get API available for Onyphe
	  C:\PS> Get-OnypheAPIName
```

### Set-OnypheProxy function
```
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
```

### Invoke-APIOnypheSearch function
```
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
```