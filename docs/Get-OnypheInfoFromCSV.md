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
```

C:\PS\> Get-onypheinfo -fromcsv .\input.csv

### EXAMPLE 2
```
Request info for several IP information from a csv formated file and set the API key as global variable
```

C:\PS\> Get-onypheinfo -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 3
```
Request info for several IP information from a csv formated file using ',' separator and set the API key as global variable
```

C:\PS\> Get-onypheinfo -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -csvdelimiter ","

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName: System.Management.Automation.PSCustomObject
### count            : 28
### error            : 0
### myip             : 192.168.6.66
### results          : {@{@category=inetnum; @timestamp=2018-01-14T02:37:32.000Z; @type=ip; country=US; ipv6=false;
### 				netname=EU-EDGECASTEU-20080602; seen_date=2018-01-14; source=RIPE; subnet=93.184.208.0/20},
### 				@{@category=inetnum; @timestamp=2018-01-14T02:37:32.000Z; @type=ip; country=EU;
### 				information=System.Object[]; ipv6=false; netname=EDGECAST-NETBLK-03; seen_date=2018-01-14;
### 				source=RIPE; subnet=93.184.208.0/24}, @{@category=inetnum; @timestamp=2018-01-07T02:37:24.000Z;
### 				@type=ip; country=US; ipv6=false; netname=EU-EDGECASTEU-20080602; seen_date=2018-01-07;
### 				source=RIPE; subnet=93.184.208.0/20}, @{@category=inetnum; @timestamp=2018-01-07T02:37:24.000Z;
### 				@type=ip; country=EU; information=System.Object[]; ipv6=false; netname=EDGECAST-NETBLK-03;
### 				seen_date=2018-01-07; source=RIPE; subnet=93.184.208.0/24}...}
### status           : ok
### took             : 0.437
### total            : 28
### cli-API_info     : {inetnum}
### cli-API_input    : {192.168.6.66}
### cli-key_required : {True}
### cli-Request_Date : 14/01/2018 20:51:06
## NOTES

## RELATED LINKS
