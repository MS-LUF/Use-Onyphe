---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Search-OnypheInfo

## SYNOPSIS
main function/cmdlet - Search for IP information on onyphe.io web service using search API

## SYNTAX

```
Search-OnypheInfo [[-SimpleSearchValue] <String>] [[-AdvancedSearch] <Array>] [-APIKey <String[]>]
 [-Page <String[]>] [-wait <Int32>] -SearchType <String> [-SimpleSearchFilter <String>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Search for IP information on onyphe.io web service using search API
send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

## EXAMPLES

### EXAMPLE 1
```
AdvancedSearch with multiple criteria/filters
```

Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
C:\PS\> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan

### EXAMPLE 2
```
simple search with one filter/criteria
```

Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS\> Search-OnypheInfo -SimpleSearchValue RU -SearchType threatlist -SimpleSearchFilter country

### EXAMPLE 3
```
AdvancedSearch with multiple criteria/filters and set the API key
```

Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
C:\PS\> Search-OnypheInfo -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 4
```
simple search with one filter/criteria and request page 2 of the results
```

Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS\> Search-OnypheInfo -SimpleSearchValue RU -SearchType threatlist -SimpleSearchFilter country -page "2"

## PARAMETERS

### -SimpleSearchValue
-SimpleSearchValue STRING{value}
string to be searched with -SimpleSearchFilter parameter

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -AdvancedSearch
-AdvancedSearch ARRAY{filter:value,filter:value}
Search with multiple criterias

```yaml
Type: Array
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
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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
Position: Named
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
Position: Named
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

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SimpleSearchFilter
{{Fill SimpleSearchFilter Description}}

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName: System.Management.Automation.PSCustomObject
### count            : 32
### error            : 0
### myip             : 90.245.80.180
### results          : {@{@category=geoloc; @timestamp=2017-12-20T13:43:12.000Z; @type=ip; asn=AS15169; city=; country=US;
### 				country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
### 				longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}, @{@category=inetnum;
### 				@timestamp=1970-01-01T00:00:00.000Z; @type=ip; country=US; information=System.Object[];
### 				netname=Undisclosed; seen_date=1970-01-01; source=Undisclosed; subnet=Undisclosed},
### 				@{@category=pastries; @timestamp=2017-12-20T12:21:40.000Z; @type=pastebin; domain=System.Object[];
### 				hostname=System.Object[]; ip=System.Object[]; key=cnRxq9LP; seen_date=2017-12-20},
### 				@{@category=pastries; @timestamp=2017-12-20T09:35:16.000Z; @type=pastebin; domain=System.Object[];
### 				hostname=System.Object[]; ip=System.Object[]; key=AjfnLBLE; seen_date=2017-12-20}...}
### status           : ok
### took             : 0.107
### total            : 3556
### cli-API_info     : ip
### cli-API_input    : {8.8.8.8}
### cli-key_required : True
### cli-Request_Date : 14/01/2018 20:45:08
## NOTES

## RELATED LINKS
