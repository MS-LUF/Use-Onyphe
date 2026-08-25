BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheSearchFilters' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				DataModel = [PSCustomObject]@{
					apis      = @('user', 'simple/ctl', 'search/ctl')
					filters   = @('ip', 'port', 'tag')
					functions = @('exists', 'wildcard', 'sort')
				}
			}
		}
	}

	It 'returns the filters array from the cached data model' {
		$Result = Get-OnypheSearchFilters
		@($Result) | Should -Be @('ip', 'port', 'tag')
	}

	It 'returns nothing when the data model has not been generated yet' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null } }
		}

		Get-OnypheSearchFilters | Should -BeNullOrEmpty
	}
}
