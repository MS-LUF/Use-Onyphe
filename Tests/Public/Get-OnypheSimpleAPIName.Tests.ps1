BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheSimpleAPIName' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				DataModel = [PSCustomObject]@{
					apis      = @(
						'user',
						'simple/ctl',
						'simple/geoloc',
						'simple/geoloc/best',
						'simple/resolver/forward',
						'simple/resolver/reverse',
						'simple/datascan/datamd5',
						'search/ctl'
					)
					filters   = @('ip')
					functions = @('exists')
				}
			}
		}
	}

	It 'returns plain simple/* apis with the prefix stripped' {
		$Result = Get-OnypheSimpleAPIName
		@($Result) | Should -Contain 'ctl'
		@($Result) | Should -Contain 'geoloc'
	}

	It 'excludes simple/*/best apis' {
		$Result = Get-OnypheSimpleAPIName
		@($Result) | Should -Not -Contain 'geoloc/best'
	}

	It 'renames simple/resolver/* to resolver<suffix>' {
		$Result = Get-OnypheSimpleAPIName
		@($Result) | Should -Contain 'resolverforward'
		@($Result) | Should -Contain 'resolverreverse'
	}

	It 'renames simple/datascan/* to datascan<suffix>' {
		$Result = Get-OnypheSimpleAPIName
		@($Result) | Should -Contain 'datascandatamd5'
	}

	It 'returns nothing when the data model has not been generated yet' {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{ DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null } }
		}

		Get-OnypheSimpleAPIName | Should -BeNullOrEmpty
	}
}
