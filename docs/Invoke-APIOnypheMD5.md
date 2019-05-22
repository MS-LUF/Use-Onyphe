---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheMD5

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to get info from onyphe md5 signature

## SYNTAX

```
Invoke-APIOnypheMD5 [-MD5] <String[]> [[-APIKey] <String>] [[-Page] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to get info from onyphe md5 signature

## EXAMPLES

### EXAMPLE 1
```
get md5 info for 7a1f20cae067b75a52bc024b83ee4667 hash
```

C:\PS\> Invoke-APIOnypheMd5 -MD5 7a1f20cae067b75a52bc024b83ee4667

### EXAMPLE 2
```
get md5 info for 7a1f20cae067b75a52bc024b83ee4667 hash and set the api key
```

C:\PS\> Invoke-APIOnypheMd5 -MD5 7a1f20cae067b75a52bc024b83ee4667 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## PARAMETERS

### -MD5
-MD5 string{MD5 Hash}
MD5 to be used for the md5 API usage

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
### count            : 10
### error            : 0
### max_page         : 1000
### myip             : 192.168.6.66
### page             : 1
### results          : {@{@category=datascan; @timestamp=05/03/2019 13:25:40; @type=doc; app=; asn=AS36352; city=Buffalo;
### 							country=US; cpe=System.Object[]; data=SSH-2.0-OpenSSH_7.4\x0d
### 							; datamd5=7a1f20cae067b75a52bc024b83ee4667; device=; domain=colocrossing.com;
### 							host=104-168-71-162-host; ip=104.168.71.162; ipv6=false; location=42.8864,-78.8781;
### 							organization=ColoCrossing; port=22; product=OpenSSH; productvendor=OpenBSD; productversion=7.4;
### 							protocol=ssh; protocolversion=2.0; reverse=104-168-71-162-host.colocrossing.com;
### 							seen_date=2019-03-05; source=sniffer; subnet=104.168.70.0/23; tag=System.Object[]; tld=com;
### 							tls=false; transport=tcp}, @{@category=datascan; @timestamp=05/03/2019 12:08:44; @type=doc; app=;
### 							asn=AS27715; country=BR; cpe=System.Object[]; data=SSH-2.0-OpenSSH_7.4\x0d
### 							; datamd5=7a1f20cae067b75a52bc024b83ee4667; device=; domain=hospedagemdesites.ws; host=gagarin0303;
### 							hostname=System.Object[]; ip=191.252.118.55; ipv6=false; location=-22.8305,-43.2192;
### 							organization=Locaweb Serviços de Internet S/A; port=22; product=OpenSSH; productvendor=OpenBSD;
### 							productversion=7.4; protocol=ssh; protocolversion=2.0; reverse=gagarin0303.hospedagemdesites.ws;
### 							seen_date=2019-03-05; source=datascan; subnet=191.252.112.0/20; tag=System.Object[]; tld=ws;
### 							tls=false; transport=tcp}, @{@category=datascan; @timestamp=05/03/2019 12:08:44; @type=doc; app=;
### 							asn=AS45090; city=Beijing; country=CN; cpe=System.Object[]; data=SSH-2.0-OpenSSH_7.4\x0d
### 							; datamd5=7a1f20cae067b75a52bc024b83ee4667; device=; ip=119.29.173.149; ipv6=false;
### 							location=39.9288,116.3889; organization=Shenzhen Tencent Computer Systems Company Limited; port=22;
### 							product=OpenSSH; productvendor=OpenBSD; productversion=7.4; protocol=ssh; protocolversion=2.0;
### 							seen_date=2019-03-05; source=datascan; subnet=119.29.128.0/17; tag=System.Object[]; tls=false;
### 							transport=tcp}, @{@category=datascan; @timestamp=05/03/2019 12:08:44; @type=doc; app=; asn=AS45090;
### 							country=CN; cpe=System.Object[]; data=SSH-2.0-OpenSSH_7.4\x0d
### 							; datamd5=7a1f20cae067b75a52bc024b83ee4667; device=; ip=62.234.10.225; ipv6=false;
### 							location=39.9289,116.3883; organization=Shenzhen Tencent Computer Systems Company Limited; port=22;
### 							product=OpenSSH; productvendor=OpenBSD; productversion=7.4; protocol=ssh; protocolversion=2.0;
### 							seen_date=2019-03-05; source=datascan; subnet=62.234.0.0/16; tag=System.Object[]; tls=false;
### 							transport=tcp}...}
### status           : ok
### took             : 0.259
### total            : 1942240
### cli-API_info     : {md5}
### cli-API_input    : {7a1f20cae067b75a52bc024b83ee4667}
### cli-key_required : {True}
### cli-Request_Date : 05/03/2019 16:48:12
## NOTES

## RELATED LINKS
