<img src="https://www.onyphe.com/assets/img/logo/Onyphe-Logo-Official-Light-Theme.svg" alt="Onyphe" style="width:40%;">

# Use-Onyphe
Simple PowerShell module to use Onyphe.io API

Onyphe.io provides data about IP address space and publicly available information in just one place.

Some of the APIs required an API key. 
To request it : https://www.onyphe.io/login

More info about available APIs :
https://www.onyphe.io/documentation/api

(c) 2018-2026 lucas-cueff.com Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).

## Notes version (2.2.0) - ASD (Attack Surface Discovery) APIv1 integration :
 - new `Get-OnypheASDInfo -ASDAPIType <type> -Value <domain(s) or certso value(s)>` cmdlet wraps the 9 "standard" (stdapis) ASD APIv1 endpoints: `domaintld`, `domainwildcard`, `domaincertso`, `certsodomain`, `certsowildcard`, `dnsdomainns`, `dnsdomainmx`, `dnsdomainsoa`, `dnsdomainexist`. These are BETA endpoints (`POST /api/v1/asd/...`) requiring a Griffin View or Griffin View ASM Edition subscription with a non-commercial use licence - check `Get-OnypheUserInfo`'s `asd.stdapis` property before use. New `Get-OnypheASDAPIName` lists the 9 implemented type names.
 - unlike every other API family in this module, ASD endpoints are **not** discoverable via `/v2/user`'s `apis` metadata array (confirmed empirically against a live Griffin View account - it lists zero `asd/*` entries) - the type list is hardcoded in `Get-OnypheASDAPIName` instead of derived dynamically.
 - reuses the existing `Invoke-OnypheAPIV2` HTTP transport as-is: live-tested that the module's existing `Authorization: apikey` header (its v2 auth scheme) also authenticates successfully against these v1 endpoints, even though Onyphe's own ASD docs show `X-Api-Key` in their curl examples - no new auth scheme needed. Only change to the shared transport: `cli-API_version` is now parametrized (`-APIVersion`, defaults to `"2"`) instead of hardcoded, so ASD calls correctly report `"1"`.

## Notes version (2.1.3) - OQLv2 condition-group documentation :
 - documented and live-verified (against a real ASM-level/Ctiscan-licensed account) that OQLv2 condition-group syntax - grouping conditions in parentheses to AND two OR-groups together, e.g. `category:resolver ( ?domain:a.com ?domain:b.com ) ( ?tld:fr )` - already works today through `Search-OnypheInfo`/`Export-OnypheInfo`'s existing `-AdvancedSearch` plain-text pass-through, same as the `!`/`?` NOT/OR prefixes documented in 2.1.0. 

## Notes version (2.1.2) - Discovery API full category coverage :
 - `Export-OnypheDiscoveryInfo` now supports all 20 Discovery categories a Griffin View subscription can expose (`ctiscan`, `ctiurl`, `ctl`, `datascan`, `datashot`, `domain`, `geoloc`, `hostname`, `inetnum`, `ip`, `onionscan`, `onionshot`, `pastries`, `resolver`, `riskscan`, `sniffer`, `threatlist`, `topsite`, `vulnscan`, `whois`), up from 3 (`datascan`/`resolver`/`vulnscan`). `Get-OnypheDiscoveryCategories` already derived its list dynamically from the account's `/v2/user` metadata, so it correctly advertised all 20 categories as valid `-Category` values - but 17 of them had no `Invoke-APIBulkDiscoveryOnyphe<Category>` wrapper behind them and threw `"Discovery API X not implemented yet in this version of Use-Onyphe pwsh module"` when selected. Found and fixed via live testing against a real Griffin View key (the mocked-only test suite couldn't have caught this, since it stubs `Get-OnypheDiscoveryCategories`'s return value).

