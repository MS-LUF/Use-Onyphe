---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Export-OnypheBulkInfo

## SYNOPSIS
main function/cmdlet - Export Search information on onyphe.io web service using bulk APIs

## SYNTAX

```
Export-OnypheBulkInfo [-FilePath] <String> [-SaveInfoAsFile] <String> [[-APIKey] <String>] [[-wait] <Int32>]
 -SearchType <String> [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Export Search information on onyphe.io web service using bulk APIs
bulk APIs use input file containing ip, domain or hostname and sends back streamed json as result.

## EXAMPLES

### EXAMPLE 1
```
export search for IP information into Json file using myfile.txt as source IPs file
C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType ip
```

### EXAMPLE 2
```
export search for domain information into Json file using myfile.txt as source domains file
C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType domain
```

### EXAMPLE 3
```
export search for hostname information into Json file using myfileip.txt as source hostnames file
C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType hostname
```

## PARAMETERS

### -FilePath
-FilePath string
full path to file to be imported to the bulk API.

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

Required: True
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

### -SearchType
{{ Fill SearchType Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases: BulkAPIType

Required: True
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
