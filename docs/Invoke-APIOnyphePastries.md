---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnyphePastries

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to get the pastries (pastebin) info from pastries API

## SYNTAX

```
Invoke-APIOnyphePastries [-IP] <String[]> [[-APIKey] <String>] [[-Page] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to get the pastries (pastebin) info from pastries API

## EXAMPLES

### EXAMPLE 1
```
get all pastries info for IP 8.8.8.8
```

C:\PS\> Invoke-APIOnyphePastries -IP 8.8.8.8

### EXAMPLE 2
```
get all pastries info for IP 8.8.8.8 and set the api key
```

C:\PS\> Invoke-APIOnyphePastries -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## PARAMETERS

### -IP
-IP string{IP}
IP to be used for the pastries API usage

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
### count            : 100
### error            : 0
### myip             : 192.168.6.66
### results          : {@{@category=pastries; @timestamp=2018-01-14T06:24:45.000Z; @type=pastebin; domain=System.Object[]
### 	hostname=System.Object[]; ip=System.Object[]; key=4AVhGheK; seen_date=2018-01-14},
### 	@{@category=pastries; @timestamp=2018-01-14T06:24:08.000Z; @type=pastebin; domain=System.Object[];
### 	hostname=System.Object[]; ip=System.Object[]; key=g6Tm4CaF; seen_date=2018-01-14},
### 	@{@category=pastries; @timestamp=2018-01-14T01:51:29.000Z; @type=pastebin; domain=System.Object[];
### 	hostname=System.Object[]; ip=System.Object[]; key=qB6HvymP; seen_date=2018-01-14},
### 	@{@category=pastries; @timestamp=2018-01-14T00:57:35.000Z; @type=pastebin; domain=System.Object[];
### 	hostname=System.Object[]; ip=System.Object[]; key=138rguxt; seen_date=2018-01-14}...}
### status           : ok
### took             : 0.086
### total            : 3043
### cli-API_info     : {patries}
### cli-API_input    : {8.8.8.8}
### cli-key_required : {True}
### cli-Request_Date : 14/01/2018 20:45:08
## NOTES

## RELATED LINKS
