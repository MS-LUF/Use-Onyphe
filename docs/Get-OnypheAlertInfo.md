---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Get-OnypheAlertInfo

## SYNOPSIS
main function/cmdlet - get existing alert on onyphe.io web service using alert APIs

## SYNTAX

```
Get-OnypheAlertInfo [-APIKey <String>] [-UseBetaFeatures] [-SearchFilter <String>] [-SearchValue <String>]
 [-SearchOperator <String>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - get all alert on onyphe.io web service using alert APIs and filter alert with query or mail criteria at client side
get content through HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

## EXAMPLES

### EXEMPLE 1
```
Get all existing alert using "jeanclaude.dusse@lesbronzesfontdusk.io"
```

C:\PS\> Get-OnypheAlert -SearchValue "jeanclaude.dusse@lesbronzesfontdusk.io" -SearchOperator eq -SearchFilter email

### EXEMPLE 2
```
Get all existing alert for your onyphe account
```

C:\PS\> Get-OnypheAlert

## PARAMETERS

### -APIKey
-APIKey string{APIKEY}
set your APIKEY to be able to use Onyphe API.

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

### -SearchFilter
-SearchFilter String {"query","name", "email", "id" - default value "name"} 
Selected field to be used for searching/filtering process at client side

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Name
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchValue
-SearchValue String
Value to be used as main filter could be a word or expression depending of chosen search operator

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

### -SearchOperator
-SearchOperator String {"eq","ne","like","notlike","match","notmatch" - default value "eq"}
Powershell Search operator to be used for filtering

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Eq
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
