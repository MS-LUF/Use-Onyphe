BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheBulkCategories' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				DataModel = [PSCustomObject]@{
					apis      = @(
						'user',
						'bulk/simple/ctl/ip',
						'bulk/simple/geoloc/ip',
						'bulk/simple/geoloc/best/ip',
						'bulk/summary/ip'
					)
					filters   = @('ip')
					functions = @('exists')
				}
			}
		}
	}

	It 'extracts the unique bulk simple category (third path segment) from bulk/simple/* entries' {
		$Result = @(Get-OnypheBulkCategories)
		$Result | Should -Contain 'ctl'
		$Result | Should -Contain 'geoloc'
	}

	It 'excludes bulk/summary/* entries (not bulk/simple/*)' {
		$Result = @(Get-OnypheBulkCategories)
		$Result | Should -Not -Contain 'ip'
	}

	It 'de-duplicates repeated categories' {
		$Result = @(Get-OnypheBulkCategories)
		($Result | Where-Object { $_ -eq 'geoloc' }).Count | Should -Be 1
	}

	It 'returns nothing when the data model has not been generated yet' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null } }
		}

		Get-OnypheBulkCategories | Should -BeNullOrEmpty
	}
}
