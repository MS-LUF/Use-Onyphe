---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Invoke-OnyphePivot

## SYNOPSIS
main function/cmdlet - pivot from a prior Onyphe result set to a follow-up search, per distinct value of a field

## SYNTAX

```
Invoke-OnyphePivot [-InputObject] <Array> [-PivotField] <String> [-APIKey <String>] [-Size <Int32>]
 [-TrackQuery] [-Calculated] [-UseBetaFeatures] [-Post] [-Wait <Int32>] [-ProgressAction <ActionPreference>]
 -PivotCategory <String> -PivotFilter <String> [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - takes a prior Onyphe result set (e.g.
from Search-OnypheInfo/Get-OnypheInfo),
extracts every distinct value of -PivotField from it, and fires one follow-up Search-OnypheInfo call
per distinct value using -PivotFilter as the target OQL filter name.
Captures the "auto-pivot" idea
from the official onyphe/cli's opp companion tool (Andlookup/Orlookup/Pivots/Whois processors,
which issue new Onyphe API calls off a field pulled from a prior result set) without porting the
rest of that tool's 24 purely client-side formatting/filtering processors - those are already
covered natively and idiomatically by PowerShell's own object pipeline (Where-Object/Group-Object/
Sort-Object -Unique/etc.).

One API call is made per distinct pivot value (not a single OR-combined query) - this mirrors the
manual multi-step technique this project's own OSINT sessions have already used by hand (e.g.
Results/CertAndDNS/sovcloud_domains_analysis.md's organization-to-domain and subnet-to-domain
enumeration passes), and keeps clear provenance (which pivot value produced which hits) at the cost
of one API call/credit per distinct value.
Each returned result object is tagged with two extra
NoteProperty fields, 'cli-pivot_source_field' and 'cli-pivot_source_value', recording which
-PivotField value produced it.

Only the first page of results is retrieved per pivot value (no -Page support) - use -Size to widen
that first page if needed.

## EXAMPLES

### EXAMPLE 1
```
pivot from a ctl result set to every other certificate sharing the same subject.organization value(s), using -PivotField and -PivotFilter as the same field name here (both live on the ctl category)
C:\PS> Search-OnypheInfo -AdvancedSearch @("domain:example.com") -Category ctl | Invoke-OnyphePivot -PivotField "subject.organization" -PivotCategory ctl -PivotFilter "subject.organization"
```

### EXAMPLE 2
```
pivot from a resolver result set to every other hostname hosted on the same organization, waiting 2s between each follow-up call
C:\PS> Search-OnypheInfo -AdvancedSearch @("domain:example.com") -Category resolver | Invoke-OnyphePivot -PivotField organization -PivotCategory resolver -PivotFilter organization -Wait 2
```

## PARAMETERS

### -InputObject
-InputObject PSOnyphe object\[\]
a prior Onyphe result set (e.g.
piped in from Search-OnypheInfo/Get-OnypheInfo) to pivot from

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -PivotField
-PivotField string
dotted property path to read off each -InputObject item (e.g.
"subject.organization",
"geolocus.organization") - the source of the distinct values to pivot on.
If the resolved property
value is itself an array (e.g.
a SAN list), every element is treated as its own distinct value.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
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
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Size
-Size int{1 to 10000}
number of results per page (server default is 100 when omitted), applied to every follow-up query

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -TrackQuery
-TrackQuery switch
ask Onyphe to return, for each result, which OQL filter matched it (applied to every follow-up query)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Calculated
-Calculated switch
ask Onyphe to enrich results with computed fields (applied to every follow-up query)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Post
-Post switch
send each follow-up query's OQL as a POST request body instead of a GET query-string parameter (see
Search-OnypheInfo's -Post)

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Wait
-Wait int{second}
wait for x second before sending each follow-up query, to manage rate limiting across the (potentially
many) API calls this cmdlet can fire - one per distinct pivot value

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -PivotCategory
{{ Fill PivotCategory Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PivotFilter
{{ Fill PivotFilter Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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