## Notes version (2.1.1) - Search/Export OQL transport fix :
 - fixed `Search-OnypheInfo`/`Export-OnypheInfo` (and their private `Invoke-APIOnyphe{Search,Export}` wrappers) silently dropping everything after the first `?` in a query. The OQL string used to be embedded directly in the URL *path* (`v2/search/category:X <oql>`); since `?` is the URI query-string delimiter, an OQL `?field:value` OR-prefix silently truncated the request there - the truncated remainder was still sent, as a bogus query string the server ignored, with no error. Requests are now built as `v2/search/?q=<oql>&...` / `v2/export/?q=<oql>&...`, matching Onyphe's current documented endpoint shape, with the `q` value properly percent-encoded via `EscapeDataString`. Live-verified: a 4-domain OR query (`?domain:a ?domain:b ?domain:c ?domain:d`) that previously returned only the first domain's results now returns the correct union across all four.
   - found while fixing this (not a code change, just documented since it looks like a bug otherwise): OR only unions correctly when *every* alternative for a field is `?`-prefixed (`?domain:a ?domain:b`) - mixing one bare `domain:a` with `?domain:b` doesn't union them, it's read as `domain:a AND (domain:a OR domain:b)`, i.e. just `domain:a`.
 - `Invoke-OnypheAPIV2` now emits a `Write-Warning` when the server returns fewer results per page than requested via `-Size` (e.g. asking for `-Size 1000` and silently getting the default page size of 10 back) instead of failing silently. The real per-account page-size ceiling is lower than the documented `1-10000` range and isn't exposed by the API, so `-Size` stays best-effort rather than guaranteed - use `-Page` to walk additional results instead of assuming a larger `-Size` was honored.

## Notes version (2.1.0) - Discovery API and OQL query-language gap-closing release :
 - added the Discovery API (**requires a Griffin View subscription on Onyphe**): `Export-OnypheDiscoveryInfo` (alias `Export-OnypheBulkDiscovery`) runs a file of OQL queries (one per line) in bulk against the `datascan`, `resolver`, or `vulnscan` category and streams back the JSON results; `Get-OnypheDiscoveryCategories` lists which Discovery categories your account has access to
 - added `-Size`, `-TrackQuery`, and `-Calculated` to `Search-OnypheInfo`/`Invoke-APIOnypheSearch` (`-TrackQuery`/`-Calculated` also on `Export-OnypheInfo`/`Invoke-APIOnypheExport`) to control result page size and request Onyphe's matched-filter/computed-field metadata
 - documented (with corrected examples) that OQL's `!field`/`?field` NOT/OR prefixes, and combining multiple `-wildcard`/`-regexp` conditions, already work today via plain-text entries in `-AdvancedSearch`/`-AdvancedFilter` - no new parameters were needed, the previous examples for multi-condition wildcard/regexp were just wrong about the syntax (Onyphe repeats the function once per condition rather than packing multiple field/pattern pairs into one call)
 - bug fixes:
   - `Invoke-OnypheAPIV2`'s error handling only tried to extract the real Onyphe error message for HTTP status 429/400 (and a dead 200 branch); every other error status (401/403/404/500/503/...) silently discarded the actual API error and returned a generic one instead - it now always attempts to extract the real error message first
   - fixed an `-AdvancedFilter` quoting bug where a function value containing more than one comma (e.g. a value needing quoting after a literal comma) could silently lose its quoting past the 2nd comma-separated segment
   - removed a dead, no-op leftover line in the datascan simple API wrapper
 - added a `-TimeoutSec` parameter to `Invoke-OnypheAPIV2` (default 100s) - HTTP requests had no timeout before, so a broad/slow query (e.g. an unpaged `Export-OnypheInfo` request) could hang indefinitely

