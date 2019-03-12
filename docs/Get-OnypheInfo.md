---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Get-OnypheInfo

## SYNOPSIS
main function/cmdlet - Get IP information from onyphe.io web service using dedicated subfunctions by searchtype

## SYNTAX

```
Get-OnypheInfo [[-SearchValue] <String[]>] [-MyIP] [[-APIKey] <String[]>] [[-Page] <String[]>]
 [[-wait] <Int32>] [-SearchType <String>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Get IP information from onyphe.io web service using dedicated subfunctions by searchtype
send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

## EXAMPLES

### EXAMPLE 1
```
Request all information available for ip 192.168.1.5
```

C:\PS\> Get-OnypheInfo -searchtype ip -SearchValue "192.168.1.5" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 2
```
Looking for my public ip address
```

C:\PS\> Get-OnypheInfo -myip

### EXAMPLE 3
```
Request geoloc information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Geoloc

### EXAMPLE 4
```
Request dns reverse information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Reverse -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 5
```
request IIS keyword datascan information
```

C:\PS\> Get-OnypheInfo -searchtype DataScan -SearchValue "IIS" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 6
```
request datascan information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype DataScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 7
```
Request pastebin content information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 8
```
Request pastebin content information for ip 8.8.8.8 and see page 2 of results
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -page "2"

### EXAMPLE 9
```
Request dns forward information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Forward -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 10
```
Request threatlist information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Threatlist -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 11
```
Request inetnum information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype Inetnum -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 12
```
Request synscan information for ip 8.8.8.8
```

C:\PS\> Get-OnypheInfo -SearchValue "8.8.8.8" -searchtype SynScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## PARAMETERS

### -SearchValue
{{Fill SearchValue Description}}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -MyIP
-Myip
look for information about my public IP

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
Type: String[]
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
Aliases:

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
### count            : 32
### error            : 0
### myip             : 192.168.6.66
### results          : {@{@category=geoloc; @timestamp=2017-12-20T13:43:12.000Z; @type=ip; asn=AS15169; city=; country=US;
### 				   country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
### 				   longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}, @{@category=inetnum;
### 				   @timestamp=1970-01-01T00:00:00.000Z; @type=ip; country=US; information=System.Object[];
### 				   netname=Undisclosed; seen_date=1970-01-01; source=Undisclosed; subnet=Undisclosed},
### 				   @{@category=pastries; @timestamp=2017-12-20T12:21:40.000Z; @type=pastebin; domain=System.Object[];
### 				   hostname=System.Object[]; ip=System.Object[]; key=cnRxq9LP; seen_date=2017-12-20},
### 				   @{@category=pastries; @timestamp=2017-12-20T09:35:16.000Z; @type=pastebin; domain=System.Object[];
### 				   hostname=System.Object[]; ip=System.Object[]; key=AjfnLBLE; seen_date=2017-12-20}...}
### status           : ok
### took             : 0.107
### total            : 3556
### cli-API_info     : ip
### cli-API_input    : {8.8.8.8}
### cli-key_required : True
### cli-Request_Date : 14/01/2018 20:45:08
## NOTES

## RELATED LINKS
