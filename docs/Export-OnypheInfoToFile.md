---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Export-OnypheInfoToFile

## SYNOPSIS
Export psobject containing Onyphe info to files

## SYNTAX

```
Export-OnypheInfoToFile [-tofolder] <Object> [-InputOnypheObject] <Array> [[-csvdelimiter] <Object>]
 [<CommonParameters>]
```

## DESCRIPTION
Export psobject containing Onyphe info to files
One root folder is created and a dedicated csv file is created by category.
Note : for the datascan category, the data attribute content is exported in a separated text file to be more readable.
Note 2 : in this version, there is an issue if you pipe a psobject containing an array of onyphe result to the function.
to be investigated.

## EXAMPLES

### EXEMPLE 1
```
Exporting onyphe results containing into $onypheresult object to flat files in folder C:\temp
```

C:\PS\> Export-OnypheInfoToFile -tofolder C:\temp -InputOnypheObject $onypheresult

### EXEMPLE 2
```
Exporting onyphe results containing into $onypheresult object to flat files in folder C:\temp using ',' as csv separator
```

C:\PS\> Export-OnypheInfoToFile -tofolder C:\temp -InputOnypheObject $onypheresult -csvdelimiter ","

## PARAMETERS

### -tofolder
-tofolcer string{target folder}
path to the target folder where you want to export onyphe data

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

### -InputOnypheObject
-InputOnypheObject $obj{output of Get-OnypheInfo or Get-OnypheInfoFromCSV functions}
look for information about my public IP

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### none
## NOTES

## RELATED LINKS
