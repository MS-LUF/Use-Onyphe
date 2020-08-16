![image](https://www.onyphe.io/img/logo-solo.png)

# Use-Onyphe
Simple PowerShell module to use Onyphe.io API

Onyphe.io provides data about IP address space and publicly available information in just one place.

Some of the APIs required an API key. 
To request it : https://www.onyphe.io/login

More info about available APIs :
https://www.onyphe.io/documentation/api

(c) 2018-2020 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).
## Notes version (1.2) - last public version :
 - add bulk APIs
 - update code to optimize file export (best memory management)
 - update object type to PSOnyphe
 - update inputobject parameter to InputOnypheObject on all functions
 - fix various bug found 

## Notes version (1.1) :
 - add new APIv2, migrate from APIv1 to full APIv2 (except bulk API that will be provided in 1.2)
   - sample csv files are updated to take into account new API and new api naming convention, please check them and update your current CSV file using the new templates.
 - remove temporary fix for empty array in APIv2
 - update deserialization of psobject
## Notes version (1.00) :
 - fix rate limiting issue on paging
 - manage new API in Export-OnypheInfoToFile
## Notes version (0.99) :
 - replace $env:appdata with $home for Linux and Powershell Core compatibility
 - create new function to request APIv2 (Invoke-OnypheAPIV2) and managing api key as new header etc...
 - rename previous function to request APIv1 (Invoke-OnypheAPIV1) and fix Net.WebException management for PowerShell core
 - create new functions to deal with Onyphe Alert APIs (Invoke-APIOnypheListAlert, Invoke-APIOnypheDelAlert, Invoke-APIOnypheAddAlert)
 - create new functions for managing the Onyphe Alert (Get-OnypheAlertInfo, Set-OnypheAlertInfo)
## Notes version (0.98) :
 - fix paging regex to support more than 1000 pages
## Notes version (0.97) :
 - code improvement
 - add beta switch to use beta interface of onyphe instead of production one
 - improve paging parameters
 - add advancedfilter option to Search-onyphe to manage multiple filter functions input
 - add onionshot category to datashot export function
## Notes version (0.96) :
- add new filtering function for search request
- add Get-OnypheSearchFunctions function
- update Invoke-APIOnypheSearch and Search-OnypheInfo functions
- replace SimpleSearchfilter parameter with SimpleSearchfilter
- replace SimpleSearchValue parameter with SearchValue
- add FunctionFilter and FunctionValue parameters
- update Get-OnypheInfoFromCSV to manage new filter function in search request
- add new alias Get-OnypheInfoFromCSV
## Notes version (0.95) :
- fix HTTP error on invoke-onyphe when no network is available
- add datashot management
- add function to export datashot to picture file
- fix Get-OnypheInfoFromCSV
- update Export-OnypheInfoToFile
## Notes version (0.94) :
- manage new apis (ctl, sniffer, onionscan, md5)
- use userinfos API to collect APIs and search filters
- rewrite get-onyphe info function to simplify the code
- update invoke-apionyphedatascan with only a single parameter
## Notes version (0.93)
- add statistics function
## Notes version (0.92)
- add tag filter
- manage new search APIs
- code refactoring
- fix file export for new categories and properties
- manage proxy connection
- manage API key storage with encryption in a config file
- add paging feature on search and info functions

## How-to
an updated how-to is now available here : https://github.com/MS-LUF/Use-Onyphe/blob/master/Howto.md

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
	
	.EXAMPLE
	C:\PS> import-module use-onyphe.psm1
```

## module content
documentation in markdown available here : https://github.com/MS-LUF/Use-Onyphe/tree/master/docs
### function
- Export-OnypheBulkInfo
- Export-OnypheDataShot
- Export-OnypheInfo
- Export-OnypheInfoToFile
- Get-OnypheAlertInfo
- Get-OnypheCliFacets
- Get-OnypheInfo
- Get-OnypheInfoFromCSV
- Get-OnypheSearchCategories
- Get-OnypheSearchFilters
- Get-OnypheSearchFunctions
- Get-OnypheSimpleAPIName
- Get-OnypheStatsFromObject
- Get-OnypheSummary
- Get-OnypheSummaryAPIName
- Get-OnypheUserInfo
- Get-ScriptDirectory
- Import-OnypheEncryptedIKey
- Invoke-APIBulkSummaryOnypheDomain
- Invoke-APIBulkSummaryOnypheHostname
- Invoke-APIBulkSummaryOnypheIP
- Invoke-APIOnypheAddAlert
- Invoke-APIOnypheCtl
- Invoke-APIOnypheDataScan
- Invoke-APIOnypheDatascanDataMD5
- Invoke-APIOnypheDataShot
- Invoke-APIOnypheDelAlert
- Invoke-APIOnypheExport
- Invoke-APIOnypheGeoloc
- Invoke-APIOnypheInetnum
- Invoke-APIOnypheListAlert
- Invoke-APIOnypheOnionScan
- Invoke-APIOnypheOnionShot
- Invoke-APIOnyphePastries
- Invoke-APIOnypheResolver
- Invoke-APIOnypheResolverForward
- Invoke-APIOnypheResolverReverse
- Invoke-APIOnypheSearch
- Invoke-APIOnypheSniffer
- Invoke-APIOnypheSynScan
- Invoke-APIOnypheThreatlist
- Invoke-APIOnypheTopSite
- Invoke-APIOnypheUser
- Invoke-APIOnypheVulnscan
- Invoke-APISummaryOnypheDomain
- Invoke-APISummaryOnypheHostname
- Invoke-APISummaryOnypheIP
- Invoke-OnypheAPIV2
- Search-OnypheInfo
- Set-OnypheAlertInfo
- Set-OnypheAPIKey
- Set-OnypheProxy
- Update-OnypheFacetsFilters  

### alias
- Export-Onyphe
- Get-Onyphe
- Get-OnypheAlert
- Get-OnypheFromCSV
- Search-Onyphe
- Set-OnypheAlert
- Update-OnypheLocalData