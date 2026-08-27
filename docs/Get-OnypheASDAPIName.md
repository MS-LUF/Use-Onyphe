---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Get-OnypheASDAPIName

## SYNOPSIS
Get ASD API type available for Onyphe

## SYNTAX

```
Get-OnypheASDAPIName
```

## DESCRIPTION
Get ASD API type available for Onyphe.
Unlike Get-OnypheDiscoveryCategories/Get-OnypheSimpleAPIName, this
list cannot be derived from /v2/user's "apis" metadata - the ASD APIs (v1, BETA) do not appear in that
array (confirmed against a live Griffin View account), so the 9 currently-implemented standard ASD API
(stdapis) type names are hardcoded here instead.
Whether they are actually usable on a given account still
depends on that account's asd.stdapis licence flag (see Get-OnypheUserInfo) - this function always returns
the full list regardless of licensing, the API call itself will fail server-side if unlicensed.

## EXAMPLES

### EXAMPLE 1
```
Get ASD API type available for Onyphe
C:\PS> Get-OnypheASDAPIName
```

## PARAMETERS

## INPUTS

## OUTPUTS

### ASD API type as string
## NOTES

## RELATED LINKS
