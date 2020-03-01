![image](https://www.onyphe.io/img/logo-solo.png)

# Use-Onyphe - How-To

## ChangeLog
This documentation has been updated to take into account **new features available with v0.99 including new Alerting APIs**. Enjoy your Onyphe stuff with Power[Shell](Of Love)

## Intro Onyphe
Onyphe.io provides data about IP address space and publicly available information in just one place.

Some of the APIs required an API key. 
To request it : https://www.onyphe.io/login

More info about available APIs :
https://www.onyphe.io/documentation/api

(c) 2018-2020 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).

## APIs v1 and v2
Since a few weeks now, new APIs are available in "v2". Main differences between v1 and v2 APIs are :
- V1 : accept only GET requests, all inputs must be managed as dedicated parameters (including API Key)
- V2 : accept GET and POST requests (using JSON formatted body for POST), API key must be provided as a HTTP Header. No paging for now.
To manage separated evolutions of V1 and V2 APIs, I am using also 2 different functions (Invoke-OnypheAPIV1, Invoke-OnypheAPIV2)

## Intro Use-Onyphe
Use-Onyphe is a free PowerShell module that you can use to simply request Onyphe APIs from a Powershell prompt or script (including PowerShell Core)
The module is available from :
 - Powershell Gallery (using install-module / update-module from PowerShell command line on recent PS version) https://www.powershellgallery.com/packages/Use-Onyphe/
 - Github https://github.com/MS-LUF/Use-Onyphe

After the installation and load of the module (using import-module), you will have to manage your context before starting to use it :-)
This module can both work on PowerShell and PowerShell Core. It means you can use it on every platform supported by PowerShell Core, including Windows, Linux and MacOS.
```
C:\PS> import-module "C:\My Modules\Use-Onyphe.psd1" -DisableNameChecking
```
```
PS /home/yours> import-module "/home/yours/My Modules/Use-Onyphe.psd1" -DisableNameChecking
```
## Prerequisites
### Prerequisite 1 : Managing your API Key
First thing to do is your API Key. You can directly load it in a global variable through Set-OnypheAPIKey :
```
    C:\PS>Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```
Or, you can save it encrypted in a local file (%home%\Use-Onyphe\Use-Onyphe-Config.xml) and load it at each start of Powershell using your Profile Script
**Note : previously it was stored under %appdata% but since v0.99 it is now stored under %home% for linux and Powershell Core compatibility**
```
    Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -MasterPassword (ConvertTo-SecureString -String "YourP@ssw0rd" -AsPlainText -Force) -EncryptKeyInLocalFile
```
Then edit your Microsoft.Powershell_profile.ps1 and set the load of the key (you will be prompted to enter the password automatically when powershell.exe will load your Microsoft.Powershell_profile.ps1) :
```
    import-module "C:\My Modules\Use-Onyphe.psd1" -DisableNameChecking
    Import-OnypheEncryptedIKey
```
### Prerequisite 2 : Managing your internet access
Second stuff to do is to manage your internet access, you can set it (proxy with authentication or not, direct connection...). For instance, to set a proxy with a SSO with current security context :
```
    C:\PS>Set-OnypheProxy -proxy "http://myproxy:3128" -ProxyUseDefaultCredentials
```
You can also add it in your Microsoft.PowerShell_profile.ps1 to set your environment automatically (%PROFILE% variable in your PowerShell user context)

## Output of Use-Onyphe functions / cmdlets
all output are managed through Powershell Objects (TypeName: System.Management.Automation.PSCustomObject)
It means you can do pretty everything with the output using native powershell features.

cli-* properties of the objects are properties added by the cmdlets (not directly managed by onyphe API). In those properties, you can find :
 - a date time object of the request
 - the API called
 - the API input
 - the API version used
 - if the API required an API Key

sample output :
```
    cli-API_info     : {ip}
    cli-API_input    : {9.9.9.9}
    cli-API_version  : 1
    cli-key_required : {True}
    cli-Request_Date : 22/08/2018 16:50:44
```
For the rest, each key of the json output is converted into a powershell object property. the type of the property could be a string,integer,array,hash table

