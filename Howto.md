<img src="https://www.onyphe.com/assets/img/logo/Onyphe-Logo-Official-Light-Theme.svg" alt="Onyphe" style="width:40%;">

# Use-Onyphe - How-To

## ChangeLog
This documentation has been updated to take into account **new features available up to v2.2.0**: the Discovery API and new search-result-shaping parameters (`-Size`, `-TrackQuery`, `-Calculated`) from v2.1.0, the Discovery API's full 20-category coverage from v2.1.2, OQLv2 condition-group syntax from v2.1.3, and the ASD (Attack Surface Discovery) APIv1 integration from v2.2.0. Enjoy your Onyphe stuff with Power[Shell](Of Love)

## Intro Onyphe
Onyphe.io provides data about IP address space and publicly available information in just one place.

Some of the APIs required an API key. 
To request it : https://www.onyphe.io/login

More info about available APIs :
https://www.onyphe.io/documentation/api

(c) 2018-2021 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).

## APIs v1 and v2
Since a few weeks now, new APIs are available in "v2". Main differences between v1 and v2 APIs are :
- V1 : accept only GET requests, all inputs must be managed as dedicated parameters (including API Key)
  - Notes : APIv1 are now deprecated and have been removed from Onyphe. APIv1 are also removed from the PowerShell Module provided.
- V2 : accept GET and POST requests (using JSON formatted body for POST), API key must be provided as a HTTP Header. No paging for now.

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
Or, you can save it encrypted in a local file (%home%\Use-Onyphe\Use-Onyphe-Config.json) and load it at each start of Powershell using your Profile Script
**Note : previously it was stored under %appdata% but since v0.99 it is now stored under %home% for linux and Powershell Core compatibility. The config file itself was later migrated from Clixml (Use-Onyphe-Config.xml) to JSON (Use-Onyphe-Config.json); an existing .xml file is auto-migrated to .json the first time the module runs.**
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

object example for request Get-OnypheSummary -SummaryAPIType ip -searchvalue 9.9.9.9 (all info available for IP 9.9.9.9) :
```
    C:\PS> Get-OnypheSummary -SummaryAPIType ip -searchvalue 9.9.9.9

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
    C:\PS>(Get-OnypheSummary -SummaryAPIType ip -searchvalue 9.9.9.9).results

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
    C:\PS>(Get-OnypheSummary -SummaryAPIType ip -searchvalue 9.9.9.9).results | get-member

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
    C:\PS> "9.9.9.9" | Get-OnypheSummary -SummaryAPIType ip
```
Search-OnypheInfo function will accept string as input for SearchValue parameter
```
    C:\PS> "OVH SAS" | Search-OnypheInfo -SearchFilter organization -Category inetnum
```
you can use the "verbose" parameter to show several useful information (like full url requested etc...)
```
    C:\PS> "9.9.9.9" | Get-OnypheSummary -SummaryAPIType ip -verbose
```
sample command line output :
```
    VERBOSE: URL Info : v2/summary/ip/9.9.9.9
    VERBOSE: using production Onyphe service - https://www.onyphe.io
    VERBOSE: Request Headers :
    Name                           Value
    ----                           -----
    Authorization                  apikey xxxxxxxxxxxxxxxxxxxxxxxxxxxxx


    VERBOSE: GET https://www.onyphe.io/api/v2/summary/ip/9.9.9.9 with 0-byte payload
    VERBOSE: received 14999-byte response of content type application/json
    VERBOSE: Response Headers :
    Key            Value
    ---            -----
    Server         {nginx}
    Date           {Wed, 03 Jun 2020 21:06:56 GMT}
    Connection     {keep-alive}
    Content-Type   {application/json; charset=UTF-8}
    Content-Length {14999}
```
if you don't want to store your API key and don't set it as global variable, you can use the parameter "APIKey" followed by your APIkey protected with double quotes on the main functions :
```
    C:\PS> Get-OnypheSummary -SummaryAPIType ip -searchvalue 9.9.9.9 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```
