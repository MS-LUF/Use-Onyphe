---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheDatascanDataMD5

## SYNOPSIS
create several input for Invoke-OnypheAPIV2 function and then call it to get info from onyphe md5 signature

## SYNTAX

```
Invoke-APIOnypheDatascanDataMD5 [-MD5] <String[]> [[-APIKey] <String>] [[-Page] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIV2 function and then call it to get info from onyphe md5 signature

## EXAMPLES

### EXAMPLE 1
```
get md5 info for 7a1f20cae067b75a52bc024b83ee4667 hash
C:\PS> Invoke-APIOnypheDatascanDataMd5 -MD5 7a1f20cae067b75a52bc024b83ee4667
```

### EXAMPLE 2
```
get md5 info for 7a1f20cae067b75a52bc024b83ee4667 hash and set the api key
C:\PS> Invoke-APIOnypheDatascanDataMd5 -MD5 7a1f20cae067b75a52bc024b83ee4667 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

## PARAMETERS

### -MD5
-MD5 string{MD5 Hash}
MD5 to be used for the md5 API usage

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
