---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Wait-OnypheASDTask

## SYNOPSIS
main function/cmdlet - wait for an ASD task on onyphe.io web service to finish, then return its result

## SYNTAX

```
Wait-OnypheASDTask [-TaskId] <String> [[-PollIntervalSec] <Int32>] [[-TimeoutSec] <Int32>] [[-APIKey] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - wait for an ASD task on onyphe.io web service to finish, then return its result.
Repeatedly checks Get-OnypheASDTaskList's per-task "running" flag (the only reliable completion signal
found live-testing 2026-09-18 - the ASD Task Poll APIv1's own output is a rolling numeric progress-tick
array that does not visibly change shape on completion, so it's surfaced here only as -Verbose progress
information, not used to detect completion) every -PollIntervalSec seconds, up to -TimeoutSec seconds
total, then calls Get-OnypheASDTask to fetch and return the finished task's actual result.
If the task ID
is no longer present in Get-OnypheASDTaskList at all (already cleared, or never existed), attempts
Get-OnypheASDTask once anyway as a fallback so the caller still sees whatever error the server reports,
rather than this cmdlet silently returning nothing.
On timeout, returns the last-seen task-list entry
with a warning instead of the (still unfinished) result.
These are BETA endpoints requiring a Griffin
View or Griffin View ASM Edition subscription with a non-commercial use licence - see
Get-OnypheUserInfo's asd.stdapis property to check whether they are licensed on your account.

## EXAMPLES

### EXAMPLE 1
```
wait for an ASD task to finish (default polling every 5s, up to 300s), then return its result
C:\PS> Wait-OnypheASDTask -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7"
```

### EXAMPLE 2
```
wait for a long-running task, checking every 10 seconds for up to 10 minutes
C:\PS> Wait-OnypheASDTask -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7" -PollIntervalSec 10 -TimeoutSec 600
```

## PARAMETERS

### -TaskId
-TaskId string
the task ID to wait for

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

### -PollIntervalSec
-PollIntervalSec int
seconds to wait between each check (default 5)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 5
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutSec
-TimeoutSec int
maximum total seconds to wait before giving up (default 300)

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 300
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
Position: 4
Default value: None
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
