---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Get-OnypheASDTask

## SYNOPSIS
main function/cmdlet - retrieve the final result of an ASD task on onyphe.io web service

## SYNTAX

```
Get-OnypheASDTask [-TaskId] <String> [[-APIKey] <String>] [[-wait] <Int32>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - retrieve the final result of an ASD task on onyphe.io web service using the ASD
Task Id APIv1 (v1/asd/task/id/\<id\>).
Any ASD *inventory endpoint (Get-OnypheASDInfo -ASDAPIType
orginventory/subnetinventory/ipinventory) can return HTTP error 1011 "too many results, you should
create a task" for a large domain instead of its usual results - re-run the same ASD call adding an
"astask":"true" field to get a .taskid back instead, then use that task ID here (or with
Wait-OnypheASDTask, which polls until the task finishes and calls this automatically).
Returns error
1009 ("task not finished, no output file") if the task hasn't finished yet.
These are BETA endpoints
requiring a Griffin View or Griffin View ASM Edition subscription with a non-commercial use licence -
see Get-OnypheUserInfo's asd.stdapis property to check whether they are licensed on your account.

## EXAMPLES

### EXAMPLE 1
```
retrieve the final result of a finished ASD task
C:\PS> Get-OnypheASDTask -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7"
```

## PARAMETERS

### -TaskId
-TaskId string
the task ID to retrieve results for

```yaml
Type: String
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

### -wait
-Wait int{second}
wait for x second before sending the request to manage rate limiting restriction

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### TypeName: PSOnyphe
## NOTES

## RELATED LINKS
