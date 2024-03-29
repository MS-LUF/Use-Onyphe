---
external help file: use-onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Set-OnypheProxy

## SYNOPSIS
Set an internet proxy to use onyphe web api

## SYNTAX

```
Set-OnypheProxy [-DirectNoProxy] [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>]
 [-ProxyUseDefaultCredentials] [-AnonymousProxy] [<CommonParameters>]
```

## DESCRIPTION
Set an internet proxy to use onyphe web api

## EXAMPLES

### EXEMPLE 1
```
Remove Internet Proxy and set a direct connection
```

C:\PS\> Set-OnypheProxy -DirectNoProxy

### EXEMPLE 2
```
Set Internet Proxy and with manual authentication
```

$credentials = get-credential 
C:\PS\> Set-OnypheProxy -Proxy "http://myproxy:8080" -ProxyCredential $credentials

### EXEMPLE 3
```
Set Internet Proxy and with automatic authentication based on current security context
```

C:\PS\> Set-OnypheProxy -Proxy "http://myproxy:8080" -ProxyUseDefaultCredentials

### EXEMPLE 4
```
Set Internet Proxy and with no authentication
```

C:\PS\> Set-OnypheProxy -Proxy "http://myproxy:8080" -AnonymousProxy

## PARAMETERS

### -DirectNoProxy
-DirectNoProxy
Remove proxy and configure Onyphe powershell functions to use a direct connection

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

### -Proxy
-Proxy{Proxy}
Set the proxy URL

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProxyCredential
-ProxyCredential{ProxyCredential}
Set the proxy credential to be authenticated with the internet proxy set

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProxyUseDefaultCredentials
-ProxyUseDefaultCredentials
Use current security context to be authenticated with the internet proxy set

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

### -AnonymousProxy
-AnonymousProxy
No authentication (open proxy) with the internet proxy set

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### none
## NOTES

## RELATED LINKS
