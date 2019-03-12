---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheSynScan

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to get the syn scan info from synscan API

## SYNTAX

```
Invoke-APIOnypheSynScan [-IP] <String[]> [[-APIKey] <String[]>] [[-Page] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to get the syn scan info from synscan API

## EXAMPLES

### EXAMPLE 1
```
get syn scan info for IP 8.8.8.8
```

C:\PS\> Invoke-APIOnypheSynScan -IP 8.8.8.8

### EXAMPLE 2
```
get syn scan info for IP 8.8.8.8 and set the api key
```

C:\PS\> Invoke-APIOnypheSynScan -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## PARAMETERS

### -IP
-IP string{IP}
IP to be used for the geoloc API usage

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

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
### count            : 76
### error            : 0
### myip             : 192.168.6.6
### results          : {@{@category=synscan; @timestamp=2017-11-26T23:47:45.000Z; @type=port-53; asn=AS15169; country=US;
### 	ip=8.8.8.8; location=37.7510,-97.8220; organization=Google LLC; os=Linux; port=53;
### 	seen_date=2017-11-26}, @{@category=synscan; @timestamp=2017-11-26T22:47:46.000Z; @type=port-53;
### 	asn=AS15169; country=US; ip=8.8.8.8; location=37.7510,-97.8220; organization=Google LLC; os=Linux;
### 	port=53; seen_date=2017-11-26}, @{@category=synscan; @timestamp=2017-11-26T22:47:42.000Z;
### 	@type=port-53; asn=AS15169; country=US; ip=8.8.8.8; location=37.7510,-97.8220; organization=Google
### 	LLC; os=Linux; port=53; seen_date=2017-11-26}, @{@category=synscan;
### 	@timestamp=2017-11-26T22:47:31.000Z; @type=port-53; asn=AS15169; country=US; ip=8.8.8.8;
### 	location=37.7510,-97.8220; organization=Google LLC; os=Linux; port=53; seen_date=2017-11-26}...}
### status           : ok
### took             : 0.029
### total            : 76
### cli-API_info     : {synscan}
### cli-API_input    : {8.8.8.8}
### cli-key_required : {True}
### cli-Request_Date : 14/01/2018 20:45:08
## NOTES

## RELATED LINKS