## Notes version (2.0.1) - major internal refactor and security/quality release :
 - **Breaking change**: API key encryption (`Set-OnypheAPIKey -EncryptKeyInLocalFile`) now derives its key with PBKDF2-SHA256 at 210,000 iterations instead of the previous PBKDF2-SHA1 at 1,000 iterations. An API key encrypted by an older version will fail to decrypt after upgrading — re-run `Set-OnypheAPIKey -EncryptKeyInLocalFile` to re-encrypt it.
 - full internal refactor of the module into a `Public/`/`Private/<Layer>/` architecture (one file per cmdlet/helper); `Use-Onyphe.psm1` is now a thin loader. Same 26 public functions / 9 aliases (35 total) still exported — no change to the public command surface.
 - migrated persisted configuration from Clixml (`Use-Onyphe-Config.xml`, `Onyphe-Data-Model.xml`) to a single JSON file (`Use-Onyphe-Config.json` under `%home%\Use-Onyphe\`); an existing `.xml` file is auto-migrated to `.json` the first time the module runs
 - added opt-in logging via `Write-OnypheLog` (file or Windows Event Log, minimum-level filtering, redacts sensitive parameter values); every public cmdlet now logs its invocation
 - added a full Pester unit-test suite: 238 tests covering every internal layer and every public cmdlet
 - security fixes:
   - the API key was written in cleartext to the `-Verbose` stream when calling the Onyphe API; the `Authorization` header is now redacted before logging
   - IP address parameters accepted values with a valid IP anywhere in the string (e.g. `"garbage8.8.8.8garbage"`) instead of requiring the whole value to be a valid IP; validation is now anchored and consolidated into one shared, tested helper instead of 19 duplicated copies
   - the `-UseBetaFeatures` switch on Windows PowerShell 5.1 disabled TLS certificate validation for the rest of the PowerShell session instead of just the one beta-API request; it is now correctly scoped and restored afterward
   - removed `Invoke-Expression`-based dynamic dispatch (replaced with the PowerShell call operator) in `Get-OnypheInfo`, `Get-OnypheSummary`, `Export-OnypheBulkInfo`, `Export-OnypheBulkSummaryInfo`
 - bug fixes:
   - fixed a crash in any cmdlet using tab-completed/validated parameters (`Get-OnypheInfo`, `Get-OnypheSummary`, `Search-OnypheInfo`, `Export-OnypheInfo`, `Export-OnypheBulkInfo`, `Export-OnypheBulkSummaryInfo`, `Set-OnypheAlertInfo`, `Get-OnypheStatsFromObject`) when used before the facets/filters cache had ever been generated (fresh install)
   - fixed a crash when passing a single (non-range) `-Page` value to `Get-OnypheInfo`/`Get-OnypheSummary`/`Search-OnypheInfo`
   - fixed a crash when an `-AdvancedFilter` entry had no `:` separator (search, export, and alert-creation)
   - fixed `Set-OnypheAlertInfo -AlertAction delete -UseBetaFeatures` throwing, and `-UseBetaFeatures` not being applied to the alert lookup/delete calls (a beta alert could be deleted against production instead)
   - fixed an internal error-handling bug that could mask the real HTTP error message on certain API error responses
   - fixed the bulk pastries API being mislabeled internally as `"patries"`
 - added `-WhatIf`/`-Confirm` support to `Set-OnypheAPIKey`, `Set-OnypheProxy`, `Set-OnypheAlertInfo`, and `Update-OnypheFacetsFilters`
 - configuration file writes are now atomic (crash-safe), and a corrupted configuration file now produces a clear error instead of an opaque JSON-parsing exception
 - consolidated 20 near-identical bulk file-upload internal functions into one shared implementation, reducing duplicated code and the risk of the kind of copy/paste drift that caused some of the bugs above

## Notes version (1.3) :
 - add whois simple API
 - update bulk APIs
 - add simple best APIs
 - minor improvement
 - new aliases : Export-OnypheBulkSimple, Export-OnypheBulkSummary
 - new functions : Export-OnypheBulkInfo, Export-OnypheBulkSummaryInfo
 - updated functions : Get-OnypheInfo
 - update csv templates 

## Notes version (1.2) :
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
- Search-OnypheInfo
- Set-OnypheAlertInfo
- Set-OnypheAPIKey
- Set-OnypheProxy
- Update-OnypheFacetsFilters

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