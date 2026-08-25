BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheDiscoveryCategories' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				DataModel = [PSCustomObject]@{
					apis      = @(
						'user',
						'bulk/simple/ctl/ip',
						'bulk/discovery/datascan/asset',
						'bulk/discovery/resolver/asset',
						'bulk/discovery/vulnscan/asset'
					)
					filters   = @('ip')
					functions = @('exists')
				}
			}
		}
	}

	It 'extracts the unique discovery category (third path segment) from bulk/discovery/* entries' {
		$Result = @(Get-OnypheDiscoveryCategories)
		$Result | Should -Contain 'datascan'
		$Result | Should -Contain 'resolver'
		$Result | Should -Contain 'vulnscan'
	}

	It 'excludes bulk/simple/* entries (not bulk/discovery/*)' {
		$Result = @(Get-OnypheDiscoveryCategories)
		$Result | Should -Not -Contain 'ctl'
	}

	It 'returns nothing when no bulk/discovery/* entry is present (e.g. no Griffin View subscription)' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				DataModel = [PSCustomObject]@{
					apis      = @('user', 'bulk/simple/ctl/ip')
					filters   = @('ip')
					functions = @('exists')
				}
			}
		}

		Get-OnypheDiscoveryCategories | Should -BeNullOrEmpty
	}

	It 'returns nothing when the data model has not been generated yet' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null } }
		}

		Get-OnypheDiscoveryCategories | Should -BeNullOrEmpty
	}
}
