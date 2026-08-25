BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Set-OnypheAPIKey' -Tag 'Unit' {
	BeforeEach {
		$script:SavedAPIKey = $global:OnypheAPIKey
		$global:OnypheAPIKey = $null
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				version = '1.0'
				APIKey  = [PSCustomObject]@{ Salt = $null; EncryptedAPIKey = $null }
			}
		}
		Mock -ModuleName Use-Onyphe Save-OnypheConfigFile { }
	}

	AfterEach {
		$global:OnypheAPIKey = $script:SavedAPIKey
	}

	It 'sets $global:OnypheAPIKey when -APIKey is supplied without -EncryptKeyInLocalFile' {
		Set-OnypheAPIKey -APIKey ('a' * 40)
		$global:OnypheAPIKey | Should -Be ('a' * 40)
	}

	It 'does not write the config file when -EncryptKeyInLocalFile is not used' {
		Set-OnypheAPIKey -APIKey ('a' * 40)
		Should -Invoke -ModuleName Use-Onyphe Save-OnypheConfigFile -Times 0
	}

	It 'clears $global:OnypheAPIKey when -Remove is used' {
		$global:OnypheAPIKey = 'something'
		Set-OnypheAPIKey -Remove
		$global:OnypheAPIKey | Should -BeNullOrEmpty
	}

	It 'throws when -EncryptKeyInLocalFile is used without -MasterPassword' {
		{ Set-OnypheAPIKey -APIKey ('a' * 40) -EncryptKeyInLocalFile } | Should -Throw
	}

	It 'throws when -EncryptKeyInLocalFile is used without -APIKey' {
		$SecurePwd = ConvertTo-SecureString -String 'p@ss' -AsPlainText -Force
		{ Set-OnypheAPIKey -EncryptKeyInLocalFile -MasterPassword $SecurePwd } | Should -Throw
	}

	It 'saves a base64 32-byte Salt and a non-empty EncryptedAPIKey when both -APIKey and -MasterPassword are supplied' {
		$SecurePwd = ConvertTo-SecureString -String 'p@ss' -AsPlainText -Force
		Set-OnypheAPIKey -APIKey ('a' * 40) -EncryptKeyInLocalFile -MasterPassword $SecurePwd

		Should -Invoke -ModuleName Use-Onyphe Save-OnypheConfigFile -Times 1 -Exactly -ParameterFilter {
			$Config.APIKey.EncryptedAPIKey -and ([Convert]::FromBase64String($Config.APIKey.Salt)).Count -eq 32
		}
	}

	It 'does not set $global:OnypheAPIKey when -WhatIf is used' {
		Set-OnypheAPIKey -APIKey ('a' * 40) -WhatIf
		$global:OnypheAPIKey | Should -BeNullOrEmpty
	}

	It 'does not write the config file when -EncryptKeyInLocalFile is used with -WhatIf' {
		$SecurePwd = ConvertTo-SecureString -String 'p@ss' -AsPlainText -Force
		Set-OnypheAPIKey -APIKey ('a' * 40) -EncryptKeyInLocalFile -MasterPassword $SecurePwd -WhatIf
		Should -Invoke -ModuleName Use-Onyphe Save-OnypheConfigFile -Times 0
	}
}
