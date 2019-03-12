---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheCtl

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to get the CTL (certificate transparancy) info from ctl API

## SYNTAX

```
Invoke-APIOnypheCtl [-Domain] <String[]> [[-APIKey] <String[]>] [[-Page] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to get the CTL (certificate transparancy) info from ctl API

## EXAMPLES

### EXAMPLE 1
```
get CTL info for fnac.com
```

C:\PS\> Invoke-APIOnypheCtl -Domain fnac.com

### EXAMPLE 2
```
get CTL info for fnac.com and set the api key
```

C:\PS\> Invoke-APIOnypheCtl -Domain fnac.com -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## PARAMETERS

### -Domain
-Domain string{Domain or FQDN}
Domain or FQDN to be used for the ctl API usage

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
### cli-Request_Date NoteProperty datetime cli-Request_Date=04/03/2019 22:04:40
### count            NoteProperty long count=10
### error            NoteProperty long error=0
### max_page         NoteProperty long max_page=3
### myip             NoteProperty string myip=192.168.6.66
### page             NoteProperty long page=1
### results          NoteProperty Object[] results=System.Object[]
### status           NoteProperty string status=ok
### took             NoteProperty string took=0.034
### total            NoteProperty long total=28
### count            : 1
### error            : 0
### max_page         : 1
### myip             : 192.168.6.66
### page             : 1
### results          : {@{@category=ctl; @timestamp=15/02/2019 21:28:05; @type=doc; ca=false; country=FR;
### 							domain=fnac.com; extkeyusage=System.Object[]; fingerprint=; host=portaltv-int;
### 							hostname=System.Object[]; ip=80.12.18.251; issuer=; keyusage=System.Object[]; organization=Orange;
### 							publickey=; seen_date=2019-02-15; serial=01:81:e1:48:b1:9b:1e:4f:bc:5f:fc:99:e7:73:7d:da;
### 							signature=; source=Cloudflare Nimbus 2019; subdomains=q5ntv.orange.fr; subject=; tld=fr; validity=;
### 							version=v3; wildcard=false}}
### status           : ok
### took             : 0.024
### total            : 1
### cli-API_info     : {ctl}
### cli-API_input    : {orange.fr}
### cli-key_required : {True}
### cli-Request_Date : 05/03/2019 15:31:48
## NOTES

## RELATED LINKS
