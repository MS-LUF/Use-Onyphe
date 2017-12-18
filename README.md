# Use-Onyphe
Simple PowerShell module to use Onyphe.io API

Onyphe.io provides data about IP address space and publicly available information in just one place.

Some of the APIs required an API key. 
To request it : https://www.onyphe.io/login

More info about available APIs :
https://www.onyphe.io/documentation/api

<#
	.SYNOPSIS 
	commandline interface to use onyphe.io web service

	.DESCRIPTION
	use-onyphe.psm1 module provides a commandline interface to onyphe.io web service.
	Require PoshRSJob PowerShell module to use multithreading option of get-onypheinfo function.
	
	.EXAMPLE
	C:\PS> import-module use-onyphe.psm1
#>

 <#
	.SYNOPSIS 
	Get IP information from onyphe.io web service using as an input a CSV file containing all information

	.DESCRIPTION
	get various ip data information from onyphe.io web service using as an input a csv file (; separator)
	
	.PARAMETER fromcsv
	-fromcsv string{full path to csv file}
	automate onyphe.io request for multiple IP
	
	.PARAMETER APIKey
	-APIKey string{APIKEY}
	set your APIKEY to be able to use Onyphe API.
	
	.PARAMETER multithreading
	-multithreading switch
	 use .Net RunSpace to run invoke-webonypherequest in parallel to decrease execution time.
	 warning : do not provide more than 10 requests in a csv using this option or some of your requests could be blocked by rate limiting feature of the web server.
	
	.OUTPUTS
	TypeName: System.Management.Automation.PSCustomObject
	
	count   : 32
	error   : 0
	myip    : 127.0.0.1
	results : {@{@category=geoloc; @timestamp=2017-12-16T12:12:00.000Z; @type=ip; asn=AS15169; city=; country=US;
			  country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
			  longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}, @{@category=inetnum;
			  @timestamp=1970-01-01T00:00:00.000Z; @type=ip; country=US; information=System.Object[]; netname=Undisclosed;
			  seen_date=1970-01-01; source=Undisclosed; subnet=Undisclosed}, @{@category=pastries;
			  @timestamp=2017-12-16T11:29:53.000Z; @type=pastebin; domain=System.Object[]; hostname=System.Object[];
			  ip=System.Object[]; key=fuMJJB9i; seen_date=2017-12-16}, @{@category=pastries;
			  @timestamp=2017-12-16T08:37:28.000Z; @type=pastebin; domain=System.Object[]; hostname=System.Object[];
			  ip=System.Object[]; key=UMbLWStd; seen_date=2017-12-16}...}
	status  : ok
	took    : 0.106
	total   : 3607

	count   : 1
	error   : 0
	myip    : 127.0.0.1
	results : {@{@category=geoloc; @timestamp=2017-12-16T12:12:00.000Z; @type=ip; asn=; city=; country=US;
			  country_name=United States; geolocation=37.7510,-97.8220; ip=7.7.7.7; ipv6=false; latitude=37.7510;
			  longitude=-97.8220; organization=; subnet=7.0.0.0/11}}
	status  : ok
	took    : 0.001661
	total   : 1

	.EXAMPLE
	C:\PS> Get-onypheinfo -fromcsv .\input.csv -multithreading
	C:\PS> Get-onypheinfo -fromcsv .\input.csv
	C:\PS> Get-onypheinfo -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#>

 <#
	.SYNOPSIS 
	Get IP information from onyphe.io web service

	.DESCRIPTION
	send HTTP request to onyphe.io web service and convert back JSON information to an hashtable

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
	
	.PARAMETER Datascan
	-IP string{IP} -Datascan string -APIKey string{APIKEY}
	look for an tcp service info for a specific IP in onyphe database.

	.PARAMETER IP
	-IP string{IP} -APIKey string{APIKEY}
	get all information available for a specific IP in onyphe database.
	
	.PARAMETER APIKey
	-APIKey string{APIKEY}
	set your APIKEY to be able to use Onyphe API.
	
	.OUTPUTS
	TypeName: System.Management.Automation.PSCustomObject
	
	count   : 32
	error   : 0
	myip    : 1.1.1.1
	results : {@{@category=geoloc; @timestamp=2017-12-14T07:10:53.000Z; @type=ip; asn=AS15169; city=; country=US;
			  country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
			  longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}, @{@category=inetnum;
			  @timestamp=1970-01-01T00:00:00.000Z; @type=ip; country=US; information=System.Object[]; netname=Undisclosed;
			  seen_date=1970-01-01; source=Undisclosed; subnet=Undisclosed}, @{@category=pastries;
			  @timestamp=2017-12-14T04:13:51.000Z; @type=pastebin; domain=System.Object[]; hostname=System.Object[];
			  ip=System.Object[]; key=pNhLGvpT; seen_date=2017-12-14}, @{@category=pastries;
			  @timestamp=2017-12-13T22:35:02.000Z; @type=pastebin; domain=System.Object[]; hostname=System.Object[];
			  ip=System.Object[]; key=ViArHJ18; seen_date=2017-12-13}...}
	status  : ok
	took    : 0.154
	total   : 3646

	.EXAMPLE
	C:\PS> Invoke-WebOnypheRequest -ip "192.168.1.5" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	C:\PS> Invoke-WebOnypheRequest -myip
	C:\PS> Invoke-WebOnypheRequest -ip "8.8.8.8" -searchtype Geoloc
	C:\PS> Invoke-WebOnypheRequest -ip "8.8.8.8" -searchtype Reverse -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	C:\PS> Invoke-WebOnypheRequest -ip "8.8.8.8" -searchtype DataScan -datascanstring "IIS" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#>

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
	none - write-host given apikey
	
	.EXAMPLE
	C:\PS> Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	C:\PS> Set-OnypheAPIKey -remove

 #>
  
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
	-inputobject $obj{output of Invoke-WebOnypheRequest or Get-OnypheInfoFromCSV functions}
	look for information about my public IP
		
	.OUTPUTS
	none
	
	.EXAMPLE
	C:\PS> Export-OnypheInfoToFile -tofolder C:\temp -inputobject $onypheresult
#>