the function Search-OnypheInfo can be used as an input for Export-OnypheInfo and Set-OnypheAlertInfo
```
    C:\PS> Search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan | Export-onyphe -SaveInfoAsFile .\myexport.json
```
```
    C:\PS> Search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan | set-onyphealert -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
```
## Help on cmdlets / functions
Get-help is available on all functions, for instance, if you want to consult the help section of Get-OnypheInfo (input, output, description and examples are available)
```
    C:\PS> Get-Help Get-OnypheInfo -full
```

## Using Use-Onyphe to use onyphe.io APIs
6 main functions / cmdlets will be used :
 - Get-OnypheSummary to use all v2/summary APIs ip,domain,hostname
   - These APIs can be used to retrieve all objects linked to an IP, a domain or an hostame (all categories are sent back from summary API) 
 - Get-OnypheInfo (or Get-Onyphe) to use all v2/simple APIs ctl,datascan,geoloc,inetnum,pastries,resolver,sniffer,synscan,threatlist,datashot,onionscan,onionshot,topsite,vulnscan,resolver/reverse,resolver/forward,datascan/datamd5,whois
   - These APIs are the 'standard' APIs and object category sent back are limited to API type in use (ctl category object for ctl API etc...)
   - you can use the `Best` option to use the Best mode of simple API (currently compliant with Best answer mode : geoloc,inetnum,threatlist,whois)
 - Search-OnypheInfo (or Search-Onyphe) to make some complex and powerfull request in all Onyphe database
   - all category types can be retrieved depending on the query used for the search request
 - Get-OnypheUserInfo will be used to follow your API key / user account (user API)
 - Get-OnypheAlertInfo (or Get-OnpyheAlert) to list your alerts using v2/alert/list API
 - Set-OnypheAlertInfo (or Set-OnypheAlert) to create and delete alerts using v2/alert/add or v2/alert/del APIs
 - Export-OnypheInfo (or Export-Onyphe) to download json file from Onyphe database for a search request
 - Export-OnypheBulkSummaryInfo to download json file fron onyphe database for a summary request including multiple entries (through a txt file provided, on entry per line)
 - Export-OnypheBulkInfo to download json file fron onyphe database for a simple request including multiple entries (through a txt file provided, on entry per line)
    - All simple APIs are also available through a bulk mode using this cmdlet
 - Export-OnypheDiscoveryInfo (or Export-OnypheBulkDiscovery) to run a file of OQL queries (one per line) in bulk against the Discovery API and download the JSON results
    - **requires a Griffin View subscription on Onyphe** - without one, no Discovery category will be available to you
 - Get-OnypheASDInfo to use the ASD (Attack Surface Discovery) APIv1 - domain/certificate/DNS enumeration endpoints
    - **requires a Griffin View or Griffin View ASM Edition subscription with a non-commercial use licence** - see Get-OnypheUserInfo's `asd.stdapis` property
 
Find hereunder several use cases for all API examples documented on https://www.onyphe.io/documentation/api