object example for request Get-OnypheInfo -searchvalue 9.9.9.9 (all info available for IP 9.9.9.9) :
```
    C:\PS>Get-OnypheInfo -searchvalue 9.9.9.9 -searchtype ip

    count            : 41
    error            : 0
    myip             : a.b.c.d
    results          : {@{@category=geoloc; @timestamp=2018-08-22T21:49:57.000Z; @type=ip; asn=AS19281; city=; country=FR;
                    country_name=France; ip=9.9.9.9; ipv6=false; latitude=48.8582; location=48.8582,2.3387;
                    longitude=2.3387; organization=Quad9; subnet=9.9.9.0/24}, @{@category=pastries;
                    @timestamp=2018-08-19T07:10:49.000Z; @type=pastebin; key=s9DELJDH; seen_date=2018-08-19},
                    @{@category=pastries; @timestamp=2018-08-16T16:58:04.000Z; @type=pastebin; key=nFNZhGCq;
                    seen_date=2018-08-16}, @{@category=pastries; @timestamp=2018-08-15T00:49:36.000Z; @type=pastebin;
                    key=SN1WQheL; seen_date=2018-08-15}...}
    status           : ok
    took             : 0.096
    total            : 263
    cli-API_info     : {ip}
    cli-API_input    : {9.9.9.9}
    cli-API_version  : 1
    cli-key_required : {True}
    cli-Request_Date : 22/08/2018 23:50:01
```
all the results are hosted in the property "results", to open it directly :
```
    C:\PS>(Get-OnypheInfo -searchvalue 9.9.9.9 -searchtype ip).results

    ...(last 3 entries)
    @category    : datascan
    @timestamp   : 2018-08-08T09:09:23.000Z
    @type        : dns
    asn          : AS19281
    country      : FR
    data         : \x003\xfc-\x80\x80\x00\x01\x00\x01\x00\x00\x00\x00\x07version\x04bind\x00\x00\x10\x00\x03\xc0\x0c\x00\x1
                0\x00\x03\x00\x00\x00\x00\x00    \x08Q9-U-5.1
    organization : Quad9
    port         : 53
    protocol     : dns
    seen_date    : 2018-08-08
    subnet       : 9.9.9.0/24

    @category    : datascan
    @timestamp   : 2018-08-07T06:42:50.000Z
    @type        : dns
    asn          : AS19281
    country      : FR
    data         : \x003\xfc-\x80\x80\x00\x01\x00\x01\x00\x00\x00\x00\x07version\x04bind\x00\x00\x10\x00\x03\xc0\x0c\x00\x1
                0\x00\x03\x00\x01Q\x80\x00       \x08Q9-P-5.1
    organization : Quad9
    port         : 53
    protocol     : dns
    seen_date    : 2018-08-07
    subnet       : 9.9.9.0/24

    @category    : datascan
    @timestamp   : 2018-08-06T07:43:41.000Z
    @type        : dns
    asn          : AS19281
    country      : FR
    data         : \x003\xfc-\x80\x80\x00\x01\x00\x01\x00\x00\x00\x00\x07version\x04bind\x00\x00\x10\x00\x03\xc0\x0c\x00\x1
                0\x00\x03\x00\x01Q\x80\x00       \x08Q9-P-5.1
    organization : Quad9
    port         : 53
    protocol     : dns
    seen_date    : 2018-08-06
    subnet       : 9.9.9.0/24
```
If you look at the type of "results" property you will see it's basically an array of other powershell objects
```
    C:\PS>(Get-OnypheInfo -searchvalue 9.9.9.9 -searchtype ip).results | get-member

    TypeName : System.Management.Automation.PSCustomObject

    Name         MemberType   Definition
    ----         ----------   ----------
    Equals       Method       bool Equals(System.Object obj)
    GetHashCode  Method       int GetHashCode()
    GetType      Method       type GetType()
    ToString     Method       string ToString()
    @category    NoteProperty string @category=geoloc
    @timestamp   NoteProperty string @timestamp=2018-08-22T21:56:19.000Z
    @type        NoteProperty string @type=ip
    asn          NoteProperty string asn=AS19281
    city         NoteProperty string city=
    country      NoteProperty string country=FR
    country_name NoteProperty string country_name=France
    ip           NoteProperty string ip=9.9.9.9
    ipv6         NoteProperty string ipv6=false
    latitude     NoteProperty string latitude=48.8582
    location     NoteProperty string location=48.8582,2.3387
    longitude    NoteProperty string longitude=2.3387
    organization NoteProperty string organization=Quad9
    subnet       NoteProperty string subnet=9.9.9.0/24
```

