---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Get-OnypheASDTaskList

## SYNOPSIS
main function/cmdlet - list all ASD tasks for the account on onyphe.io web service

## SYNTAX

```
Get-OnypheASDTaskList [[-APIKey] <String>] [[-wait] <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - list all ASD tasks for the account on onyphe.io web service using the ASD Task
List APIv1 (v1/asd/task/list) - currently running or already finished.
Each entry is
{"taskid": "\<guid\>", "running": "true"|"false"}.
Returns error 1007 ("task not found: empty list") when
there are no tasks at all - not a failure, just an empty list.
Live-tested 2026-09-18: this account
allows only one task at a time - a second call to an ASD *inventory endpoint with astask:true while one
is already tracked here fails with error 1008 "creating task failed: a task is already running", even
after the tracked task has finished, until it is explicitly cleared with Stop-OnypheASDTask.
These are
BETA endpoints requiring a Griffin View or Griffin View ASM Edition subscription with a non-commercial
use licence - see Get-OnypheUserInfo's asd.stdapis property to check whether they are licensed on your
account.

## EXAMPLES

### EXAMPLE 1
```
list all ASD tasks for the account
C:\PS> Get-OnypheASDTaskList
```

## PARAMETERS

### -APIKey
-APIKey string{APIKEY}
set your APIKEY to be able to use Onyphe API.

```yaml
Type: String
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