API V2/simple/geoloc : Return geolocation * information for the given IPv{4,6} address
```
    C:\PS> Get-OnypheInfo -Searchvalue 9.9.9.9 -Category Geoloc
```
API V2/simple/geoloc/best : Return best geolocation answer * information for the given IPv{4,6} address
```
    C:\PS> Get-OnypheInfo -Searchvalue 9.9.9.9 -Category Geoloc -Best
```
API V2/user : Return information about your user account
```
    C:\PS> Get-OnypheUserInfo
```
API V2/summary/ip : Return a summary of all information (all category) available for an IP
```
    C:\PS> Get-OnypheSummary -SummaryAPIType ip -searchvalue 9.9.9.9
```
API V2/summary/domain : Return a summary of all information (all category) available for an internet domain
```
    C:\PS> Get-OnypheSummary -SummaryAPIType domain -searchvalue perdu.com
```
API V2/summary/hostname : Return a summary of all information (all category) available for an internet hostname
```
    C:\PS> Get-OnypheSummary -SummaryAPIType hostname -searchvalue www.perdu.com
```
API V2/simple/inetnum : Return inetnum information
```
    C:\PS> Get-OnypheInfo -searchvalue 93.184.208.1 -Category Inetnum
```
API V2/simple/inetnum/best : Return inetnum best answer information
```
    C:\PS> Get-OnypheInfo -searchvalue 93.184.208.1 -Category Inetnum -best
```
API V2/simple/topsite : Return topsite information
```
    C:\PS> Get-OnypheInfo -searchvalue 9.9.9.9 -Category topsite
```
API V2/simple/vulnscan : Return vulnscan information (CVE detected / exploited on a host)
```
    C:\PS> Get-OnypheInfo -searchvalue 194.177.55.67 -Category vulnscan
```
API V2/simple/threatlist : Return threatlist information
```
    C:\PS> Get-OnypheInfo -searchvalue 206.81.18.195 -Category threatlist
```
API V2/simple/threatlist/best : Return threatlist best answer information
```
    C:\PS> Get-OnypheInfo -searchvalue 206.81.18.195 -Category threatlist -best
```
API V2/simple/pastries : Return pastries information
```
    C:\PS> Get-OnypheInfo -searchvalue 93.184.216.34 -Category pastries
```
API V2/simple/synscan : Return synscan information
```
    C:\PS> Get-OnypheInfo -searchvalue 107.164.81.7 -Category SynScan
```
API V2/simple/datascan : Return datascan information
```
    C:\PS> Get-OnypheInfo -searchvalue 107.164.81.7 -Category DataScan
```
```
    C:\PS> Get-OnypheInfo -searchvalue IIS -Category DataScan
```
API V2/simple/resolver/reverse : Return resolver/dns information
```
    C:\PS> Get-OnypheInfo -searchvalue 9.9.9.9 -Category resolver
```
API V2/simple/resolver/reverse : Return reverse information
```
    C:\PS> Get-OnypheInfo -searchvalue 182.59.164.193 -Category resolverreverse
```
API V2/simple/resolver/forward : Return forward information
```
    C:\PS> Get-OnypheInfo -searchvalue 2.22.52.73 -Category resolverforward
```
API V2/simple/sniffer : Return ip history information
```
    C:\PS> Get-OnypheInfo -searchvalue 8.8.8.8 -Category sniffer
```
API V2/simple/onionscan : Return information about an onion url
```
    C:\PS> Get-OnypheInfo -searchvalue mh7mkfvezts5j6yu.onion -Category onionscan
```
API V2/simple/ctl : return information about SSL/TLS certificates related to a domain or fqdn
```
    C:\PS> Get-OnypheInfo -searchvalue fnac.com -Category ctl
```
API V2/simple/datashot : return screenshot get from graphical protocol for an ip
```
    C:\PS> Get-OnypheInfo -searchvalue 80.11.245.174 -Category datashot
```
API V2/simple/datascan/datamd5 : return information on a onyphe md5 pattern / signature (SSH version...)
```
    C:\PS> Get-OnypheInfo -searchvalue 7a1f20cae067b75a52bc024b83ee4667 -Category datascandatamd5
```
API V2/simple/whois : return whois information
```
    C:\PS> Get-OnypheInfo -searchvalue 9.9.9.9 -Category whois
```
API V2/simple/whois/best : return whois best answer information
```
    C:\PS> Get-OnypheInfo -searchvalue 9.9.9.9 -Category whois -best
```
API V2/Search : Return datascan information
```
    C:\PS> Search-OnypheInfo -AdvancedSearch @('product:Apache','port:443','os:Windows') -Category datascan
```
```
    C:\PS> Search-OnypheInfo -SearchValue Windows -SearchFilter os -Category datascan
```
API V2/Search : Return synscan information
```
    C:\PS> Search-OnypheInfo -AdvancedSearch @('country:FR','port:23','os:Linux') -Category synscan
```
```
    C:\PS> Search-OnypheInfo -SearchValue 23 -SearchFilter port -Category synscan
```
API V2/Search : Return inetnum information
```
    C:\PS> Search-OnypheInfo -SearchValue "OVH SAS" -SearchFilter organization -Category inetnum
```
API V2/Search : Return threatlist information
```
    C:\PS> Search-OnypheInfo -SearchValue RU -SearchFilter country -Category threatlist
```
API V2/Search : Return pastries information
```
    C:\PS> Search-OnypheInfo -SearchValue "195.29.70.0/24" -SearchFilter ip -Category pastries
```
API V2/Search : Return resolver information
```
    C:\PS> Search-OnypheInfo -SearchValue "124.108.0.0/16" -SearchFilter ip -Category resolver
```
API V2/Search : Return sniffer information
```
    C:\PS> Search-OnypheInfo -SearchValue "14.164.0.0/14" -SearchFilter ip -Category sniffer
```
API V2/Search : Return onionscan information
```
    C:\PS> Search-OnypheInfo -SearchValue market -SearchFilter data -Category onionscan
```
API V2/Search : Return ctl information
```
    C:\PS> Search-OnypheInfo -SearchValue vpn -SearchFilter host -Category ctl
```
API V2/Search : Return datashot information
```
    C:\PS> Search-OnypheInfo -SearchValue rdp -SearchFilter protocol -Category datashot
```
API V2/Search : Return vulnerability found on internet asset
```
    C:\PS> Search-OnypheInfo -SearchValue CVE-2019-19781 -SearchFilter cve -Category vulnscan
```
API V2/Search : Return topsite information
```
    C:\PS> Search-OnypheInfo -SearchValue fr -SearchFilter country -Category topsite
```
API V2/Alert/List : List your account alerts already set
```
    C:\PS> Get-OnypheAlert
```
```
    C:\PS> Get-OnypheAlert -SearchValue "jeanclaude.dusse@lesbronzesfontdusk.io" -SearchOperator eq -SearchFilter email
```
API V2/Alert/Add : Define a new alert for your account
```
    C:\PS> Set-OnypheAlert -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan -AlertAction new -AlertName "windows apache" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"
```
```
    C:\PS> Set-OnypheAlert -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
```
API V2/Alert/Del : Remove an existing alert from your account
```
    C:\PS> Set-OnypheAlert -AlertAction delete -AlertName "windows apache"
```
API v2/export : Export search results to file
```
    C:\PS> Export-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan -SaveInfoAsFile .\myexport.json
```
```
    C:\PS> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan | Export-OnypheInfo -SaveInfoAsFile .\myexport.json
```
API v2/bulk/summary/ip : export summary for IPs infos in a JSON file or object based on a txt input file (bulk)
```
    C:\PS> Export-OnypheBulkSummaryInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType ip
    C:\PS> Export-OnypheBulkSummaryInfo -FilePath .\myfile.txt -SearchType ip
```
API v2/bulk/summary/hostname : export summary for hostnames infos in a JSON file or object based on a txt input file (bulk)
```
    C:\PS> Export-OnypheBulkSummaryInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType hostname
    C:\PS> Export-OnypheBulkSummaryInfo -FilePath .\myfile.txt -SearchType hostname
```
API v2/bulk/summary/domain : export summary for domains infos in a JSON file or object based on a txt input file (bulk)
```
    C:\PS> Export-OnypheBulkSummaryInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType domain
    C:\PS> Export-OnypheBulkSummaryInfo -FilePath .\myfile.txt -SearchType domain
```  
All Simple APIs are available though /v2/bulk/simple, to decrease the document size / length, here is a first sample for the whois category but all other categories remain available (including using best mode)  
API v2/bulk/simple/whois : exoprt whois infornation infos in a JSON file or object based on a txt input file (bulk)
```
    C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -category whois
    C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -category whois
    C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -category whois -best
```  
API v2/bulk/discovery/datascan : run a file of OQL queries (one per line) in bulk against the datascan category and get back a JSON file or object - **requires a Griffin View subscription**
```
    C:\PS> "protocol:rdp domain:google.com" | Set-Content .\myqueries.txt
    C:\PS> "protocol:ssh domain:google.com" | Add-Content .\myqueries.txt
    C:\PS> Export-OnypheDiscoveryInfo -FilePath .\myqueries.txt -SaveInfoAsFile .\results.json -Category datascan
    C:\PS> Export-OnypheDiscoveryInfo -FilePath .\myqueries.txt -Category datascan
```
as of v2.1.2, all 20 Discovery categories a Griffin View subscription can expose are available the same way, not just datascan: `ctiscan`, `ctiurl`, `ctl`, `datashot`, `domain`, `geoloc`, `hostname`, `inetnum`, `ip`, `onionscan`, `onionshot`, `pastries`, `resolver`, `riskscan`, `sniffer`, `threatlist`, `topsite`, `vulnscan`, `whois` (just swap `-Category datascan` for any of these); use `Get-OnypheDiscoveryCategories` to see which Discovery categories your account currently has access to.

