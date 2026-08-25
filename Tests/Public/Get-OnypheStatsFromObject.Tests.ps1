BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheStatsFromObject' -Tag 'Unit' {
	BeforeAll {
		$script:SampleInput = [PSCustomObject]@{
			results = @(
				[PSCustomObject]@{ ip = '1.1.1.1'; port = 80 },
				[PSCustomObject]@{ ip = '1.1.1.1'; port = 443 },
				[PSCustomObject]@{ ip = '2.2.2.2'; port = 80 }
			)
		}
	}

	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheCliFacets { @('ip', 'port', 'tag') }
	}

	It 'computes Count/Sum/Min/Max/Average for a single -Facets value' {
		$Result = Get-OnypheStatsFromObject -InputOnypheObject $script:SampleInput -Facets ip

		$Result.Count | Should -Be 2
		$Result.Sum | Should -Be 3
		$Result.Min | Should -Be 1
		$Result.Max | Should -Be 2
		$Result.Average | Should -Be 1.5
	}

	It 'tags each stat entry with the requested facet name' {
		$Result = Get-OnypheStatsFromObject -InputOnypheObject $script:SampleInput -Facets ip
		($Result.Stats | Select-Object -ExpandProperty 'Onyphe-Facet' -Unique) | Should -Be 'ip'
	}

	It 'returns one result object per facet when -AdvancedFacets is used' {
		$Result = @(Get-OnypheStatsFromObject -InputOnypheObject $script:SampleInput -AdvancedFacets @('ip', 'port'))
		$Result.Count | Should -Be 2
		($Result[0].Stats | Select-Object -First 1 -ExpandProperty 'Onyphe-Facet') | Should -Be 'ip'
		($Result[1].Stats | Select-Object -First 1 -ExpandProperty 'Onyphe-Facet') | Should -Be 'port'
	}

	It 'throws when neither -Facets nor -AdvancedFacets is supplied' {
		{ Get-OnypheStatsFromObject -InputOnypheObject $script:SampleInput } | Should -Throw
	}
}
