BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheASDTask' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Start-Sleep { }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskId { [PSCustomObject]@{ error = 0 } }
	}

	It 'dispatches to Invoke-APIOnypheASDTaskId with -TaskId' {
		Get-OnypheASDTask -TaskId 'abc-123' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskId -Times 1 -Exactly -ParameterFilter {
			$TaskId -eq 'abc-123'
		}
	}

	It 'accepts -TaskId from the pipeline' {
		'abc-123' | Get-OnypheASDTask | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskId -Times 1 -Exactly -ParameterFilter {
			$TaskId -eq 'abc-123'
		}
	}

	It 'sleeps for -wait seconds before requesting' {
		Get-OnypheASDTask -TaskId 'abc-123' -wait 3 | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Start-Sleep -Times 1 -Exactly -ParameterFilter {
			$Seconds -eq 3
		}
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Get-OnypheASDTask -TaskId 'abc-123' -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}
}
