---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Get-OnypheInfo

## SYNOPSIS
main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Simple API available

## SYNTAX

```
Get-OnypheInfo [[-SearchValue] <String>] [-Best] [[-APIKey] <String>] [[-Page] <String[]>] [[-wait] <Int32>]
 [-SearchType <String>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Simple API available
send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

## EXAMPLES

### EXEMPLE 1
```
Request geoloc information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -Category Geoloc

### EXEMPLE 2
```
Request dns reverse information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -Category ResolverReverse -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXEMPLE 3
```
request IIS keyword datascan information
```

C:\PS\> Get-OnypheInfo -Category DataScan -SearchValue "IIS" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXEMPLE 4
```
request datascan information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -Category DataScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXEMPLE 5
```
Request pastebin content information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -Category Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXEMPLE 6
```
Request pastebin content information for ip 8.8.8.8 and see page 2 of results
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -Category Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -page "2"

### EXEMPLE 7
```
Request dns forward information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -Category ResolverForward -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXEMPLE 8
```
Request threatlist information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -Category Threatlist -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXEMPLE 9
```
Request inetnum information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -Category Inetnum -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXEMPLE 10
```
Request synscan information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -Category SynScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## PARAMETERS

### -SearchValue
-SearchValue string -Category Inetnum -APIKey string{APIKEY}
look for an ip address in onyphe database
-SearchValue string -Category Threatlist -APIKey string{APIKEY}
look for threat info about a specific IP in onyphe database.
-SearchValue string -Category Pastries -APIKey string{APIKEY}
look for an pastbin data about a specific IP in onyphe database.
-SearchValue string -Category Synscan -APIKey string{APIKEY}

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

### -Best
-best
enable best mode when supported by simple API

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
{{Fill SearchType Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: SimpleAPIType, Category

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName: System.Management.Automation.PSCustomObject
## NOTES

## RELATED LINKS
