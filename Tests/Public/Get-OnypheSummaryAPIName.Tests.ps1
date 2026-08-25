BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheSummaryAPIName' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				DataModel = [PSCustomObject]@{
					apis      = @('user', 'summary/ip', 'summary/domain', 'summary/hostname', 'simple/ctl')
					filters   = @('ip')
					functions = @('exists')
				}
			}
		}
	}

	It 'returns only summary/* apis with the prefix stripped' {
		$Result = Get-OnypheSummaryAPIName
		@($Result) | Should -Be @('ip', 'domain', 'hostname')
	}

	It 'returns nothing when the data model has not been generated yet' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null } }
		}

		Get-OnypheSummaryAPIName | Should -BeNullOrEmpty
	}
}
