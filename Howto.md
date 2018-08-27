# Use-Onyphe - How-To

## Intro Onyphe
Onyphe.io provides data about IP address space and publicly available information in just one place.

Some of the APIs required an API key. 
To request it : https://www.onyphe.io/login

More info about available APIs :
https://www.onyphe.io/documentation/api

(c) 2018 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).

## Intro Use-Onyphe
Hello Guys,

A few words about the Powershell module Use-Onyphe that you can use to simply request Onyphe APIs from a Powershell prompt or script.
The module is available from :
 - Powershell Gallery (using install-module / update-module from Powershell command line on recent PS version) https://www.powershellgallery.com/packages/Use-Onyphe/
 - Github https://github.com/MS-LUF/Use-Onyphe

After the installation and load of the module (using import-module), you will have to manage your context before starting to use it :-)

C:\PS> import-module "C:\My Modules\Use-Onyphe.psd1" -DisableNameChecking

## Prerequisites
### Prerequisite 1 : Managing your API Key
First thing to do is your API Key. You can directly load it in a global variable through Set-OnypheAPIKey :
```
    C:\PS>Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```
Or, you can save it encrypted in a local file (%appdata%\Use-Onyphe\Use-Onyphe-Config.xml) and load it at each start of Powershell using your Profile Script
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
You can also add it in your Microsoft.Powershell_profile.ps1 to set your environment automatically

## Output of Use-Onyphe functions / cmdlets
all output are managed through Powershell Objects (TypeName: System.Management.Automation.PSCustomObject)
It means you can do pretty everything with the output using native powershell features.

cli-* properties of the objects are properties added by the cmdlets (not directly managed by onyphe API). In those properties, you can find :
 - a date time object of the request
 - the API called
 - the API input
 - if the API required an API Key

sample output :
```
    cli-API_info     : {ip}
    cli-API_input    : {9.9.9.9}
    cli-key_required : {True}
    cli-Request_Date : 22/08/2018 16:50:44
```
For the rest, each key of the json output is converted into a powershell object property. the type of the property could be a string,integer,array,hash table

object example for request Get-OnypheInfo -ip 9.9.9.9 (all info available for IP 9.9.9.9) :
```
    C:\PS>Get-OnypheInfo -ip 9.9.9.9

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
    cli-key_required : {True}
    cli-Request_Date : 22/08/2018 23:50:01
```
all the results are hosted in the property "results", to open it directly :
```
    C:\PS>(Get-OnypheInfo -ip 9.9.9.9).results

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
    C:\PS>(Get-OnypheInfo -ip 9.9.9.9).results | get-member

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
    C:\PS>"9.9.9.9" | Get-OnypheInfo
```
Search-OnypheInfo function will accept string as input for SimpleSearchValue parameter
```
    C:\PS>"OVH SAS" | Search-OnypheInfo -SimpleSearchFilter organization -SearchType inetnum
```
you can use the "verbose" parameter to show several useful information (like full url requested etc...)
```
    C:\PS>"9.9.9.9" | Get-OnypheInfo -verbose
```
sample command line output :
```
    URL Info : ip/9.9.9.9
    GET https://www.onyphe.io/api/ip/9.9.9.9?apikey=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx with 0-byte payload
    received 9073-byte response of content type application/json;charset=UTF-8
```
if you don't want to store your API key and don't set it as global variable, you can use the parameter "APIKey" followed by your APIkey protected with double quotes on the main functions :
```
    C:\PS>Get-OnypheInfo -IP "9.9.9.9" -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## Help on cmdlets / functions
Get-help is available on all functions, for instance, if you want to consult the help section of Get-OnypheInfo (input, output, description and examples are available)
```
    C:\PS>Get-Help Get-OnypheInfo -full
```

## Using Use-Onyphe to use onyphe.io API
3 main functions / cmdlets will be used : 
 - Get-OnypheInfo to use Myip,geoloc,ip,inetnum,threatlist,pastries,synscan,datascan,reverse,forward APIs
 - Search-OnypheInfo to use all search APIs. Last but not least
 - Get-OnypheUserInfo will be used to follow your API key / user account (user API)
 
Find hereunder several use cases for all API examples documented on https://www.onyphe.io/documentation/api

API MyIP : return your client public IP address
```
    C:\PS>Get-OnypheInfo -MyIP