## Input of Use-Onyphe functions / cmdlets
you can pipe data to functions :-)
for instance Get-OnypheInfo function will accept string as input for IP parameter
```
    C:\PS>"9.9.9.9" | Get-OnypheInfo -searchtype ip
```
Search-OnypheInfo function will accept string as input for SearchValue parameter
```
    C:\PS>"OVH SAS" | Search-OnypheInfo -SearchFilter organization -SearchType inetnum
```
you can use the "verbose" parameter to show several useful information (like full url requested etc...)
```
    C:\PS>"9.9.9.9" | -searchtype ip -verbose
```
sample command line output :
```
    URL Info : ip/9.9.9.9
    GET https://www.onyphe.io/api/ip/9.9.9.9?apikey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx with 0-byte payload
    received 9073-byte response of content type application/json;charset=UTF-8
```
if you don't want to store your API key and don't set it as global variable, you can use the parameter "APIKey" followed by your APIkey protected with double quotes on the main functions :
```
    C:\PS>Get-OnypheInfo -searchtype ip -searchvalue "9.9.9.9" -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## Help on cmdlets / functions
Get-help is available on all functions, for instance, if you want to consult the help section of Get-OnypheInfo (input, output, description and examples are available)
```
    C:\PS>Get-Help Get-OnypheInfo -full
```

## Using Use-Onyphe to use onyphe.io APIs
5 main functions / cmdlets will be used : 
 - Get-OnypheInfo (or Get-Onyphe) to use Myip,geoloc,ip,inetnum,threatlist,pastries,synscan,datascan,reverse,forward APIs
 - Search-OnypheInfo (or Search-Onyphe) to use all search APIs. Last but not least
 - Get-OnypheUserInfo will be used to follow your API key / user account (user API)
 - Get-OnypheAlertInfo (or Get-OnpyheAlert) to list your alerts using v2/alert/list API
 - Set-OnypheAlertInfo (or Set-OnypheAlert) to create and delete alerts using v2/alert/add or v2/alert/del APIs
 
Find hereunder several use cases for all API examples documented on https://www.onyphe.io/documentation/api

API MyIP : return your client public IP address
```
    C:\PS>Get-OnypheInfo -MyIP
```
API Geoloc : Return geolocation * information for the given IPv{4,6} address
```
    C:\PS>Get-OnypheInfo -Searchvalue 9.9.9.9 -searchtype Geoloc
```
API User : Return information about your user account
```
    C:\PS>Get-OnypheUserInfo
```
API IP : Return a summary of all information
```
    C:\PS>Get-OnypheInfo -searchtype ip -searchvalue 93.184.216.34
```
API Inetnum : Return inetnum information
```
    C:\PS>Get-OnypheInfo -searchvalue 93.184.208.1 -searchtype Inetnum
```
API Threatlist : Return threatlist information
```
    C:\PS>Get-OnypheInfo -searchvalue 206.81.18.195 -searchtype threatlist
```
API Pastries : Return pastries information
```
    C:\PS>Get-OnypheInfo -searchvalue 93.184.216.34 -searchtype pastries
```
API Synscan : Return synscan information
```
    C:\PS>Get-OnypheInfo -searchvalue 107.164.81.7 -searchtype SynScan
