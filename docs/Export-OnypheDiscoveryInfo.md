---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Export-OnypheDiscoveryInfo

## SYNOPSIS
main function/cmdlet - Export bulk OQL search results from onyphe.io web service using the Discovery API

## SYNTAX

```
Export-OnypheDiscoveryInfo [-FilePath] <String> [[-SaveInfoAsFile] <String>] [[-APIKey] <String>]
 [[-wait] <Int32>] [[-Size] <Int32>] [-ProgressAction <ActionPreference>] -Category <String>
 [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Export bulk OQL search results from onyphe.io web service using the Discovery API
the Discovery API runs one OQL query per line of the input file and sends back streamed json as result.
requires a Griffin View subscription on Onyphe - without one, -Category has no valid values and every
call will fail server-side.

## EXAMPLES

### EXAMPLE 1
```
export datascan discovery information into Json file using myqueries.txt as source OQL queries file
C:\PS> Export-OnypheDiscoveryInfo -FilePath .\myqueries.txt -SaveInfoAsFile .\results.json -Category datascan
```

### EXAMPLE 2
```
export resolver discovery information into object using myqueries.txt as source OQL queries file
C:\PS> Export-OnypheDiscoveryInfo -FilePath .\myqueries.txt -Category resolver
```

### EXAMPLE 3
```
export up to 10000 riskscan results per query line instead of Onyphe's silent 100-result default
C:\PS> Export-OnypheDiscoveryInfo -FilePath .\myqueries.txt -Category riskscan -Size 10000
```

## PARAMETERS

### -FilePath
-FilePath string
full path to file to be imported to the Discovery API, one OQL query per line (e.g.
"protocol:rdp domain:google.com").

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SaveInfoAsFile
-SaveInfoAsFile string
full path to file where json data will be exported.

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

### -APIKey
-APIKey string{APIKEY}
set your APIKEY to be able to use Onyphe API.

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

### -wait
-Wait int{second}
wait for x second before sending the request to manage rate limiting restriction

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Size
-Size int{1-10000}
number of results Onyphe should return for each OQL query line in -FilePath - Onyphe
defaults to 100 per query line when this is omitted, silently, with no error or warning
that the result set was truncated.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Category
{{ Fill Category Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: DiscoveryCategory

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName: System.Management.Automation.PSCustomObject
## NOTES

## RELATED LINKS
