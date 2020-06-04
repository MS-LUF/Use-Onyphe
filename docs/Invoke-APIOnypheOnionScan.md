---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheOnionScan

## SYNOPSIS
create several input for Invoke-OnypheAPIV2 function and then call it to get info for a .onion link using OnionScan API

## SYNTAX

```
Invoke-APIOnypheOnionScan [-Onion] <String[]> [[-APIKey] <String>] [[-Page] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIV2 function and then call it to get info for a .onion link using OnionScan API

## EXAMPLES

### EXAMPLE 1
```
get md5 info for 3g2upl4pq6kufc4m.onion URL
C:\PS> Invoke-APIOnypheOnionScan -Onion "3g2upl4pq6kufc4m.onion"
```

### EXAMPLE 2
```
get md5 info for 3g2upl4pq6kufc4m.onion URL and set the api key
C:\PS> Invoke-APIOnypheOnionScan -Onion "3g2upl4pq6kufc4m.onion" -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## PARAMETERS

### -Onion
-Onion string{Onion URL}
Onion link to be used for the Onion API usage

```yaml
Type: String[]
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
