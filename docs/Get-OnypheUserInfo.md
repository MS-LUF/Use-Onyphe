---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Get-OnypheUserInfo

## SYNOPSIS
main function/cmdlet - Get user account information (rate limiting status, requests remaining in pool...) from onyphe.io web service

## SYNTAX

```
Get-OnypheUserInfo [[-APIKey] <String[]>] [[-wait] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Get user account information (rate limiting status, requests remaining in pool...) from onyphe.io web service
send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object

## EXAMPLES

### EXAMPLE 1
```
get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx and set the api key
```

C:\PS\> Get-OnypheUserInfo -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 2
```
get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx already set as global variable
```

C:\PS\> Get-OnypheUserInfo

## PARAMETERS

### -APIKey
-APIKey string{APIKEY}
set your APIKEY to be able to use Onyphe API.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -wait
-Wait int{second}
wait for x second before sending the request to manage rate limiting restriction

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName: System.Management.Automation.PSCustomObject
### Name             MemberType   Definition
### ----             ----------   ----------
### Equals           Method       bool Equals(System.Object obj)
### GetHashCode      Method       int GetHashCode()
### GetType          Method       type GetType()
### ToString         Method       string ToString()
### cli-API_info     NoteProperty string[] cli-API_info=System.String[]
### cli-API_input    NoteProperty string[] cli-API_input=System.String[]
### cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
### cli-Request_Date NoteProperty datetime cli-Request_Date=23/01/2018 11:33:17
### count            NoteProperty int count=1
### error            NoteProperty int error=0
### myip             NoteProperty string myip=192.168.6.66
### results          NoteProperty Object[] results=System.Object[]
### status           NoteProperty string status=ok
### took             NoteProperty string took=0.001
### total            NoteProperty int total=1
## NOTES

## RELATED LINKS
