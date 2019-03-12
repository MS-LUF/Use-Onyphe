---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheMyIP

## SYNOPSIS
create several input for Invoke-Onyphe function and then call it to get current public ip from MyIP API

## SYNTAX

```
Invoke-APIOnypheMyIP [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-Onyphe function and then call it to get current public ip from MyIP API

## EXAMPLES

### EXAMPLE 1
```
get your current public ip
```

C:\PS\> Invoke-APIOnypheMyIP

## PARAMETERS

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
### status           NoteProperty string status=ok
### error            : 0
### myip             : 192.168.6.66
### status           : ok
### cli-API_info     : {myip}
### cli-API_input    : {none}
### cli-key_required : {False}
### cli-Request_Date : 14/01/2018 20:45:08
## NOTES

## RELATED LINKS
