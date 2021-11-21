---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Set-OnypheAlertInfo

## SYNOPSIS
main function/cmdlet - create, modify, delete an alert on onyphe.io web service using alert APIs

## SYNTAX

```
Set-OnypheAlertInfo [[-SearchValue] <String>] [[-FilterValue] <String[]>] [[-AdvancedSearch] <Array>]
 [-AlertAction] <String> [[-AlertMail] <String>] [-AlertName] <String> [[-APIKey] <String>] [-UseBetaFeatures]
 [[-AdvancedFilter] <Array>] [-InputOnypheObject <Array>] [-SearchType <String>] [-SearchFilter <String>]
 [-FilterFunction <String>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - create, modify, delete an alert on onyphe.io web service using alert APIs
post JSON content through HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

## EXAMPLES

### EXEMPLE 1
```
New alert for AdvancedSearch with multiple criteria/filters
```

Set a new alert named "windows apache" matching datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows, and sent back the alert on "jeanclaude.dusse@lesbronzesfontdusk.io"
C:\PS\> Set-OnypheAlert -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan -AlertAction new -AlertName "windows apache" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"

### EXEMPLE 2
```
New alert for simple search with one filter/criteria
```

Set a new alert named "from russia with lv" matching threatlist for all IP matching the criteria : all IP from russia tagged by threat lists, and sent back the alert on "jeanclaude.dusse@lesbronzesfontdusk.io"
C:\PS\> Set-OnypheAlert -SearchValue RU -SearchType threatlist -SearchFilter country -AlertAction new -AlertName "from russia with lv" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"

### EXEMPLE 3
```
New alert for simple search with one filter/criteria and use a server filter to retrieve only objects indexed since 2 month,
```

Set an new alert named "from russia with lv 2 m" matching threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS\> Set-OnypheAlert -SearchValue RU -SearchType threatlist -SearchFilter country -FilterFunction monthago -FilterValue "2" -AlertAction new -AlertName "from russia with lv 2 m" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"

### EXEMPLE 4
```
Modify an existing alert named "from paris with lv" and update mail and query
```

Modify an existing alert named "from paris with lv" an update it to match threatlist for all IP matching the criteria : all IP from russia tagged by threat lists and filter the result and show me only the answer with os property not null, finally sent back the alert to new mail "robert.lespinasse@lesbronzesfontdusk.io"
C:\PS\> Set-OnypheAlert -SearchValue FR -SearchType threatlist -SearchFilter country -FilterFunction exist -FilterValue os -AlertAction modify -AlertName "from paris with lv" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"

### EXEMPLE 5
```
New alert for advanced search and filter
```

Set a new alert named "RandR" matching datascan for all IP matching the criteria : all ip from RU with TCP 3389 port opened, filter the results using multiple filters (only os property known and from all organization like *company*), and finally sent back the alert to "robert.lespinasse@lesbronzesfontdusk.io"
C:\PS\> Set-OnypheAlert -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"

### EXEMPLE 6
```
Delete an existing alert named "windows apache"
```

C:\PS\> Set-OnypheAlert -AlertAction delete -AlertName "windows apache"

## PARAMETERS

### -SearchValue
-SearchValue STRING{value}
string to be searched with -SearchFilter parameter

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
Position: 9
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
Position: 10
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertAction
-AlertAction String {"new","delete","modify" - default value "new"} 
Mandatory parameter used to select what kind of action is requested : creation, deletion, modification of an alert

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: New
Accept pipeline input: False
Accept wildcard characters: False
```

### -AlertMail
-AlertMail String
Mail address used to send you back the alert when a new event is matching your query

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

### -AlertName
-AlertName String
Name of the alert.
Only alphanumeric and space characters allowed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
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
Position: 12
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
Position: 13
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

### -InputOnypheObject
{{Fill InputOnypheObject Description}}

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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

Required: False
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
