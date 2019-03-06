# Use-Onyphe
Simple PowerShell module to use Onyphe.io API

Onyphe.io provides data about IP address space and publicly available information in just one place.

Some of the APIs required an API key. 
To request it : https://www.onyphe.io/login

More info about available APIs :
https://www.onyphe.io/documentation/api

(c) 2018-2019 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).

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
documentation in markdown available here : https://github.com/MS-LUF/Use-Onyphe/docs
### function
- Export-OnypheInfoToFile
- Get-OnypheAPIName
- Get-OnypheCliFacets
- Get-OnypheInfo
- Get-OnypheInfoFromCSV
- Get-OnypheSearchCategories
- Get-OnypheSearchFilters
- Get-OnypheStatsFromObject
- Get-OnypheUserInfo
- Get-ScriptDirectory
- Import-OnypheEncryptedIKey
- Invoke-APIOnypheCtl
- Invoke-APIOnypheDataScan
- Invoke-APIOnypheForward
- Invoke-APIOnypheGeoloc
- Invoke-APIOnypheInetnum
- Invoke-APIOnypheIP
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
- Invoke-Onyphe
- Search-OnypheInfo
- Set-OnypheAPIKey
- Set-OnypheProxy
- Update-OnypheFacetsFilters
### alias
- Get-Onyphe
- Search-Onyphe
- Update-OnypheLocalData
