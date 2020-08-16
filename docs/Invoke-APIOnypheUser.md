---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheUser

## SYNOPSIS
create several input for Invoke-OnypheAPIV2 function and then call it to get the user account info from user API

## SYNTAX

```
Invoke-APIOnypheUser [[-APIKey] <String>] [-UseBetaFeatures] [[-FuncInput] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIV2 function and then call it to get the user account info from user API

## EXAMPLES

### EXAMPLE 1
```
get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx and set the api key
C:\PS> Invoke-APIOnypheUser -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### EXAMPLE 2
```
get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx already set as global variable
C:\PS> Invoke-APIOnypheUser
```

## PARAMETERS

### -APIKey
-APIKey string{APIKEY}
Set APIKEY as global variable.

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

### -FuncInput
{{ Fill FuncInput Description }}

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
