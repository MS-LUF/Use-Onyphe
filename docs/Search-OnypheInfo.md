---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Search-OnypheInfo

## SYNOPSIS
main function/cmdlet - Search for IP information on onyphe.io web service using search API

## SYNTAX

```
Search-OnypheInfo [[-SearchValue] <String>] [[-FilterValue] <String[]>] [[-AdvancedSearch] <Array>]
 [[-APIKey] <String>] [[-Page] <String[]>] [[-wait] <Int32>] [-UseBetaFeatures] [[-AdvancedFilter] <Array>]
 [[-Size] <Int32>] [-TrackQuery] [-Calculated] [-ProgressAction <ActionPreference>] -SearchType <String>
 [-SearchFilter <String>] [-FilterFunction <String>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Search for IP information on onyphe.io web service using search API
send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

## EXAMPLES

### EXAMPLE 1
```
AdvancedSearch with multiple criteria/filters
Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
C:\PS> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan
```

### EXAMPLE 2
```
simple search with one filter/criteria
Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country
```

### EXAMPLE 3
```
AdvancedSearch with multiple criteria/filters and set the API key
Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
C:\PS> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### EXAMPLE 4
```
simple search with one filter/criteria and request page 2 of the results
Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -page "2"
```

### EXAMPLE 5
```
simple search with one filter/criteria and use a server filter to retrieve only objects indexed since 2 month
Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction monthago -FilterValue "2"
```

### EXAMPLE 6
```
filter the result and show me only the answer with os property not null for threatlist category for all Russia
C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction exist -FilterValue os
```

### EXAMPLE 7
```
filter the results using multiple filters (only os property known and from all organization like *company*) for tcp port 3389 opened in russia
C:\PS> search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan
```

### EXAMPLE 8
```
exclude a filter from the results by prefixing its name with "!" (OQL NOT), and/or OR two filters together by
prefixing them with "?" (OQL OR) - both work as plain text inside -AdvancedSearch, no dedicated parameter needed
C:\PS> Search-OnypheInfo -AdvancedSearch @("category:threatlist","!country:RU") -category threatlist
C:\PS> Search-OnypheInfo -AdvancedSearch @("?country:RU","?country:CN") -category threatlist
```

### EXAMPLE 9
```
OR several wildcard/regexp conditions together by repeating the function once per condition in -AdvancedFilter
(this is how Onyphe's OQL itself combines multiple wildcard/regexp conditions - not a single comma-packed call)
C:\PS> Search-OnypheInfo -AdvancedFilter @("orwildcard:domain,g?ogle.com","orwildcard:domain,googl?.com") -Category resolver
```

### EXAMPLE 10
```
limit output fields, request a larger page size, and ask for the matched-filter/calculated-fields metadata
C:\PS> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -Size 500 -TrackQuery -Calculated
```

### EXAMPLE 11
```
OQLv2 condition groups (requires an ASM-level or Ctiscan licence - check Get-OnypheUserInfo's oqlversion property)
group conditions with parentheses to AND two independent OR-groups together; pass "(" and ")" as their own
-AdvancedSearch array elements, never appended to a filter:value element with a space in the same string - the
module's multi-word auto-quoting will otherwise swallow the closing paren into the previous value and produce
an OQL syntax error server-side
C:\PS> Search-OnypheInfo -AdvancedSearch @("(","?domain:sovcloud-core.fr","?domain:sovcloud-api.fr",")","(","?tld:fr",")") -Category resolver
```

## PARAMETERS

### -SearchValue
-SearchValue STRING{value}
string to be searched with -SearchFilter parameter

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -FilterValue
-FilterValue String
value to use as input for FilterFunction

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdvancedSearch
-AdvancedSearch ARRAY{filter:value,filter:value}
Search with multiple criterias

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -APIKey
-APIKey string{APIKEY}
set your APIKEY to be able to use Onyphe API.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Page
-page string{page number}
go directly to a specific result page (1 to 1000)
you can set a list of page using x-y like 1-100 to read the first 100 pages

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -wait
-Wait int{second}
wait for x second before sending the request to manage rate limiting restriction

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseBetaFeatures
-UseBetaFeatures switch
use test.onyphe.io to use new beat features of Onyphe

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -AdvancedFilter
-AdvancedFilter ARRAY{filter:value,filter:value}
Filter with multiple criterias

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 12
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Size
-Size int{1 to 10000}
number of results per page (server default is 100 when omitted)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TrackQuery
-TrackQuery switch
ask Onyphe to return, for each result, which OQL filter matched it

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 14
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Calculated
-Calculated switch
ask Onyphe to enrich results with computed fields (e.g.
defanged/undefanged URL variants)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 15
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilterFunction
{{ Fill FilterFunction Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchFilter
{{ Fill SearchFilter Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchType
{{ Fill SearchType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Category

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName: System.Management.Automation.PSCustomObject
## NOTES

## RELATED LINKS
