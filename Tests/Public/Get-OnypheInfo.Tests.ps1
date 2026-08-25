BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheInfo' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheSimpleAPIName { @('geoloc', 'whois', 'bogus') }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Start-Sleep { }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheGeoloc { [PSCustomObject]@{ status = 'ok' } }
		Mock -ModuleName Use-Onyphe Invoke-APIBestOnypheGeoloc { [PSCustomObject]@{ status = 'ok-best' } }
	}

	It 'throws when -Category is omitted' {
		{ Get-OnypheInfo -SearchValue '8.8.8.8' } | Should -Throw
	}

	It 'throws when -SearchValue is omitted' {
		{ Get-OnypheInfo -Category geoloc } | Should -Throw
	}

	It 'dispatches to Invoke-APIOnypheGeoloc for -Category geoloc' {
		Get-OnypheInfo -SearchValue '8.8.8.8' -Category geoloc | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheGeoloc -Times 1 -Exactly -ParameterFilter {
			$IP -eq '8.8.8.8'
		}
	}

	It 'dispatches to Invoke-APIBestOnypheGeoloc when -Best is used' {
		Get-OnypheInfo -SearchValue '8.8.8.8' -Category geoloc -Best | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIBestOnypheGeoloc -Times 1 -Exactly
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheGeoloc -Times 0
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Get-OnypheInfo -SearchValue '8.8.8.8' -Category geoloc -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}

	It 'passes a single -Page value through' {
		Get-OnypheInfo -SearchValue '8.8.8.8' -Category geoloc -Page '2' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheGeoloc -Times 1 -Exactly -ParameterFilter {
			$Page -eq '2'
		}
	}

	It 'expands a -Page range into one call per page' {
		Get-OnypheInfo -SearchValue '8.8.8.8' -Category geoloc -Page '1-3' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheGeoloc -Times 3 -Exactly
	}

	It 'throws for a category with no corresponding Invoke-API* function' {
		{ Get-OnypheInfo -SearchValue '8.8.8.8' -Category bogus } | Should -Throw '*not implemented*'
	}

	It 'sleeps for -wait seconds before requesting' {
		Get-OnypheInfo -SearchValue '8.8.8.8' -Category geoloc -wait 3 | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Start-Sleep -Times 1 -Exactly -ParameterFilter {
			$Seconds -eq 3
		}
	}
}
