---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheSniffer

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to get the IP sniffer info from sniffer API

## SYNTAX

```
Invoke-APIOnypheSniffer [-IP] <String[]> [[-APIKey] <String[]>] [[-Page] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to get the IP sniffer info from sniffer API

## EXAMPLES

### EXAMPLE 1
```
get sniffer info for IP 217.138.28.194
```

C:\PS\> Invoke-APIOnypheSniffer -IP 217.138.28.194

### EXAMPLE 2
```
get sniffer info for IP 217.138.28.194 and set the api key
```

C:\PS\> Invoke-APIOnypheSniffer -IP 217.138.28.194 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## PARAMETERS

### -IP
-IP string{IP}
IP to be used for the sniffer API usage

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
### count            : 10
### error            : 0
### max_page         : 3
### myip             : 192.168.6.66
### page             : 1
### results          : {@{@category=sniffer; @timestamp=04/03/2019 13:27:53; @type=doc; asn=AS20952; city=Witham;
### 							country=GB; data=\x1b\x81\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00
### 							CKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x00\x00!\x00\x01; datamd5=70b95a08c5a052f5f8353bc75d1b7912;
### 							destport=137; ip=217.138.28.194; ipv6=false; location=51.8149,0.6454; organization=Venus Business
### 							Communications Limited; seen_date=2019-03-04; srcport=137; subnet=217.138.28.128/25;
### 							tag=System.Object[]; transport=udp; type=udpdata}, @{@category=sniffer; @timestamp=02/03/2019
### 							17:34:37; @type=doc; asn=AS20952; city=Witham; country=GB;
### 							data=Ni\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00 CKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x00\x00!\x00\x01;
### 							datamd5=35191f8ac64683f9564b6b0fc6e27847; destport=137; ip=217.138.28.194; ipv6=false;
### 							location=51.8149,0.6454; organization=Venus Business Communications Limited; seen_date=2019-03-02;
### 							srcport=137; subnet=217.138.28.128/25; tag=System.Object[]; transport=udp; type=udpdata},
### 							@{@category=sniffer; @timestamp=01/03/2019 23:52:39; @type=doc; asn=AS20952; city=Witham;
### 							country=GB; data=\x1e\xe8\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00
### 							CKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x00\x00!\x00\x01; datamd5=9f8536314d5eafdb06c99897fffb8aa8;
### 							destport=137; ip=217.138.28.194; ipv6=false; location=51.8149,0.6454; organization=Venus Business
### 							Communications Limited; seen_date=2019-03-01; srcport=137; subnet=217.138.28.128/25;
### 							tag=System.Object[]; transport=udp; type=udpdata}, @{@category=sniffer; @timestamp=28/02/2019
### 							18:08:53; @type=doc; asn=AS20952; city=Witham; country=GB;
### 							data=\x18\x99\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00
### 							CKAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\x00\x00!\x00\x01; datamd5=83a75a375d30691bc1cb164f2955f406;
### 							destport=137; ip=217.138.28.194; ipv6=false; location=51.8194,0.6718; organization=Venus Business
### 							Communications Limited; seen_date=2019-02-28; srcport=137; subnet=217.138.0.0/16;
### 							tag=System.Object[]; transport=udp; type=udpdata}...}
### status           : ok
### took             : 0.011
### total            : 28
### cli-API_info     : {sniffer}
### cli-API_input    : {217.138.28.194}
### cli-key_required : {True}
### cli-Request_Date : 04/03/2019 22:05:23
## NOTES

## RELATED LINKS