```
API Geoloc : Return geolocation * information for the given IPv{4,6} address
```
    C:\PS>Get-OnypheInfo -IP 9.9.9.9 -searchtype Geoloc
```
API User : Return information about your user account
```
    C:\PS>Get-OnypheUserInfo
```
API IP : Return a summary of all information
```
    C:\PS>Get-OnypheInfo -IP 93.184.216.34
```
API Inetnum : Return inetnum information
```
    C:\PS>Get-OnypheInfo -IP 93.184.208.1 -searchtype Inetnum
```
API Threatlist : Return threatlist information
```
    C:\PS>Get-OnypheInfo -IP 206.81.18.195 -searchtype threatlist
```
API Pastries : Return pastries information
```
    C:\PS>Get-OnypheInfo -IP 93.184.216.34 -searchtype pastries
```
API Synscan : Return synscan information
```
    C:\PS>Get-OnypheInfo -IP 107.164.81.7 -searchtype SynScan
```
API Datascan : Return datascan information
```
    C:\PS>Get-OnypheInfo -IP 107.164.81.7 -searchtype DataScan
```
```
    C:\PS>Get-OnypheInfo -DataScanString IIS -searchtype DataScan
```
API Reverse : Return reverse information
```
    C:\PS>Get-OnypheInfo -IP 182.59.164.193 -searchtype Reverse
```
API Forward : Return forward information
```
    C:\PS>Get-OnypheInfo -IP 2.22.52.73 -searchtype Reverse
```
API Search/DataScan : Return datascan information
```
    C:\PS>Search-OnypheInfo -AdvancedSearch @('product:Apache','port:443','os:Windows') -SearchType datascan
```
```
    C:\PS>Search-OnypheInfo -SimpleSearchValue Windows -SimpleSearchFilter os -SearchType datascan
```
API Search/Synscan : Return synscan information
```
    C:\PS>Search-OnypheInfo -AdvancedSearch @('country:FR','port:23','os:Linux') -SearchType synscan
```
```
    C:\PS>Search-OnypheInfo -SimpleSearchValue 23 -SimpleSearchFilter port -SearchType synscan
```
API Search/Inetnum : Return inetnum information
```
    C:\PS>Search-OnypheInfo -SimpleSearchValue "OVH SAS" -SimpleSearchFilter organization -SearchType inetnum
```
API Search/Threatlist : Return threatlist information
```
    C:\PS>Search-OnypheInfo -SimpleSearchValue RU -SimpleSearchFilter country -SearchType threatlist
```
API Search/pastries : Return pastries information
```
    C:\PS>Search-OnypheInfo -SimpleSearchValue "195.29.70.0/24" -SimpleSearchFilter ip -SearchType pastries
```
API Search/Resolver : Return resolver information
```
    C:\PS>Search-OnypheInfo -SimpleSearchValue "124.108.0.0/16" -SimpleSearchFilter ip -SearchType resolver
```
API Search/sniffer : Return sniffer information
```
    C:\PS>Search-OnypheInfo -SimpleSearchValue "14.164.0.0/14" -SimpleSearchFilter ip -SearchType sniffer
```
API Search/onionscan : Return onionscan information
```
    C:\PS>Search-OnypheInfo -SimpleSearchValue market -SimpleSearchFilter data -SearchType onionscan
```

## paging and results
by default 10 results are available in on object. if you have more than 10 results available, you can consult them ten by ten using pages.
for instance the following request "Search-OnypheInfo -SimpleSearchValue "OVH SAS" -SimpleSearchFilter organization -SearchType inetnum" will send back a powershell object with the properties "max_page" to 1000.
by default, the object will embbed the first 10 results available on the first page. to consult the page 2 containing the next 10 results, you can use the property "page" :
```
    C:\PS>Search-OnypheInfo -SimpleSearchValue "OVH SAS" -SimpleSearchFilter organization -SearchType inetnum -page 2
