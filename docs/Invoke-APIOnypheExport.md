---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheExport

## SYNOPSIS
create several input for Invoke-OnypheAPIV2 function and then call it to export search info from export API

## SYNTAX

```
Invoke-APIOnypheExport [-SearchType] <String> [[-SearchValue] <String>] [[-SearchFilter] <String>]
 [[-FilterFunction] <String>] [[-FilterValue] <String[]>] [[-AdvancedSearch] <Array>] [[-APIKey] <String>]
 [[-wait] <Int32>] [-UseBetaFeatures] [[-AdvancedFilter] <Array>] [[-FuncInput] <Hashtable>]
 [-OutFile] <String> [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIV2 function and then call it to export search info from export API

## EXAMPLES

### EXAMPLE 1
```
AdvancedSearch export with multiple criteria/filters
export search data with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
C:\PS> Invoke-APIOnypheSearch -AdvancedSearch @("product:Apache","port:443","os:Windows") -category datascan
```

### EXAMPLE 2
```
simple export with one filter/criteria
export search data with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS> Invoke-APIOnypheSearch -SearchValue RU -Category threatlist -SearchFilter country
```

## PARAMETERS

### -SearchType
{{ Fill SearchType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Category

Required: True
Position: 1
Default value: None
Accept pipeline input: False
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchFilter
-SearchFilter STRING{Get-OnypheSearchFilters}
Filter to be used with string set with SearchValue parameter

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

### -FilterFunction
-FilterFunction String{Get-OnypheSearchFunctions}
Filter search function

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
Position: 5
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
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -APIKey
-APIKey string{APIKEY}
Set APIKEY as global variable

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -wait
{{ Fill wait Description }}

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
Position: Named
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
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FuncInput
{{ Fill FuncInput Description }}

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutFile
-OutFile string{full path to a new file for exporting json data}
full path to output file used to write json data from Onyphe

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName: PSOnyphe
## NOTES

## RELATED LINKS
