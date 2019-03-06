---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheDataScan

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to get the data scan info from datascan API

## SYNTAX

```
Invoke-APIOnypheDataScan [-IPOrDataScanString] <String[]> [[-APIKey] <String[]>] [[-Page] <String[]>]
 [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to get the data scan info from datascan API

## EXAMPLES

### EXAMPLE 1
```
get all data scan info for IP 27.251.29.154
```

C:\PS\> Invoke-APIOnypheDataScan -IP 27.251.29.154

### EXAMPLE 2
```
get all info for info available for PanWeb web server
```

C:\PS\> Invoke-APIOnypheDataScan -DataScanString "PanWeb"

### EXAMPLE 3
```
get all data scan info for IP 27.251.29.154 and set the api key
```

C:\PS\> Invoke-APIOnypheDataScan -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## PARAMETERS

### -IPOrDataScanString
-IPOrDataScanString string{IP}
IP to be used for the DataScan API usage
-IPOrDataScanString string
string to be used for the DataScan API usage

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
### count            : 1
### error            : 0
### myip             : 192.168.6.66
### results          : {@{@category=datascan; @timestamp=2018-01-05T02:21:45.000Z; @type=http; asn=AS10201; country=IN;
### 	data=HTTP/1.0 302 Moved Temporarily
### 	Date: Sat, 06 Jan 2018 02:13:01 GMT
### 	Server: PanWeb Server/ -
### 	ETag: "73829-130d-57651d79"
### 	Connection: close
### 	Pragma: no-cache
### 	Location: /php/login.php
### 	Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0
### 	Content-Length: 0
### 	Content-Type: text/html
### 	Expires: Thu, 19 Nov 1981 08:52:00 GMT
### 	X-FRAME-OPTIONS: SAMEORIGIN
### 	Set-Cookie: PHPSESSID=73ebc70421adc9c46219dd68d722bb8b; path=/; HttpOnly
### 	; datamd5=beddae472d600e9e25787353ed4e5f21; ip=27.251.29.154; ipv6=false; location=20.0000,77.0000;
### 	organization=Dishnet Wireless Limited. Broadband Wireless; port=80; product=PanWeb Server;
### 	productversion= - ; protocol=http; seen_date=2018-01-05}}
### status           : ok
### took             : 0.013
### total            : 1
### cli-API_info     : {datascan}
### cli-API_input    : {27.251.29.154}
### cli-key_required : {True}
### cli-Request_Date : 14/01/2018 20:45:08
## NOTES

## RELATED LINKS
