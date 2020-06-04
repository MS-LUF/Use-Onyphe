---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheAddAlert

## SYNOPSIS
create several input for Invoke-OnypheAPIv2 function and then call it to add new alert for alert/add API

## SYNTAX

```
Invoke-APIOnypheAddAlert [[-AlertName] <String>] [[-AlertEmail] <String>] [[-SearchType] <String>]
 [[-SearchValue] <String>] [[-SearchFilter] <String>] [[-FilterFunction] <String>] [[-FilterValue] <String[]>]
 [[-AdvancedSearch] <Array>] [[-APIKey] <String>] [-UseBetaFeatures] [[-AdvancedFilter] <Array>]
 [[-InputOnypheObject] <Object>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIv2 function and then call it to add new alert for alert/add API

## EXAMPLES

### EXAMPLE 1
```
New alert based on AdvancedSearch with multiple criteria/filters
Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
C:\PS> Invoke-APIOnypheAddAlert -AlertEmail "alert@example.com" -AlertName "My new Alert" -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan
```

### EXAMPLE 2
```
New alert based on simple search with one filter/criteria
Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS> Invoke-APIOnypheAddAlert -AlertEmail "alert@example.com" -AlertName "My new Alert" -SearchValue RU -SearchType threatlist -SearchFilter country
```

## PARAMETERS

### -AlertName
-AlertName string
 Name of the new Onpyhe Alert

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertEmail
-AlertEmail string
 Target mail receiving Onyphe Alert

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

### -SearchType
{{ Fill SearchType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: Category

Required: False
Position: 3
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
Position: 4
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
Position: 5
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
Position: 6
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
Position: 7
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
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -APIKey
-APIKey string{APIKEY}
 Set APIKEY as global variable.

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
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputOnypheObject
{{ Fill InputOnypheObject Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName : System.Management.Automation.PSCustomObject
## NOTES

## RELATED LINKS
