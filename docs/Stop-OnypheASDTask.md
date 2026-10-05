---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Stop-OnypheASDTask

## SYNOPSIS
main function/cmdlet - kill/clear an ASD task on onyphe.io web service

## SYNTAX

```
Stop-OnypheASDTask [-TaskId] <String> [[-APIKey] <String>] [[-wait] <Int32>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - kill/clear an ASD task on onyphe.io web service using the ASD Task Kill APIv1
(v1/asd/task/kill/\<id\>, an HTTP DELETE request) - works on both a still-running task (terminates it) and
an already-finished one (clears it from Get-OnypheASDTaskList, which is necessary on this account before
a new ASD *inventory call with astask:true can be made - see Get-OnypheASDTaskList's comment-based help).
These are BETA endpoints requiring a Griffin View or Griffin View ASM Edition subscription with a
non-commercial use licence - see Get-OnypheUserInfo's asd.stdapis property to check whether they are
licensed on your account.

## EXAMPLES

### EXAMPLE 1
```
kill/clear an ASD task, prompting for confirmation first
C:\PS> Stop-OnypheASDTask -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7"
```

### EXAMPLE 2
```
kill/clear an ASD task without prompting
C:\PS> Stop-OnypheASDTask -TaskId "22f9efca-994f-4f26-af1b-8a4db99e4fa7" -Confirm:$false
```

## PARAMETERS

### -TaskId
-TaskId string
the task ID to kill/clear

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

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
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
