<img src="https://www.onyphe.com/assets/img/logo/Onyphe-Logo-Official-Light-Theme.svg" alt="Onyphe" style="width:40%;">

# Use-Onyphe
Simple PowerShell module to use Onyphe.io API

Onyphe.io provides data about IP address space and publicly available information in just one place.

Some of the APIs required an API key. 
To request it : https://www.onyphe.io/login

More info about available APIs :
https://www.onyphe.io/documentation/api

(c) 2018-2026 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).
## Notes version (2.5.0)
 - Added `Invoke-OnyphePivot`: pivots from a prior Onyphe result set to a follow-up search, firing one API call per distinct value of a chosen property across the input set.

## Notes version (2.4.0)
 - `Search-OnypheInfo`/`Export-OnypheInfo` gain a `-Post` switch to send the OQL query as a POST body instead of a GET query string, avoiding URL-length limits on long queries.

## Notes version (2.3.9)
 - Added the ASD Bootstrap Certso Wildcard endpoint (`-ASDAPIType bootstrapcertsowildcard`) - last of the standard ASD endpoints.

## Notes version (2.3.8)
 - Added the ASD Web Subdomain Domain endpoint (`-ASDAPIType websubdomaindomain`).

## Notes version (2.3.7)
 - Added the ASD Domain Exist endpoint (`-ASDAPIType domainexist`); large domains require the async task mode added in 2.3.0.

## Notes version (2.3.6)
 - Added the ASD Dns Domain Ns Exist endpoint (`-ASDAPIType dnsdomainnsexist`), a live DNS lookup.

## Notes version (2.3.5)
 - Added the ASD Dns Domain MsTenantId endpoint (`-ASDAPIType dnsdomainmstenantid`) - returns sibling domains sharing the same Microsoft 365 tenant.

## Notes version (2.3.4)
 - Added the ASD Score Inventory endpoint (`-ASDAPIType scoreinventory`).

## Notes version (2.3.3)
 - Added the ASD Vhost Inventory endpoint (`-ASDAPIType vhostinventory`).

## Notes version (2.3.2)
 - Added the ASD Ip Domain endpoint (`-ASDAPIType ipdomain`).

## Notes version (2.3.1)
 - Added the ASD Ip Certso endpoint (`-ASDAPIType ipcertso`).

## Notes version (2.3.0)
 - Added ASD task management: `Get-OnypheASDTask`, `Get-OnypheASDTaskList`, `Wait-OnypheASDTask`, `Stop-OnypheASDTask` - unblocks large-domain `*inventory` endpoints that require async processing. `Invoke-OnypheAPIV2` gained `DELETE` method support.

## Notes version (2.2.6)
 - Added the ASD Org Inventory endpoint (`-ASDAPIType orginventory`); large domains need the task-polling workflow added in 2.3.0.

## Notes version (2.2.5)
 - Added the ASD Ip Inventory endpoint (`-ASDAPIType ipinventory`).

## Notes version (2.2.4)
 - Added the ASD Subnet Inventory endpoint (`-ASDAPIType subnetinventory`).

## Notes version (2.2.2)
 - Documentation-only release: documented that `Get-OnypheSummary` always returns the first page of results regardless of `-Page`.

## Notes version (2.2.1)
 - Fixed `Export-OnypheDiscoveryInfo` silently capping results at 100 per query line; added an optional `-Size` parameter.

## Notes version (2.2.0)
 - Added `Get-OnypheASDInfo`, wrapping the Attack Surface Discovery (ASD) APIv1 standard endpoints. Requires a Griffin View subscription.

## Notes version (2.1.3)
 - Documented OQLv2 condition-group (parenthesized AND-of-ORs) syntax, already supported via `-AdvancedSearch` pass-through.

## Notes version (2.1.2)
 - `Export-OnypheDiscoveryInfo` now supports all Discovery categories a Griffin View subscription can expose, up from 3.

## Notes version (2.1.1)
 - Fixed `Search-OnypheInfo`/`Export-OnypheInfo` silently dropping everything after the first `?` in a query (OQL OR-prefix collided with the URL query-string delimiter).

## Notes version (2.1.0)
 - Added the Discovery API (`Export-OnypheDiscoveryInfo`, `Get-OnypheDiscoveryCategories`, requires Griffin View). Added `-Size`/`-TrackQuery`/`-Calculated` to Search/Export. Several error-handling and OQL quoting bug fixes.

