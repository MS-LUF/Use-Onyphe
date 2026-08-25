BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheSimpleBestAPIName' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				DataModel = [PSCustomObject]@{
					apis      = @('user', 'simple/ctl', 'simple/geoloc', 'simple/geoloc/best', 'simple/inetnum/best')
					filters   = @('ip')
					functions = @('exists')
				}
			}
		}
	}

	It 'returns only simple/*/best apis with prefix and suffix stripped' {
		$Result = Get-OnypheSimpleBestAPIName
		@($Result) | Should -Be @('geoloc', 'inetnum')
	}

	It 'excludes plain simple/* apis without a /best suffix' {
		$Result = Get-OnypheSimpleBestAPIName
		@($Result) | Should -Not -Contain 'ctl'
	}

	It 'returns nothing when the data model has not been generated yet' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null } }
		}

		Get-OnypheSimpleBestAPIName | Should -BeNullOrEmpty
	}
}
