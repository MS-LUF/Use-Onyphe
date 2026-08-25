BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheSearchCategories' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				DataModel = [PSCustomObject]@{
					apis      = @('user', 'search', 'search/ctl', 'search/geoloc', 'simple/ctl')
					filters   = @('ip')
					functions = @('exists')
				}
			}
		}
	}

	It 'returns only the search/* apis with the prefix stripped' {
		$Result = Get-OnypheSearchCategories
		@($Result) | Should -Be @('ctl', 'geoloc')
	}

	It 'excludes the bare "search" entry (no trailing category)' {
		$Result = Get-OnypheSearchCategories
		@($Result) | Should -Not -Contain 'search'
	}

	It 'returns nothing when the data model has not been generated yet' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null } }
		}

		Get-OnypheSearchCategories | Should -BeNullOrEmpty
	}
}
