---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Export-OnypheInfo

## SYNOPSIS
main function/cmdlet - Export Search information on onyphe.io web service using search export API

## SYNTAX

```
Export-OnypheInfo [[-InputOnypheObject] <Array>] [[-SearchValue] <String>] [[-FilterValue] <String[]>]
 [[-AdvancedSearch] <Array>] [[-APIKey] <String>] [[-wait] <Int32>] [-UseBetaFeatures]
 [[-AdvancedFilter] <Array>] [-SaveInfoAsFile] <String> [-SearchType <String>] [-SearchFilter <String>]
 [-FilterFunction <String>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Export Search information on onyphe.io web service using search export API
send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

## EXAMPLES

### EXAMPLE 1
```
AdvancedSearch with multiple criteria/filters
Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows and export data to myexport.json
C:\PS> Export-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan -SaveInfoAsFile .\myexport.json
```

### EXAMPLE 2
```
simple search with one filter/criteria
Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists and export data to myexport.json
C:\PS> Export-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -SaveInfoAsFile .\myexport.json
```

### EXAMPLE 3
```
AdvancedSearch with multiple criteria/filters and set the API key
Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows and export data to myexport.json
C:\PS> Export-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -Category datascan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -SaveInfoAsFile .\myexport.json
```

### EXAMPLE 4
```
simple search with one filter/criteria and use a server filter to retrieve only objects indexed since 2 month
Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists and export data to myexport.json
C:\PS> Export-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction monthago -FilterValue "2" -SaveInfoAsFile .\myexport.json
```

### EXAMPLE 5
```
filter the result and show me only the answer with os property not null for threatlist category for all Russia  and export data to myexport.json
C:\PS> Export-OnypheInfo -SearchValue RU -Category threatlist -SearchFilter country -FilterFunction exist -FilterValue os -SaveInfoAsFile .\myexport.json
```

### EXAMPLE 6
```
filter the results using multiple filters (only os property known and from all organization like *company*) for tcp port 3389 opened in russia  and export data to myexport.json
C:\PS> Export-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan -SaveInfoAsFile .\myexport.json
```

### EXAMPLE 7
```
search from onyphe using search-onyphe and pipe the object to export the content to a json file using export-onyphe
C:\PS> Search-onyphe -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -Category datascan | Export-onyphe -SaveInfoAsFile .\myexport.json
```

## PARAMETERS

### -InputOnypheObject
-InputOnypheObject PSOnyphe object
used a PSOnyphe object generated with Search-Onyphe as input

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: 13
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

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
Accept pipeline input: False
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
Position: 10
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
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SaveInfoAsFile
-SaveInfoAsFile string
full path to file where json data will be exported.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 12
Default value: None
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

Required: False
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
