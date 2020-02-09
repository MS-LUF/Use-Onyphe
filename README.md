![image](https://www.onyphe.io/img/logo-solo.png)

# Use-Onyphe
Simple PowerShell module to use Onyphe.io API

Onyphe.io provides data about IP address space and publicly available information in just one place.

Some of the APIs required an API key. 
To request it : https://www.onyphe.io/login

More info about available APIs :
https://www.onyphe.io/documentation/api

(c) 2018-2020 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).

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
a new how-to is now available here : https://github.com/MS-LUF/Use-Onyphe/blob/master/Howto.md

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
- Export-OnypheDataShot
- Export-OnypheInfoToFile
- Get-OnypheAlertInfo
- Get-OnypheAPIName
- Get-OnypheCliFacets
- Get-OnypheInfo
- Get-OnypheInfoFromCSV
- Get-OnypheSearchCategories
- Get-OnypheSearchFilters
- Get-OnypheSearchFunctions
- Get-OnypheStatsFromObject
- Get-OnypheUserInfo
- Get-ScriptDirectory
- Import-OnypheEncryptedIKey
- Invoke-APIOnypheAddAlert
- Invoke-APIOnypheCtl
- Invoke-APIOnypheDataScan
- Invoke-APIOnypheDelAlert
- Invoke-APIOnypheForward
- Invoke-APIOnypheGeoloc
- Invoke-APIOnypheInetnum
- Invoke-APIOnypheIP
- Invoke-APIOnypheListAlert
- Invoke-APIOnypheMD5
- Invoke-APIOnypheMyIP
- Invoke-APIOnypheOnionScan
- Invoke-APIOnyphePastries
- Invoke-APIOnypheReverse
- Invoke-APIOnypheSearch
- Invoke-APIOnypheSniffer
- Invoke-APIOnypheSynScan
- Invoke-APIOnypheThreatlist
- Invoke-APIOnypheUser
- Invoke-OnypheAPIV1
- Invoke-OnypheAPIV2
- Search-OnypheInfo
- Set-OnypheAlertInfo
- Set-OnypheAPIKey
- Set-OnypheProxy
- Update-OnypheFacetsFilters
### alias
- Get-Onyphe
- Get-OnypheAlert
- Get-OnypheFromCSV
- Search-Onyphe
- Set-OnypheAlert
- Update-OnypheLocalData
