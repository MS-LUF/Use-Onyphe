---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheInetnum

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to get the inetnum info from inetnum API

## SYNTAX

```
Invoke-APIOnypheInetnum [-IP] <String[]> [[-APIKey] <String>] [[-Page] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to get the inetnum info from inetnum API

## EXAMPLES

### EXAMPLE 1
```
get inetnum info for subnet 93.184.208.0
```

C:\PS\> Invoke-APIOnypheInetnum -IP 93.184.208.0

### EXAMPLE 2
```
get inetnum info for subnet 93.184.208.0 and set the api key
```

C:\PS\> Invoke-APIOnypheInetnum -IP 93.184.208.0 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## PARAMETERS

### -IP
-IP string{IP}
IP to be used for the geoloc API usage

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
### cli-Request_Date NoteProperty datetime cli-Request_Date=14/01/2018 20:47:39
### count            NoteProperty int count=1
### error            NoteProperty int error=0
### myip             NoteProperty string myip=192.168.6.66
### results          NoteProperty Object[] results=System.Object[]
### status           NoteProperty string status=ok
### took             NoteProperty string took=0.001305
### total            NoteProperty int total=1
### count            : 28
### error            : 0
### myip             : 192.168.6.66
### results          : {@{@category=inetnum; @timestamp=2018-01-14T02:37:32.000Z; @type=ip; country=US; ipv6=false;
### 	netname=EU-EDGECASTEU-20080602; seen_date=2018-01-14; source=RIPE; subnet=93.184.208.0/20},
### 	@{@category=inetnum; @timestamp=2018-01-14T02:37:32.000Z; @type=ip; country=EU;
### 	information=System.Object[]; ipv6=false; netname=EDGECAST-NETBLK-03; seen_date=2018-01-14;
### 	source=RIPE; subnet=93.184.208.0/24}, @{@category=inetnum; @timestamp=2018-01-07T02:37:24.000Z;
### 	@type=ip; country=US; ipv6=false; netname=EU-EDGECASTEU-20080602; seen_date=2018-01-07;
### 	source=RIPE; subnet=93.184.208.0/20}, @{@category=inetnum; @timestamp=2018-01-07T02:37:24.000Z;
### 	@type=ip; country=EU; information=System.Object[]; ipv6=false; netname=EDGECAST-NETBLK-03;
### 	seen_date=2018-01-07; source=RIPE; subnet=93.184.208.0/24}...}
### status           : ok
### took             : 1.314
### total            : 28
### cli-API_info     : {inetnum}
### cli-API_input    : {93.184.208.0}
### cli-key_required : {True}
### cli-Request_Date : 14/01/2018 20:45:08
## NOTES

## RELATED LINKS
