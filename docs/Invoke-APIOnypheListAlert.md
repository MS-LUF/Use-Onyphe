---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheListAlert

## SYNOPSIS
create several input for Invoke-OnypheAPIv2 function and then call it to list alert already set from alert/list API

## SYNTAX

```
Invoke-APIOnypheListAlert [[-APIKey] <String>] [-UseBetaFeatures] [[-FuncInput] <Hashtable>]
 [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIv2 function and then call it to list alert already set from alert/list API

## EXAMPLES

### EXAMPLE 1
```
get alert set and set api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
C:\PS> Invoke-APIOnypheListAlert -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### EXAMPLE 2
```
get alert set
C:\PS> Invoke-APIOnypheListAlert
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