## ASD (Attack Surface Discovery) APIs
Since v2.2.0, `Get-OnypheASDInfo` wraps 9 of Onyphe's BETA "standard" ASD APIv1 endpoints - domain/certificate/DNS enumeration helpers, distinct from the Search/Discovery categories above. **These require a Griffin View or Griffin View ASM Edition subscription with a non-commercial use licence** - check `(Get-OnypheUserInfo).results.asd.stdapis` before use; `Get-OnypheASDAPIName` lists the implemented type names (`domaintld`, `domainwildcard`, `domaincertso`, `certsodomain`, `certsowildcard`, `dnsdomainns`, `dnsdomainmx`, `dnsdomainsoa`, `dnsdomainexist`).

API v1/asd/domain/tld : discover related domains across different TLDs for a given domain
```
    C:\PS> Get-OnypheASDInfo -ASDAPIType domaintld -Value onyphe.io
```
API v1/asd/certso/domain : discover certificate subject.organization value(s) linked to a domain
```
    C:\PS> Get-OnypheASDInfo -ASDAPIType certsodomain -Value onyphe.io
```
API v1/asd/domain/certso : discover domain(s) linked to a certificate subject.organization value - note this is the one endpoint that takes an organization name rather than a domain in -Value
```
    C:\PS> Get-OnypheASDInfo -ASDAPIType domaincertso -Value "ONYPHE"
```
API v1/asd/dns/domain/exist : check whether one or more domains exist (passive DNS history / live brute-force)
```
    C:\PS> Get-OnypheASDInfo -ASDAPIType dnsdomainexist -Value @("onyphe.io","example.org")
```
API v1/asd/dns/domain/ns, /mx, /soa : live DNS lookups against a domain (same -Value shape, just swap -ASDAPIType)
```
    C:\PS> Get-OnypheASDInfo -ASDAPIType dnsdomainns -Value onyphe.io
```
you can narrow results and disable Onyphe's backend false-positive filtering with -IncludePattern/-ExcludePattern/-Untrusted (not supported by `dnsdomainexist`), and request one-JSON-object-per-line output with -AsLines :
```
    C:\PS> Get-OnypheASDInfo -ASDAPIType domaintld -Value onyphe.io -ExcludePattern "test" -Untrusted -AsLines
```
Note: the "advanced" Pivot Query ASD API (`asd.advapis`) is not implemented yet in this module, and the ASD APIs' `astask` background-task mode is not exposed - see README.md's v2.2.0 notes for why.

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
    C:\PS>Set-OnypheAlert -SearchValue FR -Category threatlist -SearchFilter country -FilterFunction dayago -FilterValue 0 -AlertAction new -AlertName "from Paris with love" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"
