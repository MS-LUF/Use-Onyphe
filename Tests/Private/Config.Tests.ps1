BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Private/Config functions' -Tag 'Unit' {
	InModuleScope 'Use-Onyphe' {

		Context 'Get-OnypheConfigPath' {
			It 'returns Use-Onyphe\Use-Onyphe-Config.json under the user profile' {
				(Get-OnypheConfigPath) | Should -Be (Join-Path $home 'Use-Onyphe\Use-Onyphe-Config.json')
			}
		}

		Context 'Save-OnypheConfigFile / Read-OnypheConfigFile round-trip' {
			BeforeEach {
				$script:ConfigTestPath = Join-Path $TestDrive 'Use-Onyphe-Config.json'
				if (Test-Path $script:ConfigTestPath) { Remove-Item -Path $script:ConfigTestPath -Force }
				Mock Get-OnypheConfigPath { $script:ConfigTestPath }
			}

			It 'writes the config object as JSON, creating the containing directory' {
				$DeepPath = Join-Path $TestDrive 'nested\dir\Use-Onyphe-Config.json'
				Mock Get-OnypheConfigPath { $DeepPath }
				$Config = [PSCustomObject]@{ version = '1.0'; APIKey = [PSCustomObject]@{ Salt = 'abc'; EncryptedAPIKey = 'xyz' } }

				Save-OnypheConfigFile -Config $Config

				Test-Path $DeepPath | Should -BeTrue
				(Get-Content $DeepPath -Raw | ConvertFrom-Json).APIKey.Salt | Should -Be 'abc'
			}

			It 'reads back a previously saved config unchanged' {
				$Config = [PSCustomObject]@{
					version   = '1.0'
					APIKey    = [PSCustomObject]@{ Salt = 'abc'; EncryptedAPIKey = 'xyz' }
					DataModel = [PSCustomObject]@{ apis = @('a','b'); filters = @('f'); functions = @('fn') }
				}
				Save-OnypheConfigFile -Config $Config

				$Read = Read-OnypheConfigFile

				$Read.APIKey.Salt | Should -Be 'abc'
				@($Read.DataModel.apis) | Should -Be @('a','b')
			}

			It 'returns a default empty config when no JSON file and no legacy XML exists' {
				Mock ConvertFrom-OnypheLegacyConfig { $null }

				$Config = Read-OnypheConfigFile

				$Config.version | Should -Be '1.0'
				$Config.APIKey.EncryptedAPIKey | Should -BeNullOrEmpty
				$Config.DataModel.apis | Should -BeNullOrEmpty
			}

			It 'does not leave a temporary file behind after a successful write' {
				$DeepDir = Join-Path $TestDrive 'atomic-write-dir'
				$DeepPath = Join-Path $DeepDir 'Use-Onyphe-Config.json'
				Mock Get-OnypheConfigPath { $DeepPath }
				$Config = [PSCustomObject]@{ version = '1.0'; APIKey = [PSCustomObject]@{ Salt = 'abc'; EncryptedAPIKey = 'xyz' } }

				Save-OnypheConfigFile -Config $Config

				(Get-ChildItem -Path $DeepDir -Force).Name | Should -Be 'Use-Onyphe-Config.json'
			}

			It 'throws a descriptive error when the JSON file is corrupted' {
				Set-Content -Path $script:ConfigTestPath -Value '{ not valid json' -Encoding UTF8

				{ Read-OnypheConfigFile } | Should -Throw '*corrupted or not valid JSON*'
			}

			It 'migrates and persists a legacy config when the JSON file is missing but legacy data is found' {
				$Legacy = [PSCustomObject]@{
					version   = '1.0'
					APIKey    = [PSCustomObject]@{ Salt = 'legacy-salt'; EncryptedAPIKey = 'legacy-key' }
					Proxy     = [PSCustomObject]@{}
					DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null }
					Logging   = [PSCustomObject]@{}
				}
				Mock ConvertFrom-OnypheLegacyConfig { $Legacy }

				$Config = Read-OnypheConfigFile

				$Config.APIKey.Salt | Should -Be 'legacy-salt'
				Test-Path $script:ConfigTestPath | Should -BeTrue
			}
		}

		Context 'ConvertFrom-OnypheLegacyConfig' {
			It 'returns $null when neither legacy file exists' {
				Mock Test-Path { $false }

				ConvertFrom-OnypheLegacyConfig | Should -BeNullOrEmpty
			}

			It 'migrates the legacy API key file, base64-encoding the salt' {
				Mock Test-Path { $Path -like '*Use-Onyphe-Config.xml' }
				Mock Import-Clixml {
					if ($Path -like '*Use-Onyphe-Config.xml') {
						@{ Salt = [byte[]](1,2,3,4); EncryptedAPIKey = 'legacy-encrypted' }
					}
				}

				$Result = ConvertFrom-OnypheLegacyConfig

				$Result.APIKey.EncryptedAPIKey | Should -Be 'legacy-encrypted'
				$Result.APIKey.Salt | Should -Be ([Convert]::ToBase64String([byte[]](1,2,3,4)))
			}

			It 'migrates the legacy data-model file' {
				Mock Test-Path { $Path -like '*Onyphe-Data-Model.xml' }
				Mock Import-Clixml {
					if ($Path -like '*Onyphe-Data-Model.xml') {
						[PSCustomObject]@{ apis = @('a'); filters = @('f'); functions = @('fn') }
					}
				}

				$Result = ConvertFrom-OnypheLegacyConfig

				@($Result.DataModel.apis) | Should -Be @('a')
			}
		}

		Context 'Get-OnypheLoggingConfig' {
			It 'defaults to Enabled=$false, MinimumLevel=Information, Mode=File when Logging is absent' {
				$Config = [PSCustomObject]@{ version = '1.0' }

				$Logging = Get-OnypheLoggingConfig -Config $Config

				$Logging.Enabled | Should -BeFalse
				$Logging.MinimumLevel | Should -Be 'Information'
				$Logging.Mode | Should -Be 'File'
			}

			It 'honors an explicit Logging section' {
				$Config = [PSCustomObject]@{
					Logging = [PSCustomObject]@{
						Enabled      = $true
						MinimumLevel = 'Debug'
						Mode         = 'EventLog'
					}
				}

				$Logging = Get-OnypheLoggingConfig -Config $Config

				$Logging.Enabled | Should -BeTrue
				$Logging.MinimumLevel | Should -Be 'Debug'
				$Logging.Mode | Should -Be 'EventLog'
			}

			It 'falls back to Information for an unrecognized MinimumLevel and warns once' {
				$Config = [PSCustomObject]@{ Logging = [PSCustomObject]@{ MinimumLevel = 'Bogus' } }
				$script:LoggingConfigWarned = $false

				$Logging = Get-OnypheLoggingConfig -Config $Config -WarningVariable Warnings -WarningAction SilentlyContinue

				$Logging.MinimumLevel | Should -Be 'Information'
				@($Warnings).Count | Should -Be 1
			}
		}
	}
}