## Notes version (2.0.1)
 - Major internal refactor and security/quality release.
 - **Breaking change**: API key encryption now uses PBKDF2-SHA256 (210,000 iterations) instead of PBKDF2-SHA1 - re-run `Set-OnypheAPIKey -EncryptKeyInLocalFile` to re-encrypt an existing key.
 - Refactored the module into a `Public`/`Private/<Layer>` architecture; migrated persisted configuration from Clixml to JSON; added opt-in logging and a full Pester test suite.
 - Several security fixes (credential redaction in logs, IP validation anchoring, TLS-validation scoping, removed dynamic-dispatch via `Invoke-Expression`) and crash fixes across multiple cmdlets.

## Notes version (1.3)
 - Added whois simple API, bulk APIs, simple best APIs; new functions `Export-OnypheBulkInfo`/`Export-OnypheBulkSummaryInfo`; updated CSV templates.

## Notes version (1.2)
 - Added bulk APIs; optimized file export memory usage; standardized on the `PSOnyphe` object type; various bug fixes.

## Notes version (1.1)
 - Migrated from APIv1 to full APIv2 (bulk API deferred to 1.2); updated CSV templates for the new API naming convention.

## Notes version (1.00)
 - Fixed a rate-limiting issue on paging; added new API support in `Export-OnypheInfoToFile`.

## Notes version (0.99)
 - Replaced `$env:appdata` with `$home` for Linux/PowerShell Core compatibility; added APIv2 request handling and Alert API functions.

## Notes version (0.98)
 - Fixed paging regex to support more than 1000 pages.

## Notes version (0.97)
 - Added a beta-interface switch, improved paging parameters, added `-AdvancedFilter`, added onionshot support.

## Notes version (0.96)
 - Added search filtering functions and `Get-OnypheSearchFunctions`; renamed several search parameters.

## Notes version (0.95)
 - Fixed HTTP error handling when no network is available; added datashot management and export.

## Notes version (0.94)
 - Added new APIs (ctl, sniffer, onionscan, md5); simplified `Get-OnypheInfo`.

## Notes version (0.93)
 - Added statistics function.

## Notes version (0.92)
 - Added tag filter, proxy support, encrypted API key storage, and paging.

## How-to
an updated how-to is now available here : https://github.com/MS-LUF/Use-Onyphe/blob/master/Howto.md

## Configuration file
Use-Onyphe persists your API key (if you choose to encrypt it to disk), proxy settings placeholder, API/filter/function cache, and logging preferences in a single JSON file (`$home\Use-Onyphe\Use-Onyphe-Config.json`). A sample file and a full explanation of every section are available here :
- Sample config file : [Templates/Use-Onyphe-Config.sample.json](./Templates/Use-Onyphe-Config.sample.json)
- Full documentation : [Templates/ConfigSchema.md](./Templates/ConfigSchema.md)

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
- Export-OnypheBulkSummaryInfo
- Export-OnypheDataShot
- Export-OnypheDiscoveryInfo
- Export-OnypheInfo
- Export-OnypheInfoToFile
- Get-OnypheAlertInfo
- Get-OnypheASDAPIName
- Get-OnypheASDInfo
- Get-OnypheASDTask
- Get-OnypheASDTaskList
- Get-OnypheBulkAPIType
- Get-OnypheBulkCategories
- Get-OnypheCliFacets
- Get-OnypheDiscoveryCategories
- Get-OnypheInfo
- Get-OnypheInfoFromCSV
- Get-OnypheSearchCategories
- Get-OnypheSearchFilters
- Get-OnypheSearchFunctions
- Get-OnypheSimpleAPIName
- Get-OnypheSimpleBestAPIName
- Get-OnypheStatsFromObject
- Get-OnypheSummary
- Get-OnypheSummaryAPIName
- Get-OnypheUserInfo
- Import-OnypheEncryptedIKey
- Invoke-OnyphePivot
- Search-OnypheInfo
- Set-OnypheAlertInfo
- Set-OnypheAPIKey
- Set-OnypheProxy
- Stop-OnypheASDTask
- Update-OnypheFacetsFilters
- Wait-OnypheASDTask

### alias
- Export-Onyphe
- Export-OnypheBulkDiscovery
- Export-OnypheBulkSimple
- Export-OnypheBulkSummary
- Get-Onyphe
- Get-OnypheAlert
- Get-OnypheFromCSV
- Search-Onyphe
- Set-OnypheAlert
- Update-OnypheLocalData