```
You will see that the property "page" will switch to "2" and the "results" properties will be updated with the next 10 results.
if you want to retrieve all the pages, you can do a simple loop :
```
    C:\PS>$script:AllResults = @()
    C:\PS>for ($i=1;$i -le 1000;$i++) {$script:AllResults += Search-OnypheInfo -SimpleSearchValue "OVH SAS" -SimpleSearchFilter organization -SearchType inetnum -page $i -wait 3}
```
Note : parameter "-wait 3" will wait 3 seconds between each request to manage rate limiting.

## managing rate limiting
you can add the parameter "wait" followed by a digit to request to wait x seconds between each request to manage rate limiting feature.
It's usefull in case of a loop or in batch mode usage.
Note : in batch usage (see next chapter) the wait parameter is set automatically to 3

## batch mode usage
a cmdlet / function is available to automate request based on a csv.
the output is an array containing all results.
to do so use the function "Get-OnypheInfoFromCSV"
```
    C:\PS> Get-OnypheInfoFromCSV -fromcsv .\input.csv
```
by default the CSV delimieter is ; (made in France ;-) ) to change it, use the parameter -csvde followed by the separator protected by double quotes.
you can find a csv template on my github here : https://raw.githubusercontent.com/MS-LUF/Use-Onyphe/master/sample_testonyphe.csv
all apis can be used. currently the pages are not managed, it should be done in the next version of the module (it means only the first 10 results are managed by default).

## export results to file (CSV)
a cmdlet / function is available to export a onyphe powershell object to an external CSV.
Note : the data or content properties of pastries,datascan ... are exported in dedicated text file to be more readable.
Just specify the target folder and several subfolders (on per request) containing csv and txt files will be created.
to do so use the function Export-OnypheInfoToFile :
```
    C:\PS>$script:AllResults = @()
    C:\PS>for ($i=1;$i -le 1000;$i++) {$script:AllResults += Search-OnypheInfo -SimpleSearchValue "OVH SAS" -SimpleSearchFilter organization -SearchType inetnum -page $i -wait 3}
    C:\PS>Export-OnypheInfoToFile -tofolder C:\temp -inputobject $AllResults
```

## playing with onyphe and powershell objects
### Example 1
Please onyphe, tell me what are the current IP addresses tagged with mirai botnet ?
Well, we will do the stats for the first 100 pages of results for the demo :)

First, retrieve the results (all threatlist objects tagged with mirai) :
```
    C:\PS>$script:AllResults = @()
    C:\PS>for ($i=1;$i -le 100;$i++) {$script:AllResults += Search-OnypheInfo -SimpleSearchValue mirai -SearchType threatlist -SimpleSearchFilter tag -page $i -wait 3}
```
Then, play with the objects :-)
how many unique ip ?
```
    C:\PS>($AllResults.results.subnet | sort-object | Get-Unique).count
    978
```

The ip list itself ?
```
    C:\PS>$AllResults.results.subnet | sort-object | Get-Unique
    ...
    95.5.2.125/32
    95.9.177.76/32
    96.78.106.179/32
    96.84.126.5/32
```
Well, not so hard, isn't it ;-)

### Example 2
Please onyphe, I am a security guy from Quad9 and I want to have an overview of all my opened ports on internet.
Well, quite simple :)

First, retrieve all the results avaialable (all synscan objects linked to Quad9 organization) :
```
    C:\PS>$script:AllResults = @()
    C:\PS>for ($i=1;$i -le ([int](Search-OnypheInfo -SimpleSearchValue Quad9 -SimpleSearchFilter organization -SearchType synscan).max_page);$i++) {$script:AllResults += Search-OnypheInfo -SimpleSearchValue Quad9 -SimpleSearchFilter organization -SearchType synscan -page $i -wait 3}
```
Then, play with the objects :-)
What are the open ports ?
```
    C:\PS>$AllResults.results.port | sort-object | get-unique
    3389
    443
    53
```

wait... I can see 3389 in the list !
can you please tell me what is the ip related to this port ?

of course !
```
    C:\PS>($AllResults.results | Where-Object {$_.port -eq 3389}).ip | sort-object | get-unique
    9.9.9.9
```

thank you, let me check... it seems the port is now closed... but need some investigation !

Still easy, isn't it ;-)