```
API Datascan : Return datascan information
```
    C:\PS>Get-OnypheInfo -searchvalue 107.164.81.7 -searchtype DataScan
```
```
    C:\PS>Get-OnypheInfo -searchvalue IIS -searchtype DataScan
```
API Reverse : Return reverse information
```
    C:\PS>Get-OnypheInfo -searchvalue 182.59.164.193 -searchtype Reverse
```
API Forward : Return forward information
```
    C:\PS>Get-OnypheInfo -searchvalue 2.22.52.73 -searchtype Reverse
```
API sniffer : Return ip history information
```
    C:\PS>Get-OnypheInfo -searchvalue 8.8.8.8 -searchtype sniffer
```
API onionscan : Return information about an onion url
```
    C:\PS>Get-OnypheInfo -searchvalue mh7mkfvezts5j6yu.onion -searchtype onionscan
```
API ctl : return information about SSL/TLS certificates related to a domain or fqn
```
    C:\PS>Get-OnypheInfo -searchvalue fnac.com -searchtype ctl
```
API md5 : return information on a onyphe md5 pattern / signature (SSH version...)
```
    C:\PS>Get-OnypheInfo -searchvalue 7a1f20cae067b75a52bc024b83ee4667 -searchtype md5
```
API Search/DataScan : Return datascan information
```
    C:\PS>Search-OnypheInfo -AdvancedSearch @('product:Apache','port:443','os:Windows') -SearchType datascan
```
```
    C:\PS>Search-OnypheInfo -SearchValue Windows -SearchFilter os -SearchType datascan
```
API Search/Synscan : Return synscan information
```
    C:\PS>Search-OnypheInfo -AdvancedSearch @('country:FR','port:23','os:Linux') -SearchType synscan
```
```
    C:\PS>Search-OnypheInfo -SearchValue 23 -SearchFilter port -SearchType synscan
```
API Search/Inetnum : Return inetnum information
```
    C:\PS>Search-OnypheInfo -SearchValue "OVH SAS" -SearchFilter organization -SearchType inetnum
```
API Search/Threatlist : Return threatlist information
```
    C:\PS>Search-OnypheInfo -SearchValue RU -SearchFilter country -SearchType threatlist
```
API Search/pastries : Return pastries information
```
    C:\PS>Search-OnypheInfo -SearchValue "195.29.70.0/24" -SearchFilter ip -SearchType pastries
```
API Search/Resolver : Return resolver information
```
    C:\PS>Search-OnypheInfo -SearchValue "124.108.0.0/16" -SearchFilter ip -SearchType resolver
```
API Search/sniffer : Return sniffer information
```
    C:\PS>Search-OnypheInfo -SearchValue "14.164.0.0/14" -SearchFilter ip -SearchType sniffer
```
API Search/onionscan : Return onionscan information
```
    C:\PS>Search-OnypheInfo -SearchValue market -SearchFilter data -SearchType onionscan
```
API Search/ctl : Return ctl information
```
    C:\PS>Search-OnypheInfo -SearchValue vpn -SearchFilter host -SearchType ctl
```
API Search/datashot : Return datashot information
```
    C:\PS>Search-OnypheInfo -SearchValue rdp -SearchFilter protocol -SearchType datashot
```
API Search/vulnscan : Return vulnerability found on internet asset
```
    C:\PS>Search-OnypheInfo -SearchValue CVE-2019-19781 -SearchFilter cve -SearchType vulnscan
```
API Search/topsite : Return information about a toplist like Alexa (https://www.alexa.com/topsites)
```
    C:\PS>Search-OnypheInfo -SearchValue fr -SearchFilter country -SearchType topsite
```
API V2/Alert/List : List your account alerts already set
```
    C:\PS>Get-OnypheAlert
```
```
    C:\PS>Get-OnypheAlert -SearchValue "jeanclaude.dusse@lesbronzesfontdusk.io" -SearchOperator eq -SearchFilter email
```
API V2/Alert/Add : Define a new alert for your account
```
    C:\PS>Set-OnypheAlert -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan -AlertAction new -AlertName "windows apache" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"
