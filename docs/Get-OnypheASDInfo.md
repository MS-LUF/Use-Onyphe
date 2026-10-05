---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Get-OnypheASDInfo

## SYNOPSIS
main function/cmdlet - Get information from onyphe.io web service using the ASD (Attack Surface Discovery) APIv1

## SYNTAX

```
Get-OnypheASDInfo [-Value] <String[]> [[-IncludePattern] <String[]>] [[-ExcludePattern] <String[]>]
 [-Untrusted] [-AsLines] [[-APIKey] <String>] [[-wait] <Int32>] [-ProgressAction <ActionPreference>]
 -ASDAPIType <String> [<CommonParameters>]
```

## DESCRIPTION
main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by ASD API
type available.
The ASD APIs are BETA endpoints requiring a Griffin View or Griffin View ASM Edition
subscription with a non-commercial use licence - see Get-OnypheUserInfo's asd.stdapis property to check
whether they are licensed on your account.
Only 21 of the ~21-22 "standard" ASD APIs (stdapis) documented by
the official onyphe/cli are implemented so far; the "advanced" Pivot Query API (advapis) and the
remaining stdapis inventory/existence-check endpoints are not yet implemented in this module.
ASD task
management (for results too large to return synchronously) is implemented separately - see
Get-OnypheASDTask/Get-OnypheASDTaskList/Wait-OnypheASDTask/Stop-OnypheASDTask.

## EXAMPLES

### EXAMPLE 1
```
discover related domains across TLDs for example.com
C:\PS> Get-OnypheASDInfo -ASDAPIType domaintld -Value example.com
```

### EXAMPLE 2
```
discover certificate subject.organization value(s) linked to a domain
C:\PS> Get-OnypheASDInfo -ASDAPIType certsodomain -Value example.com
```

### EXAMPLE 3
```
discover domain(s) linked to a certificate subject.organization value, disabling backend false-positive filtering
C:\PS> Get-OnypheASDInfo -ASDAPIType domaincertso -Value "Example Organization" -Untrusted
```

### EXAMPLE 4
```
check whether one or more domains exist (passive DNS history / live brute-force)
C:\PS> Get-OnypheASDInfo -ASDAPIType dnsdomainexist -Value @("example.com","example.org")
```

### EXAMPLE 5
```
discover the subnet(s) belonging to one or more domains, as an attack-surface inventory rollup
C:\PS> Get-OnypheASDInfo -ASDAPIType subnetinventory -Value example.com
```

### EXAMPLE 6
```
discover the IP address(es) belonging to one or more domains, as an attack-surface inventory rollup
C:\PS> Get-OnypheASDInfo -ASDAPIType ipinventory -Value example.com
```

### EXAMPLE 7
```
discover the organization(s) associated with one or more domains, as an attack-surface inventory rollup
C:\PS> Get-OnypheASDInfo -ASDAPIType orginventory -Value example.com
```

### EXAMPLE 8
```
discover the IP address(es) belonging to a certificate subject.organization value
C:\PS> Get-OnypheASDInfo -ASDAPIType ipcertso -Value "Example Organization"
```

### EXAMPLE 9
```
discover the IP address(es) belonging to one or more domains
C:\PS> Get-OnypheASDInfo -ASDAPIType ipdomain -Value example.com
```

### EXAMPLE 10
```
discover the virtual host(s)/forward DNS hostname(s) belonging to one or more domains
C:\PS> Get-OnypheASDInfo -ASDAPIType vhostinventory -Value example.com
```

### EXAMPLE 11
```
discover risk-flagged findings for one or more domains, as an attack-surface inventory rollup
C:\PS> Get-OnypheASDInfo -ASDAPIType scoreinventory -Value example.com
```

### EXAMPLE 12
```
discover other domain(s) sharing the same Microsoft 365 tenant as one or more domains (a live DNS lookup)
C:\PS> Get-OnypheASDInfo -ASDAPIType dnsdomainmstenantid -Value example.com
```

### EXAMPLE 13
```
check whether one or more domains have an existing NS record (a live DNS lookup)
C:\PS> Get-OnypheASDInfo -ASDAPIType dnsdomainnsexist -Value @("example.com","example.org")
```

### EXAMPLE 14
```
check whether one or more domains exist - can return HTTP error 1011 "too many results, you should create a task" for domains with a large enough footprint, see Get-OnypheASDTask/Wait-OnypheASDTask
C:\PS> Get-OnypheASDInfo -ASDAPIType domainexist -Value @("example.com","example.org")
```

### EXAMPLE 15
```
discover subdomain(s)/hostname(s) for one or more domains from web crawl data
C:\PS> Get-OnypheASDInfo -ASDAPIType websubdomaindomain -Value example.com
```

### EXAMPLE 16
```
seed a wildcard-domain search from a certificate subject.organization value - can return HTTP error 1011 "too many results, you should create a task" for a large organization, see Get-OnypheASDTask/Wait-OnypheASDTask
C:\PS> Get-OnypheASDInfo -ASDAPIType bootstrapcertsowildcard -Value "Example Organization"
```

## PARAMETERS

### -Value
-Value string\[\]
one or more values to query.
For domaincertso, ipcertso and bootstrapcertsowildcard this is one or more
certificate subject.organization values; for subnetinventory/ipinventory/orginventory/vhostinventory/
scoreinventory, the domain(s) are wrapped
server-side into an inventory rollup rather than queried individually; for every other ASDAPIType this
is one or more domains.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -IncludePattern
-IncludePattern string\[\]
patterns to grep and keep matching results (not supported by ASDAPIType dnsdomainexist, dnsdomainnsexist,
domainexist)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ExcludePattern
-ExcludePattern string\[\]
patterns to grep and exclude from results (not supported by ASDAPIType dnsdomainexist, dnsdomainnsexist,
domainexist)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Untrusted
-Untrusted switch
disable Onyphe's backend false-positive filtering, server default is enabled/trusted (not supported by
ASDAPIType dnsdomainexist, dnsdomainnsexist, domainexist)

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

### -AsLines
-AsLines switch
render results as one JSON object per line instead of with context (server default is with context)

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

### -wait
-Wait int{second}
wait for x second before sending the request to manage rate limiting restriction

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -ASDAPIType
{{ Fill ASDAPIType Description }}

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
