---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Get-OnypheSummary

## SYNOPSIS
main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Summary API available

## SYNTAX

```
Get-OnypheSummary [[-SearchValue] <String>] [[-APIKey] <String>] [[-Page] <String[]>] [[-wait] <Int32>]
 [-SearchType <String>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Summary API available
send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

## EXAMPLES

### EXAMPLE 1
```
Request all information for ip 8.8.8.8 
C:\PS> Get-OnypheSummary -SearchValue "8.8.8.8" -SummaryAPIType ip
```

### EXAMPLE 2
```
Request all information for perdu.com domain and set the API key
C:\PS> Get-OnypheSummary -SearchValue "perdu.com" -SummaryAPIType domain -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### EXAMPLE 3
```
Request all information for www.perdu.com hostname  and see page 2 of results
C:\PS> Get-OnypheSummary -SearchValue "www.perdu.com" -SummaryAPIType hostname -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -page "2"
```

## PARAMETERS

### -SearchValue
{{ Fill SearchValue Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
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
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Page
-page string{page number}
go directly to a specific result page (1 to 1000)
you can set a list of page using x-y like 1-100 to read the first 100 pages

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
Aliases: SummaryAPIType

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