```
```
    C:\PS>Set-OnypheAlert -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
```
API V2/Alert/Del : Remove an existing alert from your account
```
    C:\PS>Set-OnypheAlert -AlertAction delete -AlertName "windows apache"
```

## E-mail alerting system
Since a few weeks now, 3 new APIs (V2) are available to manage automatic e-mail alerts for your Onyphe account. It means you can automate search request at Onyphe server side and received an e-mail alerts when new events are available (especially when using timeline filter functions in your request).
Of course this new feature requires an API Key (non free).
**You can create 100 alerts maximum by account.**
Of course, this PowerShell module has been updated to manage this new important features :) You can now create / delete / modify your alerts using Use-Onyphe module.
The parameters are quite the same compared to the Search-Onyphe function. It means, you are free to create simple search request or advanced search / filters requests for an alert.
**The alerts are sent from noreply@onyphe.fr with the following object [ONYPHE][ALERT]**

Here are several samples to help you understand how it works ;-)
Create a "simple" alert named "from Paris with love" when a new french IP has been added to Onyphe threatlist (new daily info) and sent back the alert to "jeanclaude.dusse@lesbronzesfontdusk.io"
```
    C:\PS>Set-OnypheAlert -SearchValue FR -SearchType threatlist -SearchFilter country -FilterFunction dayago -FilterValue 0 -AlertAction new -AlertName "from Paris with love" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"
```
Create an advanced alert named "FR RDP" when a new IP has been tagged for an open MS-RDP port, in France, from an organization named like *company*, with an available OS property (since the last 2 month) and sent back the alert to "robert.lespinasse@lesbronzesfontdusk.io"
```
    C:\PS> Set-OnypheAlert -AdvancedFilter @("wildcard:organization,*company*","exists:os","monthago:2") -AdvancedSearch @("country:FR","port:3389") -SearchType datascan -AlertAction new -AlertName "FR RDP" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
```
Delete an existing alert named "FR RDP"
```
    C:\PS> Set-OnypheAlert -AlertAction delete -AlertName "FR RDP"
```
List all existing alert
```
    C:\PS> Get-OnypheAlert
```
Get alert based on mail,name or query criteria. Here with mail criteria, retrieve all alert defined to "jeanclaude.dusse@lesbronzesfontdusk.io"
Note : search operators available are the classic PowerShell ones : eq, ne, like, notlike, match, notmatch
Note : default value for SearchOperator parameter is "eq"
Note : default value for SearchFilter parameter is "name"
```
    C:\PS> Get-OnypheAlert -SearchValue "jeanclaude.dusse@lesbronzesfontdusk.io" -SearchOperator eq -SearchFilter email
```
## Paging and Results
by default 10 results are available in on object. if you have more than 10 results available, you can consult them ten by ten using pages.
for instance the following request "Search-OnypheInfo -SearchValue "OVH SAS" -SearchFilter organization -SearchType inetnum" will send back a powershell object with the properties "max_page" to 1000.
by default, the object will embbed the first 10 results available on the first page. to consult the page 2 containing the next 10 results, you can use the property "page" :
```
    C:\PS>Search-OnypheInfo -SearchValue "OVH SAS" -SearchFilter organization -SearchType inetnum -page 2
```
You will see that the property "page" will switch to "2" and the "results" properties will be updated with the next 10 results.
if you want to retrieve all the pages, you can specify first and last page separated with - using page parameter :
```
    C:\PS>Search-OnypheInfo -SearchValue "OVH SAS" -SearchFilter organization -SearchType inetnum -page 1-1000
```
Note : parameter "-wait 3" will wait 3 seconds between each request to manage rate limiting.

## Filter functions available on servers
you can use some server filter functions to optimize your search (feature only available for search APIs not basic APIs). Currently, you can mainly use some timing function to filter results based on object creation date.
you can use dayago, weekago, monthago functions to filter the results directly on the server side.
you can use the filter functions on search request but also on alert creation (because an alert is no more a linked between a automate search request and an e-mail address).
For instance, hereunder we request all objects created since the last 2 months
```
    C:\PS> Search-OnypheInfo -SearchValue RU -SearchType threatlist -SearchFilter country -FilterFunction monthago -FilterValue 2
