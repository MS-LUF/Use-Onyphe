---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheOnionScan

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to get info for a .onion link using OnionScan API

## SYNTAX

```
Invoke-APIOnypheOnionScan [-Onion] <String[]> [[-APIKey] <String>] [[-Page] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to get info for a .onion link using OnionScan API

## EXAMPLES

### EXAMPLE 1
```
get md5 info for vlp4uw5ui22ljlg7.onion URL
```

C:\PS\> Invoke-APIOnypheOnionScan -Onion "vlp4uw5ui22ljlg7.onion"

### EXAMPLE 2
```
get md5 info for vlp4uw5ui22ljlg7.onion URL and set the api key
```

C:\PS\> Invoke-APIOnypheOnionScan -Onion "vlp4uw5ui22ljlg7.onion" -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

## PARAMETERS

### -Onion
-Onion string{Onion URL}
Onion link to be used for the Onion API usage

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
### results          : {}
### status           : ok
### took             : 0.259
### total            : 1942240
### cli-API_info     : {OnionScan}
### cli-API_input    : {vlp4uw5ui22ljlg7.onion}
### cli-key_required : {True}
### cli-Request_Date : 05/03/2019 16:48:12
## NOTES

## RELATED LINKS
