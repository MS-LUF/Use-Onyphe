---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Get-OnypheInfoFromCSV

## SYNOPSIS
Get IP information from onyphe.io web service using as an input a CSV file containing all information

## SYNTAX

```
Get-OnypheInfoFromCSV [-fromcsv] <Object> [[-APIKey] <String>] [[-csvdelimiter] <Object>] [<CommonParameters>]
```

## DESCRIPTION
get various ip data information from onyphe.io web service using as an input a csv file (; separator)

## EXAMPLES

### EXAMPLE 1
```
Request info for several IP information from a csv formated file and your API key is already set as global variable
C:\PS> Get-onypheinfofromcsv -fromcsv .\input.csv
```

### EXAMPLE 2
```
Request info for several IP information from a csv formated file and set the API key as global variable
C:\PS> Get-onypheinfofromcsv -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### EXAMPLE 3
```
Request info for several IP information from a csv formated file using ',' separator and set the API key as global variable
C:\PS> Get-onypheinfofromcsv -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -csvdelimiter ","
```

## PARAMETERS

### -fromcsv
-fromcsv string{full path to csv file}
automate onyphe.io request for multiple IP request

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

### -APIKey
-APIKey string{APIKEY}
set your APIKEY to be able to use Onyphe API.

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

### -csvdelimiter
-csvdelimiter string{csv separator}
set your csv separator.
default is ;

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName: System.Management.Automation.PSCustomObject
## NOTES

## RELATED LINKS