```
Here are also the filters available currently : dayago, weekago, monthago, exists, wildcard, fields
exists can be used to send back only result with a property containing a non null value. For instance, I can retrieve only the result containing a property OS set :
```
    C:\PS> Search-OnypheInfo -SearchValue RU -SearchType threatlist -SearchFilter country -FilterFunction exist -FilterValue os
```
wildcard can be used to search deeply a property, but this is limited to 24 hours period of time to be sure the server won't crash. For instance, to look for all organization starting with company :
```
    C:\PS> Search-OnypheInfo -SearchValue RU -SearchType threatlist -SearchFilter country -FilterFunction wildcard -FilterValue "organization,company*"
```
you can use multiple filter functions at a time using advancedfilter property :
```
    C:\PS> search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan
```
a last sample using the previous request but declared as an alert named "RandR" for robert.lespinasse@lesbronzesfontdusk.io
```
    C:\PS>Set-OnypheAlert -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
```
## Managing rate limiting
you can add the parameter "wait" followed by a digit to request to wait x seconds between each request to manage rate limiting feature.
It's usefull in case of a loop or in batch mode usage.
Note : in batch usage (see next chapter) the wait parameter is set automatically to 3

## Batch mode usage
a cmdlet / function is available to automate request based on a csv.
the output is an array containing all results.
to do so use the function "Get-OnypheInfoFromCSV"
```
    C:\PS> Get-OnypheInfoFromCSV -fromcsv .\input.csv
```
by default the CSV delimieter is ; (made in France ;-) ) to change it, use the parameter -csvde followed by the separator protected by double quotes.
you can find a csv template on my github here : https://raw.githubusercontent.com/MS-LUF/Use-Onyphe/master/sample_testonyphe.csv
all apis can be used. currently the pages are not managed, it should be done in the next version of the module (it means only the first 10 results are managed by default).

## Export results to file (CSV)
a cmdlet / function is available to export a onyphe powershell object to an external CSV.
Note : the data or content properties of pastries,datascan ... are exported in dedicated text file to be more readable.
Just specify the target folder and several subfolders (on per request) containing csv and txt files will be created.
to do so use the function Export-OnypheInfoToFile :
```
    C:\PS> $AllResults = Search-OnypheInfo -SearchValue "OVH SAS" -SearchFilter organization -SearchType inetnum -page 1-1000
    C:\PS> Export-OnypheInfoToFile -tofolder C:\temp -inputobject $AllResults
```

## Playing with Onyphe and PowerShell objects
### Example 1
Please onyphe, tell me what are the current IP addresses tagged with mirai botnet ?
Well, we will do the stats for the first 100 pages of results for the demo :)

First, retrieve the results (all threatlist objects tagged with mirai) :
```
    C:\PS> Search-OnypheInfo -SearchValue mirai -SearchType threatlist -SearchFilter tag
    C:\PS> Search-OnypheInfo -SearchValue mirai -SearchType threatlist -SearchFilter tag -Page 1-594
```
Then, play with the objects :-)
how many unique ip ?
```
    C:\PS> ($AllResults.results.subnet | sort-object -Unique).count
    978
```

The ip list itself ?
```
    C:\PS> $AllResults.results.subnet | sort-object -Unique
    ...
    95.5.2.125/32
    95.9.177.76/32
    96.78.106.179/32
    96.84.126.5/32
```
Well, not so hard, isn't it ;-)

### Example 2
Please Onyphe, I am a security guy from Quad9 and I want to have an overview of all my opened ports on internet.
Well, quite simple :)

First, retrieve all the results avaialable (all synscan objects linked to Quad9 organization) :
```
    C:\PS> $AllResults = Search-OnypheInfo -SearchValue Quad9 -SearchFilter organization -SearchType synscan -Page 1-2
