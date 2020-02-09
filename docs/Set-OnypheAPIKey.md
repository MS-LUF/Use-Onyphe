---
external help file: Use-Onyphe-help.xml
Module Name: Use-Onyphe
online version:
schema: 2.0.0
---

# Set-OnypheAPIKey

## SYNOPSIS
set and remove onyphe API key as global variable

## SYNTAX

```
Set-OnypheAPIKey [[-APIKey] <String>] [-Remove] [-EncryptKeyInLocalFile] [[-MasterPassword] <SecureString>]
 [<CommonParameters>]
```

## DESCRIPTION
set and remove onyphe API key as global variable

## EXAMPLES

### EXAMPLE 1
```
Set your API key as global variable so it will be used automatically by all use-onyphe functions
```

C:\PS\> Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

### EXAMPLE 2
```
Remove your API key set as global variable
```

C:\PS\> Set-OnypheAPIKey -remove

### EXAMPLE 3
```
Store your API key on hard drive
```

C:\PS\> Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -MasterPassword (ConvertTo-SecureString -String "YourP@ssw0rd" -AsPlainText -Force) -EncryptKeyInLocalFile

## PARAMETERS

### -APIKey
-APIKey string{APIKEY}
Set APIKEY as global variable.

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

### -Remove
-Remove
Remove your current APIKEY from global variable.

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

### -EncryptKeyInLocalFile
-EncryptKeyInLocalFile
Store APIKey in encrypted value on local drive

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

### -MasterPassword
-MasterPassword SecureString{Password}
Use a passphrase for encryption purpose.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
