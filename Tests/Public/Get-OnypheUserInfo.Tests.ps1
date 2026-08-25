BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheUserInfo' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheUser { [PSCustomObject]@{ status = 'ok' } }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
	}

	It 'calls Invoke-APIOnypheUser with no parameters by default' {
		Get-OnypheUserInfo | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheUser -Times 1 -Exactly -ParameterFilter {
			$PSBoundParameters.Count -eq 0
		}
	}

	It 'passes -UseBetaFeatures through to Invoke-APIOnypheUser' {
		Get-OnypheUserInfo -UseBetaFeatures | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheUser -Times 1 -Exactly -ParameterFilter {
			$UseBetaFeatures -eq $true
		}
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Get-OnypheUserInfo -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}

	It 'returns the object from Invoke-APIOnypheUser' {
		$Result = Get-OnypheUserInfo
		$Result.status | Should -Be 'ok'
	}
}
