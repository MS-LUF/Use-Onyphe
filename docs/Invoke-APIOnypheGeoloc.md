---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheGeoloc

## SYNOPSIS
create several input for Invoke-OnypheAPIV2 function and then call it to get the Geoloc info from Geoloc API

## SYNTAX

```
Invoke-APIOnypheGeoloc [-IP] <String> [[-APIKey] <String>] [[-Page] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIV2 function and then call it to get the Geoloc info from Geoloc API

## EXAMPLES

### EXAMPLE 1
```
get geoloc info for IP 8.8.8.8
C:\PS> Invoke-APIOnypheGeoloc -IP 8.8.8.8
```

## PARAMETERS

### -IP
-IP string{IP}
IP to be used for the geoloc API usage

```yaml
Type: String
Parameter Sets: (All)
Aliases: input

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -APIKey
{{ Fill APIKey Description }}

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

### -Page
{{ Fill Page Description }}

```yaml
Type: String[]
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

### TypeName : System.Management.Automation.PSCustomObject
## NOTES

## RELATED LINKS
