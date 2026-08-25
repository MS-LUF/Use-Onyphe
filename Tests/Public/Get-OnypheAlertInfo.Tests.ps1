BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheAlertInfo' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheListAlert {
			[PSCustomObject]@{
				results = @(
					[PSCustomObject]@{ name = 'alert-one'; email = 'a@x.com'; id = 1 },
					[PSCustomObject]@{ name = 'alert-two'; email = 'b@x.com'; id = 2 }
				)
			}
		}
	}

	It 'returns the raw results object unfiltered when -SearchValue is omitted' {
		$Result = Get-OnypheAlertInfo
		$Result.results.Count | Should -Be 2
		$Result.PSObject.Properties.Name | Should -Not -Contain 'cli-Filtered_Results'
	}

	It 'filters on name (the default -SearchFilter) with the eq operator by default' {
		$Result = Get-OnypheAlertInfo -SearchValue 'alert-two'
		$Result.'cli-Filtered_Results'.id | Should -Be 2
	}

	It 'filters on -SearchFilter email when specified' {
		$Result = Get-OnypheAlertInfo -SearchValue 'a@x.com' -SearchFilter email
		$Result.'cli-Filtered_Results'.name | Should -Be 'alert-one'
	}

	It 'supports the like operator with wildcards' {
		$Result = Get-OnypheAlertInfo -SearchValue 'alert-*' -SearchOperator like
		@($Result.'cli-Filtered_Results').Count | Should -Be 2
	}

	It 'supports the ne operator' {
		$Result = Get-OnypheAlertInfo -SearchValue 'alert-one' -SearchOperator ne
		$Result.'cli-Filtered_Results'.name | Should -Be 'alert-two'
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Get-OnypheAlertInfo -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}

	It 'passes -UseBetaFeatures through to Invoke-APIOnypheListAlert' {
		Get-OnypheAlertInfo -UseBetaFeatures | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheListAlert -Times 1 -Exactly -ParameterFilter {
			$UseBetaFeatures -eq $true
		}
	}
}
