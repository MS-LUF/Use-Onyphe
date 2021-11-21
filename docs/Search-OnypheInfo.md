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
 -SearchType <String> [-SearchFilter <String>] [-FilterFunction <String>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Search for IP information on onyphe.io web service using search API
send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

## EXAMPLES

### EXEMPLE 1
```
AdvancedSearch with multiple criteria/filters
```

Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
C:\PS\> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan

### EXEMPLE 2
```
simple search with one filter/criteria
```

Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS\> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country

### EXEMPLE 3
```
AdvancedSearch with multiple criteria/filters and set the API key
```

Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
C:\PS\> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXEMPLE 4
```
simple search with one filter/criteria and request page 2 of the results
```

Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS\> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -page "2"

### EXEMPLE 5
```
simple search with one filter/criteria and use a server filter to retrieve only objects indexed since 2 month
```

Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS\> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction monthago -FilterValue "2"

### EXEMPLE 6
```
filter the result and show me only the answer with os property not null for threatlist category for all Russia
```

C:\PS\> Search-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction exist -FilterValue os

### EXEMPLE 7
```
filter the results using multiple filters (only os property known and from all organization like *company*) for tcp port 3389 opened in russia
```

C:\PS\> search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan

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

### -FilterFunction
{{Fill FilterFunction Description}}

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

### -SearchFilter
{{Fill SearchFilter Description}}

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
{{Fill SearchType Description}}

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName: System.Management.Automation.PSCustomObject
## NOTES

## RELATED LINKS
