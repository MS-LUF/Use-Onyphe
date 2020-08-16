---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheDelAlert

## SYNOPSIS
create several input for Invoke-OnypheAPIv2 function and then call it to delete an alert already create using alert/del API

## SYNTAX

```
Invoke-APIOnypheDelAlert [[-APIKey] <String>] [-UseBetaFeatures] [-AlertID] <String> [[-FuncInput] <Hashtable>]
 [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIv2 function and then call it to delete an alert already create using alert/del API

## EXAMPLES

### EXAMPLE 1
```
Delete Onyphe Alert with ID 0 and set api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
C:\PS> Invoke-APIOnypheDelAlert -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -AlertID 0
```

### EXAMPLE 2
```
Delete Onyphe Alert with ID 0
C:\PS> Invoke-APIOnypheDelAlert -AlertID 0
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

### -AlertID
-AlertID string{ID}
 mandatory input containing the ID of the alert to be deleted

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
Position: 3
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