```
Create an advanced alert named "FR RDP" when a new IP has been tagged for an open MS-RDP port, in France, from an organization named like *company*, with an available OS property (since the last 2 month) and sent back the alert to "robert.lespinasse@lesbronzesfontdusk.io"
```
    C:\PS> Set-OnypheAlert -AdvancedFilter @("wildcard:organization,*company*","exists:os","monthago:2") -AdvancedSearch @("country:FR","port:3389") -Category datascan -AlertAction new -AlertName "FR RDP" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
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
for instance the following request "Search-OnypheInfo -SearchValue "OVH SAS" -SearchFilter organization -category inetnum" will send back a powershell object with the properties "max_page" to 1000.
by default, the object will embbed the first 10 results available on the first page. to consult the page 2 containing the next 10 results, you can use the property "page" :
```
    C:\PS> Search-OnypheInfo -SearchValue "OVH SAS" -SearchFilter organization -Category inetnum -page 2
```
You will see that the property "page" will switch to "2" and the "results" properties will be updated with the next 10 results.
if you want to retrieve all the pages, you can specify first and last page separated with - using page parameter :
```
    C:\PS> Search-OnypheInfo -SearchValue "OVH SAS" -SearchFilter organization -Category inetnum -page 1-1000
```
Note : parameter "-wait 3" will wait 3 seconds between each request to manage rate limiting.

