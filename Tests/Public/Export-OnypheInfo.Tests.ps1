BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Export-OnypheInfo' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchCategories { @('datascan', 'threatlist') }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchFilters { @('country', 'port') }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchFunctions { @('monthago', 'exists') }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheExport { [PSCustomObject]@{ status = 'ok' } }
	}

	It 'builds params from -SearchValue/-SearchFilter and passes -OutFile' {
		Export-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country -SaveInfoAsFile 'out.json' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheExport -Times 1 -Exactly -ParameterFilter {
			($SearchValue -eq 'RU') -and ($SearchFilter -eq 'country') -and ($OutFile -eq 'out.json')
		}
	}

	It 'builds params from -AdvancedSearch' {
		Export-OnypheInfo -AdvancedSearch @('country:RU', 'port:443') -Category datascan -SaveInfoAsFile 'out.json' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheExport -Times 1 -Exactly -ParameterFilter {
			(@($AdvancedSearch) -join ',') -eq 'country:RU,port:443'
		}
	}

	It 'throws when neither -SearchValue/-AdvancedSearch nor -Category is supplied' {
		{ Export-OnypheInfo -SaveInfoAsFile 'out.json' } | Should -Throw '*mandatory*'
	}

	It 'builds params from -InputOnypheObject.cli-func_input, dropping any Page key' {
		$InputObj = [PSCustomObject]@{
			'cli-func_input' = @{ SearchType = 'threatlist'; SearchValue = 'RU'; Page = '2' }
		}
		Export-OnypheInfo -InputOnypheObject $InputObj -SaveInfoAsFile 'out.json' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheExport -Times 1 -Exactly -ParameterFilter {
			($SearchValue -eq 'RU') -and (-not $PSBoundParameters.ContainsKey('Page'))
		}
	}

	It 'throws when -InputOnypheObject is missing cli-func_input' {
		$InputObj = [PSCustomObject]@{ results = @() }
		{ Export-OnypheInfo -InputOnypheObject $InputObj -SaveInfoAsFile 'out.json' } | Should -Throw '*cli-func_input*'
	}

	It 'accepts a Search-OnypheInfo-shaped object from the pipeline' {
		$InputObj = [PSCustomObject]@{
			'cli-func_input' = @{ SearchType = 'threatlist'; SearchValue = 'RU' }
		}
		$InputObj | Export-OnypheInfo -SaveInfoAsFile 'out.json' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheExport -Times 1 -Exactly -ParameterFilter {
			$SearchValue -eq 'RU'
		}
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Export-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country -APIKey ('a' * 40) -SaveInfoAsFile 'out.json' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}

	It 'passes -TrackQuery and -Calculated through to Invoke-APIOnypheExport' {
		Export-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country -TrackQuery -Calculated -SaveInfoAsFile 'out.json' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheExport -Times 1 -Exactly -ParameterFilter {
			($TrackQuery -eq $true) -and ($Calculated -eq $true)
		}
	}
}
