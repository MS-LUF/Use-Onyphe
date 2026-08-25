BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Import-OnypheEncryptedIKey' -Tag 'Unit' {
	BeforeAll {
		$script:PlainAPIKey = 'a' * 40
		$script:CorrectPassword = ConvertTo-SecureString -String 'CorrectHorseBatteryStaple' -AsPlainText -Force
		$script:WrongPassword = ConvertTo-SecureString -String 'WrongPassword' -AsPlainText -Force

		$SecureKeyString = ConvertTo-SecureString -String $script:PlainAPIKey -AsPlainText -Force
		$SaltBytes = New-Object byte[] 32
		(New-Object System.Security.Cryptography.RNGCryptoServiceProvider).GetBytes($SaltBytes)
		$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList 'user', $script:CorrectPassword
		$Rfc2898Deriver = New-Object System.Security.Cryptography.Rfc2898DeriveBytes -ArgumentList $Credentials.GetNetworkCredential().Password, $SaltBytes, 210000, ([System.Security.Cryptography.HashAlgorithmName]::SHA256)
		$KeyBytes = $Rfc2898Deriver.GetBytes(32)
		$script:EncryptedAPIKey = $SecureKeyString | ConvertFrom-SecureString -Key $KeyBytes
		$script:SaltBase64 = [Convert]::ToBase64String($SaltBytes)
	}

	BeforeEach {
		$script:SavedAPIKey = $global:OnypheAPIKey
		$global:OnypheAPIKey = $null
	}

	AfterEach {
		$global:OnypheAPIKey = $script:SavedAPIKey
	}

	It 'throws when no API key has been stored yet' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ APIKey = [PSCustomObject]@{ Salt = $null; EncryptedAPIKey = $null } }
		}

		{ Import-OnypheEncryptedIKey -MasterPassword $script:CorrectPassword } | Should -Throw '*Set-OnypheAPIKey*'
	}

	It 'decrypts and sets $global:OnypheAPIKey with the correct master password' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ APIKey = [PSCustomObject]@{ Salt = $script:SaltBase64; EncryptedAPIKey = $script:EncryptedAPIKey } }
		}

		Import-OnypheEncryptedIKey -MasterPassword $script:CorrectPassword

		$global:OnypheAPIKey | Should -Be $script:PlainAPIKey
	}

	It 'throws a descriptive error with the wrong master password' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ APIKey = [PSCustomObject]@{ Salt = $script:SaltBase64; EncryptedAPIKey = $script:EncryptedAPIKey } }
		}

		{ Import-OnypheEncryptedIKey -MasterPassword $script:WrongPassword } | Should -Throw '*passphrase*'
	}
}
