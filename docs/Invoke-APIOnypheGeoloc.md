---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheGeoloc

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to get the Geoloc info from Geoloc API

## SYNTAX

```
Invoke-APIOnypheGeoloc [-IP] <String[]> [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to get the Geoloc info from Geoloc API

## EXAMPLES

### EXAMPLE 1
```
get geoloc info for IP 8.8.8.8
```

C:\PS\> Invoke-APIOnypheGeoloc -IP 8.8.8.8

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
### count            : 1
### error            : 0
### myip             : 192.168.6.66
### results          : {@{@category=geoloc; @timestamp=2018-01-13T10:18:52.000Z; @type=ip; asn=AS15169; city=; country=US;
### 			country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
### 			longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}}
### status           : ok
### took             : 0.013426
### total            : 1
### cli-API_info     : {geoloc}
### cli-API_input    : {8.8.8.8}
### cli-key_required : {False}
### cli-Request_Date : 14/01/2018 20:45:08
## NOTES

## RELATED LINKS
