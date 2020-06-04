---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheDataScan

## SYNOPSIS
create several input for Invoke-OnypheAPIV2 function and then call it to get the data scan info from datascan API

## SYNTAX

```
Invoke-APIOnypheDataScan [-IPOrDataScanString] <String[]> [[-APIKey] <String>] [[-Page] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIV2 function and then call it to get the data scan info from datascan API

## EXAMPLES

### EXAMPLE 1
```
get all data scan info for IP 27.251.29.154
C:\PS> Invoke-APIOnypheDataScan -IPOrDataScanString 27.251.29.154
```

### EXAMPLE 2
```
get all info for info available for PanWeb web server
C:\PS> Invoke-APIOnypheDataScan -IPOrDataScanString "PanWeb"
```

### EXAMPLE 3
```
get all data scan info for IP 27.251.29.154 and set the api key
C:\PS> Invoke-APIOnypheDataScan -IPOrDataScanString 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## PARAMETERS

### -IPOrDataScanString
-IPOrDataScanString string{IP}
IP to be used for the DataScan API usage
-IPOrDataScanString string
string to be used for the DataScan API usage

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
