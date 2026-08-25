	Function Set-OnypheAPIKey {
  <#
		.SYNOPSIS 
		set and remove onyphe API key as global variable

		.DESCRIPTION
		set and remove onyphe API key as global variable
		
		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.

		.PARAMETER MasterPassword
		-MasterPassword SecureString{Password}
		Use a passphrase for encryption purpose.

		.PARAMETER EncryptKeyInLocalFile
		-EncryptKeyInLocalFile
		Store APIKey in encrypted value on local drive
		
		.PARAMETER Remove
		-Remove
		Remove your current APIKEY from global variable.
		
		.OUTPUTS
		none
		
		.EXAMPLE
		Set your API key as global variable so it will be used automatically by all use-onyphe functions
		C:\PS> Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		
		.EXAMPLE
		Remove your API key set as global variable
		C:\PS> Set-OnypheAPIKey -remove

		.EXAMPLE
		Store your API key on hard drive
		C:\PS> Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -MasterPassword (ConvertTo-SecureString -String "YourP@ssw0rd" -AsPlainText -Force) -EncryptKeyInLocalFile
  #>
  [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
  Param (
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$Remove,
		[parameter(Mandatory=$false)]
			[switch]$EncryptKeyInLocalFile,
		[parameter(Mandatory=$false)]
			[securestring]$MasterPassword
  )
  process {
	$Config = Read-OnypheConfigFile
	Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
	if ($Remove.IsPresent) {
		if ($PSCmdlet.ShouldProcess('Use-Onyphe session API key', 'Remove')) {
			$global:OnypheAPIKey = $Null
		}
	  } Else {
		if ($PSCmdlet.ShouldProcess('Use-Onyphe session API key', 'Set')) {
			$global:OnypheAPIKey = $APIKey
			If ($EncryptKeyInLocalFile.IsPresent) {
				If (!$MasterPassword -or !$APIKey) {
					Write-warning "Please provide a valid Master Password to protect the API Key storage on disk and a valid API Key"
					throw 'no api key or master password'
				} ElseIf ($PSCmdlet.ShouldProcess('local configuration file', 'Write encrypted API key')) {
					[Security.SecureString]$SecureKeyString = ConvertTo-SecureString -String $APIKey -AsPlainText -Force
					$SaltBytes = New-Object byte[] 32
					$RNG = New-Object System.Security.Cryptography.RNGCryptoServiceProvider
					$RNG.GetBytes($SaltBytes)
					$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $MasterPassword
					$Rfc2898Deriver = New-Object System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $SaltBytes, 210000, ([System.Security.Cryptography.HashAlgorithmName]::SHA256)
					$KeyBytes  = $Rfc2898Deriver.GetBytes(32)
					$EncryptedString = $SecureKeyString | ConvertFrom-SecureString -key $KeyBytes
					$Config.APIKey = [PSCustomObject]@{
						Salt            = [Convert]::ToBase64String($SaltBytes)
						EncryptedAPIKey = $EncryptedString
					}
					Save-OnypheConfigFile -Config $Config
					Write-OnypheLog -Config $Config -Level Information -CmdletName $MyInvocation.MyCommand.Name -Message 'API key encrypted and saved to local configuration file'
				}
			}
		}
	  }
  }
	}
