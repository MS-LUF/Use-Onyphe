---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheSearch

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to search info from search APIs

## SYNTAX

```
Invoke-APIOnypheSearch [[-SimpleSearchValue] <String>] [[-AdvancedSearch] <Array>] [-APIKey <String[]>]
 [-Page <String[]>] -SearchType <String> [-SimpleSearchFilter <String>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to to search info from search APIs

## EXAMPLES

### EXAMPLE 1
```
AdvancedSearch with multiple criteria/filters
```

Search with datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows
C:\PS\> Invoke-APIOnypheSearch -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan

### EXAMPLE 2
```
simple search with one filter/criteria
```

Search with threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
C:\PS\> Invoke-APIOnypheSearch -SimpleSearchValue RU -SearchType threatlist -SimpleSearchFilter country

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
Set APIKEY as global variable

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

### TypeName : System.Management.Automation.PSCustomObject
### Name             MemberType   Definition
### ----             ----------   ----------
### Equals           Method       bool Equals(System.Object obj)
### GetHashCode      Method       int GetHashCode()
### GetType          Method       type GetType()
### ToString         Method       string ToString()
### cli-API_info     NoteProperty string[] cli-API_info=System.String[]
### cli-API_input    NoteProperty string[] cli-API_input=System.String[]
### cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
### cli-Request_Date NoteProperty datetime cli-Request_Date=15/08/2018 15:05:25
### count            NoteProperty int count=10
### error            NoteProperty int error=0
### max_page         NoteProperty decimal max_page=1000,0
### myip             NoteProperty string myip=90.92.236.55
### page             NoteProperty int page=1000
### results          NoteProperty Object[] results=System.Object[]
### status           NoteProperty string status=ok
### took             NoteProperty string took=0.066
### total            NoteProperty int total=157611
### count            : 10
### error            : 0
### max_page         : 1000,0
### myip             : 90.92.234.60
### page             : 1000
### results          : {@{@category=inetnum; @timestamp=2018-08-12T01:35:21.000Z; @type=ip; asn=AS16276; country=GB;
### 	information=System.Object[]; ipv6=false; location=51.4964,-0.1224; netname=reduk2; organization=OVH
### 	SAS; seen_date=2018-08-12; source=RIPE; subnet=213.32.105.0/26}, @{@category=inetnum;
### 	@timestamp=2018-08-12T01:35:21.000Z; @type=ip; asn=AS16276; country=FR;
### 	information=System.Object[]; ipv6=false; location=48.8582,2.3387; netname=OVH_121297930;
### 	organization=OVH SAS; seen_date=2018-08-12; source=RIPE; subnet=149.202.133.104/30},
### 	@{@category=inetnum; @timestamp=2018-08-12T01:35:21.000Z; @type=ip; asn=AS16276; country=FR;
### 	information=System.Object[]; ipv6=false; location=48.8582,2.3387; netname=OVH_121298047;
### 	organization=OVH SAS; seen_date=2018-08-12; source=RIPE; subnet=149.202.133.108/30},
### 	@{@category=inetnum; @timestamp=2018-08-12T01:35:21.000Z; @type=ip; asn=AS16276; country=FR;
### 	information=System.Object[]; ipv6=false; location=48.8582,2.3387; netname=OVH_121298490;
### 	organization=OVH SAS; seen_date=2018-08-12; source=RIPE; subnet=51.254.51.84/30}...}
### status           : ok
### took             : 0.066
### total            : 157611
### cli-API_info     : {search/inetnum}
### cli-API_input    : {organization:"OVH SAS"}
### cli-key_required : {True}
### cli-Request_Date : 15/08/2018 15:05:25
## NOTES

## RELATED LINKS
