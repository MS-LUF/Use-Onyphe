---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Export-OnypheDataShot

## SYNOPSIS
Export encoded base64 jpg file from a datashot category object

## SYNTAX

```
Export-OnypheDataShot [-tofolder] <Object> [-inputobject] <Array> [<CommonParameters>]
```

## DESCRIPTION
Export encoded base64 jpg file from a datashot category object

## EXAMPLES

### EXAMPLE 1
```
Export all screenshots available in powershell object $temp into C:\temp folder
```

C:\PS\> Export-OnypheDataShot -tofolder C:\temp -inputobject $temp

## PARAMETERS

### -tofolder
{{Fill tofolder Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -inputobject
{{Fill inputobject Description}}

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### jpg file
## NOTES

## RELATED LINKS
