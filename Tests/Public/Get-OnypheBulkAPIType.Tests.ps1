BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheBulkAPIType' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				DataModel = [PSCustomObject]@{
					apis      = @(
						'user',
						'simple/ctl',
						'bulk/simple/ctl/ip',
						'bulk/simple/geoloc/ip',
						'bulk/simple/geoloc/best/ip',
						'bulk/summary/ip',
						'bulk/summary/domain'
					)
					filters   = @('ip')
					functions = @('exists')
				}
			}
		}
	}

	It 'extracts the unique bulk API type (second path segment) from every bulk/* entry' {
		$Result = @(Get-OnypheBulkAPIType)
		$Result | Should -Contain 'simple'
		$Result | Should -Contain 'summary'
	}

	It 'de-duplicates repeated bulk API types' {
		$Result = @(Get-OnypheBulkAPIType)
		($Result | Where-Object { $_ -eq 'simple' }).Count | Should -Be 1
	}

	It 'returns nothing when the data model has not been generated yet' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null } }
		}

		Get-OnypheBulkAPIType | Should -BeNullOrEmpty
	}
}