```
Then, play with the objects :-)
What are the open ports ?
```
    C:\PS> $AllResults.results.port | sort-object -unique
    3389
    443
    53
```

wait... I can see 3389 in the list !
can you please tell me what is the ip related to this port ?

of course !
```
    C:\PS> ($AllResults.results | Where-Object {$_.port -eq 3389}).ip | sort-object -unique
    9.9.9.9
```

thank you, let me check... it seems the port is now closed... but need some investigation !

Still easy, isn't it ;-)

### Example 3
Well, thanks onyphe but I am not very confortable with PowerShell and I have quite simple needs. Indeed, I am not a technical guy more a funtionnal one and I would like to do some simple stats related to several search.
Starting v0.93 of Use-Onyphe module, a new function is now available "Get-OnypheStatsFromObject" that can do several simple stuff for you :-) you can do some basic stats (count, total, average, min, max) on all properties of Onyphe results based on Powershell Onyphe result object.

For instance, let's take a CSO from Citrix company, he wants to have, everyweek, a quick overview of all opened ports regarding his organzation to update his security dashboard.

First, retrieve all the results avaialable (all synscan objects linked to citrix organization) :
```
    C:\PS> Search-OnypheInfo -AdvancedSearch @('organization:Citrix') -SearchType synscan -Page 1-7
```
Then, do the stats 
```
    C:\PS> Get-OnypheStatsFromObject -Facets port -inputobject $AllResults

    Sum     : 420
    Count   : 5
    Average : 84
    Min     : 2
    Max     : 269
    Stats   : {@{Onyphe-Facet=port; Onyphe-Property-value=25; Onyphe-Property-Count=20}, @{Onyphe-Facet=port;
            Onyphe-Property-value=443; Onyphe-Property-Count=269}, @{Onyphe-Facet=port; Onyphe-Property-value=53;
            Onyphe-Property-Count=7}, @{Onyphe-Facet=port; Onyphe-Property-value=80; Onyphe-Property-Count=122}...}
```
420 objets found, 5 differents port opened, one port is opened 2 times (min), one port is opened 269 times (max)

If you want to have the results by port, it's also simple, we just have to open property 'stats' of the object :
```
    C:\PS>(Get-OnypheStatsFromObject -Facets port -inputobject $AllResults).Stats

    Onyphe-Facet Onyphe-Property-value Onyphe-Property-Count
    ------------ --------------------- ---------------------
    port         25                                       20
    port         443                                     269
    port         53                                        7
    port         80                                      122
    port         8080                                      2
```

### Example 4
Please Onyphe, I am a in charge of following security KPIs and my boss wants to have an overview of external RDP server in front of internet.

First, retrieve all the results avaialable (all synscan objects linked to your organization, here for instance OVH SAS) :
```
    C:\PS> $allresults = Search-OnypheInfo -AdvancedSearch @('organization:OVH SAS','port:3389') -SearchType datashot -Page 1-1000
```
Then, export the screenshot of the home RDP login page for more information :)
```
    C:\PS> $allresults | Export-OnypheDataShot -tofolder .\temp\
```

### Example 5
Please Onyphe, filter the result and show me only the answer with os property not null for threatlist category for all Russia
```
    C:\PS> Search-OnypheInfo -SearchValue RU -SearchType threatlist -SearchFilter country -FilterFunction exist -FilterValue os
```

### Example 6
Please Onyphe, filter the results using multiple filters (only os property known and from all organization like *company*) for tcp port 3389 opened in russia
```
    C:\PS> search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan
```

### Example 7
Please Onyphe, I have found a very useful search request and I want to create an alert for it

Well, we can manage it in different ways, first create the alert 'manually'
```
    C:\PS> set-onyphealert -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
```
Or you can pipe a search object to the set-onyphealert function
```
    C:\PS> search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan | set-onyphealert -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
```
Or you can import an existing search object result in set-onyphealert function
```
    C:\PS> $test = search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan
    C:\PS> set-onyphealert -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io" -InputOnypheObject $test
```