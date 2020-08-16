---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIBulkSummaryOnypheDomain

## SYNOPSIS
create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an array of domains based on a file input from Bulk/domain API

## SYNTAX

```
Invoke-APIBulkSummaryOnypheDomain [-FilePath] <String> [-OutFile] <String> [[-APIKey] <String>]
 [[-FuncInput] <Hashtable>] [<CommonParameters>]
```

## DESCRIPTION
reate several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an array of domains based on a file input from Bulk/domain API

## EXAMPLES

### EXAMPLE 1
```
export all info available as JSON for all domains contained in listdom.txt
C:\PS> Invoke-APIBulkSummaryOnypheDomain -FilePath .\listdom.txt
```

### EXAMPLE 2
```
export all info available as JSON for all domains contained in listdom.txt and set the API Key
C:\PS> Invoke-APIBulkSummaryOnypheDomain -FilePath .\listdom.txt -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## PARAMETERS

### -FilePath
-FilePath string{full path to an existing text file}
full path to input file to send to onyphe API

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

### -OutFile
-OutFile string{full path to a new file for exporting json data}
full path to output file used to write json data from Onyphe

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

### -APIKey
-APIKey string{APIKEY}
Set APIKEY as global variable.

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
