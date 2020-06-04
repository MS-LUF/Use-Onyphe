---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Import-OnypheEncryptedIKey

## SYNOPSIS
import onyphe API key as global variable from encrypted local config file

## SYNTAX

```
Import-OnypheEncryptedIKey [-MasterPassword] <SecureString> [<CommonParameters>]
```

## DESCRIPTION
import onyphe API key as global variable from encrypted local config file

## EXAMPLES

### EXAMPLE 1
```
set API Key as global variable using encrypted key hosted in local xml file previously generated with Set-OnypheAPIKey
C:\PS> Import-OnypheEncryptedIKey -MasterPassword (ConvertTo-SecureString -String "YourP@ssw0rd" -AsPlainText -Force)
```

## PARAMETERS

### -MasterPassword
-MasterPassword SecureString{Password}
Use a passphrase for encryption purpose.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### none
## NOTES

## RELATED LINKS
