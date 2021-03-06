---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APISummaryOnypheDomain

## SYNOPSIS
create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an internet domain from Geoloc Summary/domain API

## SYNTAX

```
Invoke-APISummaryOnypheDomain [-Domain] <String> [[-APIKey] <String>] [[-Page] <String>]
 [[-FuncInput] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an internet domain from Geoloc Summary/domain API

## EXAMPLES

### EXAMPLE 1
```
get all onyphe info for domain perdu.com
C:\PS> Invoke-APISummaryOnypheDomain -Domain perdu.com
```

### EXAMPLE 2
```
get all onyphe info for domain perdu.com and set the API Key
C:\PS> Invoke-APISummaryOnypheDomain -Domain perdu.com -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## PARAMETERS

### -Domain
-Domain string{Domain}
Domain to be used for the Summary/domain API API usage

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
