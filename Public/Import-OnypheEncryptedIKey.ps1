	Function Import-OnypheEncryptedIKey {
  <#
		.SYNOPSIS 
		import onyphe API key as global variable from encrypted local config file

		.DESCRIPTION
		import onyphe API key as global variable from encrypted local config file
		
		.PARAMETER MasterPassword
		-MasterPassword SecureString{Password}
		Use a passphrase for encryption purpose.
		
		.OUTPUTS
		none
		
		.EXAMPLE
		set API Key as global variable using encrypted key hosted in local xml file previously generated with Set-OnypheAPIKey
		C:\PS> Import-OnypheEncryptedIKey -MasterPassword (ConvertTo-SecureString -String "YourP@ssw0rd" -AsPlainText -Force)
  #>
    [CmdletBinding()]
    Param(
      [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
        [securestring]$MasterPassword
	)
	process {
		$Config = Read-OnypheConfigFile
		Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
        if (!$Config.APIKey -or !$Config.APIKey.EncryptedAPIKey) {
			throw 'Configuration file has not been set, Set-OnypheAPIKey to configure the API Keys.'
        }
        $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword
		try {
			$SaltBytes = [Convert]::FromBase64String($Config.APIKey.Salt)
			$Rfc2898Deriver = New-Object System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $SaltBytes, 210000, ([System.Security.Cryptography.HashAlgorithmName]::SHA256)
			$KeyBytes  = $Rfc2898Deriver.GetBytes(32)
			$SecString = ConvertTo-SecureString -Key $KeyBytes $Config.APIKey.EncryptedAPIKey
			$SecureStringToBSTR = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecString)
			$APIKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto($SecureStringToBSTR)
			$global:OnypheAPIKey = $APIKey
			Write-OnypheLog -Config $Config -Level Information -CmdletName $MyInvocation.MyCommand.Name -Message 'API key loaded from local configuration file'
		} catch {
			throw "Not able to set correctly your API Key, your passphrase my be incorrect"
			write-error -message "Error Type: $($_.Exception.GetType().FullName)"
			write-error -message "Error Message: $($_.Exception.Message)"
		}
	}
	}