## Filter functions available on servers
you can use some server filter functions to optimize your search (feature only available for search APIs not basic APIs). Currently, you can mainly use some timing function to filter results based on object creation date.
you can use dayago, weekago, monthago functions to filter the results directly on the server side.
you can use the filter functions on search request but also on alert creation (because an alert is no more a linked between a automate search request and an e-mail address).
For instance, hereunder we request all objects created since the last 2 months
```
    C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction monthago -FilterValue 2
```
Here are also the filters available currently : dayago, weekago, monthago, exists, wildcard, fields
exists can be used to send back only result with a property containing a non null value. For instance, I can retrieve only the result containing a property OS set :
```
    C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction exists -FilterValue os
```
wildcard can be used to search deeply a property, but this is limited to 24 hours period of time to be sure the server won't crash. For instance, to look for all organization starting with company :
```
    C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction wildcard -FilterValue "organization,company*"
```
you can use multiple filter functions at a time using advancedfilter property :
```
    C:\PS> search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan
```
a last sample using the previous request but declared as an alert named "RandR" for robert.lespinasse@lesbronzesfontdusk.io
```
    C:\PS> Set-OnypheAlert -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
```
## Excluding, OR-ing, and combining multiple wildcard/regexp conditions (OQL)
you can exclude a filter from the results by prefixing its name with "!" (OQL NOT), directly as plain text inside -AdvancedSearch, no dedicated parameter needed. For instance, all Russia-tagged threatlist entries except those on port 80 :
```
    C:\PS> Search-OnypheInfo -AdvancedSearch @("category:threatlist","country:RU","!port:80") -Category threatlist
```
you can OR two filters together by prefixing them with "?" (OQL OR). For instance, all threatlist entries from Russia or China :
```
    C:\PS> Search-OnypheInfo -AdvancedSearch @("?country:RU","?country:CN") -Category threatlist
```
to combine several wildcard or regexp conditions together (an OR between them), repeat the function once per condition inside -AdvancedFilter - Onyphe's OQL combines multiple wildcard/regexp conditions this way, not by packing several field/pattern pairs into a single function call :
```
    C:\PS> Search-OnypheInfo -AdvancedFilter @("orwildcard:domain,g?ogle.com","orwildcard:domain,googl?.com") -Category resolver
```
## OQLv2 condition groups
**Requires an ASM-level or Ctiscan licence** - check `(Get-OnypheUserInfo).results.oqlversion` (2 means it's available to you). You can group conditions in parentheses to AND two independent OR-groups together, for instance all resolver entries matching one of two domains, restricted to the .fr TLD :
```
    C:\PS> Search-OnypheInfo -AdvancedSearch @("(","?domain:sovcloud-core.fr","?domain:sovcloud-api.fr",")","(","?tld:fr",")") -Category resolver
```
**Important**: pass `"("` and `")"` as their own -AdvancedSearch array elements, never combined with a filter:value pair in the same string (e.g. `"( domain:a.com )"`). The module's own multi-word auto-quoting will otherwise treat the space before the closing paren as part of the value and quote it in, producing a real OQL syntax error server-side. This works the same way on Export-OnypheInfo :
```
    C:\PS> Export-OnypheInfo -AdvancedSearch @("(","?domain:sovcloud-core.fr","?domain:sovcloud-api.fr",")","(","?tld:fr",")") -Category resolver -SaveInfoAsFile .\myexport.json
```
## Result size, matched-filter tracking, and calculated fields
by default a search page returns 100 results; you can request a different page size (up to 10000) with -Size :
```
    C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -Size 500
```
-TrackQuery asks Onyphe to add, to each result, which OQL filter actually matched it (useful with broader -AdvancedSearch queries) :
```
    C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -TrackQuery
```
-Calculated asks Onyphe to enrich each result with computed fields (for instance defanged/undefanged URL variants) :
```
    C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -Calculated
```
all three parameters, and -fields, can be combined together, and -TrackQuery/-Calculated are also available on Export-OnypheInfo :
```
    C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -Size 500 -TrackQuery -Calculated -AdvancedFilter @("fields:ip,port")
    C:\PS> Export-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -TrackQuery -Calculated -SaveInfoAsFile .\myexport.json
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
all apis can be used.

## Export results to file (CSV)
a cmdlet / function is available to export a onyphe powershell object to an external CSV.
Note : the data or content properties of pastries,datascan ... are exported in dedicated text file to be more readable.
Just specify the target folder and several subfolders (on per request) containing csv and txt files will be created.
to do so use the function Export-OnypheInfoToFile :
```
    C:\PS> $AllResults = Search-OnypheInfo -SearchValue "OVH SAS" -SearchFilter organization -Category inetnum -page 1-1000
    C:\PS> Export-OnypheInfoToFile -tofolder C:\temp -InputOnypheObject $AllResults
```

## Bulk APIs, send multiple summary or simple requests at a time and get back a Json file
you can now use bulk summary / simple APIs to send several requests at a time based on a txt input file containing one entry per line (no space, no coma etc...)
3 bulk summary apis are available : ip, host, domain
17 bulk simple apis (including best) are available : ctl,datascan,datashot,geoloc,inetnum,pastries,resolver,sniffer,synscan,threatlist,topsite,vulnscan,whois
20 bulk discovery apis are also available as of v2.1.2 (**Griffin View subscription required**) - see the Discovery API example above, the input file contains one OQL query per line instead of one IP/domain/hostname per line; use `Get-OnypheDiscoveryCategories` to see which ones your account has access to
the output is not an object but a json flat file.
**Only the 10 latest results per category will be returned**
find below an example to get summary info for ten IPs contained in myfile.txt
```
    C:\PS> Export-OnypheBulkSummaryInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType ip
```

## Playing with Onyphe and PowerShell objects
### Example 1
Please onyphe, tell me what are the current IP addresses tagged with mirai botnet ?
Well, we will do the stats for the first 100 pages of results for the demo :)

First, retrieve the results (all threatlist objects tagged with mirai) :
```
    C:\PS> Search-OnypheInfo -SearchValue mirai -Category threatlist -SearchFilter tag
    C:\PS> Search-OnypheInfo -SearchValue mirai -Category threatlist -SearchFilter tag -Page 1-594
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
    C:\PS> $AllResults = Search-OnypheInfo -SearchValue Quad9 -SearchFilter organization -Category synscan -Page 1-2
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
    C:\PS> $AllResults = Search-OnypheInfo -AdvancedSearch @('organization:Citrix') -Category synscan -Page 1-7
```
Then, do the stats 
```
    C:\PS> Get-OnypheStatsFromObject -Facets port -InputOnypheObject $AllResults

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
    C:\PS> (Get-OnypheStatsFromObject -Facets port -InputOnypheObject $AllResults).Stats

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
    C:\PS> $allresults = Search-OnypheInfo -AdvancedSearch @('organization:OVH SAS','port:3389') -Category datashot -Page 1-1000
```
Then, export the screenshot of the home RDP login page for more information :)
```
    C:\PS> $allresults | Export-OnypheDataShot -tofolder .\temp\
```

### Example 5
Please Onyphe, filter the result and show me only the answer with os property not null for threatlist category for all Russia
```
    C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction exists -FilterValue os
```

### Example 6
Please Onyphe, filter the results using multiple filters (only os property known and from all organization like *company*) for tcp port 3389 opened in russia
```
    C:\PS> search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan
```

### Example 7
Please Onyphe, I have found a very useful search request and I want to create an alert for it

Well, we can manage it in different ways, first create the alert 'manually'
```
    C:\PS> set-onyphealert -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
```
Or you can pipe a search object to the set-onyphealert function
```
    C:\PS> search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan | set-onyphealert -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"
```
Or you can import an existing search object result in set-onyphealert function
```
    C:\PS> $test = search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan
    C:\PS> set-onyphealert -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io" -InputOnypheObject $test
```

### Example 8
Please Onyphe, I have found a very useful search request and I want to export the raw JSON from it for background analysis.
Very easy :), the Export-onyphe cmdlets use the exact same parameters as the search-onyphe cmdlets ;)
```
    C:\PS> Export-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan -SaveInfoAsFile .\myexport.json
```