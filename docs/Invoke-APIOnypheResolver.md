---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheResolver

## SYNOPSIS
create several input for Invoke-OnypheAPIV2 function and then call it to get the resolver dns info from resolver API

## SYNTAX

```
Invoke-APIOnypheResolver [-IP] <String> [[-APIKey] <String>] [[-Page] <String>] [[-FuncInput] <Hashtable>]
 [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIV2 function and then call it to get the resolver dns info from resolver API

## EXAMPLES

### EXAMPLE 1
```
get dns info info for IP 8.8.8.8
C:\PS> Invoke-APIOnypheResolver -IP 8.8.8.8
```

### EXAMPLE 2
```
get dns info info for IP 8.8.8.8 ans set the api key
C:\PS> Invoke-APIOnypheResolver -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## PARAMETERS

### -IP
-IP string{IP}
IP to be used for the resolver API usage

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
-APIKey string{APIKEY}
Set APIKEY as global variable.

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
-page string{page number}
go directly to a specific result page (1 to 1000)

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

### -FuncInput
{{ Fill FuncInput Description }}

```yaml
Type: Hashtable
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
