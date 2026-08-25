BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheSummary' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheSummaryAPIName { @('ip', 'domain', 'bogus') }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Start-Sleep { }
		Mock -ModuleName Use-Onyphe Invoke-APISummaryOnypheIP { [PSCustomObject]@{ status = 'ok' } }
	}

	It 'dispatches to Invoke-APISummaryOnypheIP for -SummaryAPIType ip' {
		Get-OnypheSummary -SearchValue '8.8.8.8' -SummaryAPIType ip | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APISummaryOnypheIP -Times 1 -Exactly -ParameterFilter {
			$IP -eq '8.8.8.8'
		}
	}

	It 'accepts -SearchValue from the pipeline' {
		'8.8.8.8' | Get-OnypheSummary -SummaryAPIType ip | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APISummaryOnypheIP -Times 1 -Exactly -ParameterFilter {
			$IP -eq '8.8.8.8'
		}
	}

	It 'sleeps for -wait seconds before requesting' {
		Get-OnypheSummary -SearchValue '8.8.8.8' -SummaryAPIType ip -wait 3 | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Start-Sleep -Times 1 -Exactly -ParameterFilter {
			$Seconds -eq 3
		}
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Get-OnypheSummary -SearchValue '8.8.8.8' -SummaryAPIType ip -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}

	It 'passes a single -Page value through' {
		Get-OnypheSummary -SearchValue '8.8.8.8' -SummaryAPIType ip -Page '2' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APISummaryOnypheIP -Times 1 -Exactly -ParameterFilter {
			$Page -eq '2'
		}
	}

	It 'expands a -Page range into one call per page' {
		Get-OnypheSummary -SearchValue '8.8.8.8' -SummaryAPIType ip -Page '1-2' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APISummaryOnypheIP -Times 2 -Exactly
	}

	It 'throws for a summary type with no corresponding Invoke-API* function' {
		{ Get-OnypheSummary -SearchValue '8.8.8.8' -SummaryAPIType bogus } | Should -Throw '*not implemented*'
	}
}
