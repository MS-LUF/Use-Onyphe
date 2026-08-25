BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Search-OnypheInfo' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchCategories { @('datascan', 'threatlist') }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchFilters { @('country', 'port') }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchFunctions { @('monthago', 'exists') }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Start-Sleep { }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheSearch { [PSCustomObject]@{ status = 'ok' } }
	}

	It 'passes -AdvancedSearch through to Invoke-APIOnypheSearch' {
		Search-OnypheInfo -AdvancedSearch @('country:RU', 'port:443') -Category datascan | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheSearch -Times 1 -Exactly -ParameterFilter {
			(@($AdvancedSearch) -join ',') -eq 'country:RU,port:443'
		}
	}

	It 'passes -SearchValue/-SearchFilter through to Invoke-APIOnypheSearch' {
		Search-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheSearch -Times 1 -Exactly -ParameterFilter {
			($SearchValue -eq 'RU') -and ($SearchFilter -eq 'country')
		}
	}

	It 'throws when -SearchFilter is used without -SearchValue or -AdvancedSearch' {
		{ Search-OnypheInfo -Category threatlist -SearchFilter country } | Should -Throw '*SearchValue*'
	}

	It 'throws when -FilterFunction is used without -FilterValue' {
		{ Search-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country -FilterFunction monthago } | Should -Throw '*FilterValue*'
	}

	It 'passes -UseBetaFeatures through to Invoke-APIOnypheSearch' {
		Search-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country -UseBetaFeatures | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheSearch -Times 1 -Exactly -ParameterFilter {
			$UseBetaFeatures -eq $true
		}
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Search-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}

	It 'expands a -Page range into one call per page' {
		Search-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country -Page '1-2' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheSearch -Times 2 -Exactly
	}

	It 'accepts -SearchValue from the pipeline' {
		'OVH SAS' | Search-OnypheInfo -SearchFilter country -Category threatlist | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheSearch -Times 1 -Exactly -ParameterFilter {
			$SearchValue -eq 'OVH SAS'
		}
	}

	It 'sleeps for -wait seconds before requesting' {
		Search-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country -wait 3 | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Start-Sleep -Times 1 -Exactly -ParameterFilter {
			$Seconds -eq 3
		}
	}

	It 'passes -Size through to Invoke-APIOnypheSearch' {
		Search-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country -Size 500 | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheSearch -Times 1 -Exactly -ParameterFilter {
			$Size -eq 500
		}
	}

	It 'passes -TrackQuery and -Calculated through to Invoke-APIOnypheSearch' {
		Search-OnypheInfo -SearchValue 'RU' -Category threatlist -SearchFilter country -TrackQuery -Calculated | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheSearch -Times 1 -Exactly -ParameterFilter {
			($TrackQuery -eq $true) -and ($Calculated -eq $true)
		}
	}
}
