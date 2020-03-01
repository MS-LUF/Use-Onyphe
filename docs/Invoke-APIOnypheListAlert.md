---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-APIOnypheListAlert

## SYNOPSIS
create several input for Invoke-OnypheAPIv2 function and then call it to list alert already set from alert/list API

## SYNTAX

```
Invoke-APIOnypheListAlert [-APIKey <String>] [-UseBetaFeatures] [<CommonParameters>]
```

## DESCRIPTION
create several input for Invoke-OnypheAPIv2 function and then call it to list alert already set from alert/list API

## EXAMPLES

### EXAMPLE 1
```
get alert set and set api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

C:\PS\> Invoke-APIOnypheListAlert -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 2
```
get alert set
```

C:\PS\> Invoke-APIOnypheListAlert

## PARAMETERS

### -APIKey
-APIKey string{APIKEY}
Set APIKEY as global variable.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UseBetaFeatures
-UseBetaFeatures switch
use test.onyphe.io to use new beat features of Onyphe

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 11
Default value: False
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
### cli-API_version  NoteProperty string cli-API_version=2
### cli-key_required NoteProperty bool[] cli-key_required=System.Boolean[]
### cli-Request_Date NoteProperty datetime cli-Request_Date=27/12/2019 12:20:36
### count            NoteProperty long count=2
### error            NoteProperty long error=0
### myip             NoteProperty string myip=8.8.8.8
### results          NoteProperty Object[] results=System.Object[]
### status           NoteProperty string status=ok
### took             NoteProperty string took=0.000
### total            NoteProperty long total=2
## NOTES

## RELATED LINKS