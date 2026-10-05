BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheASDTaskList' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Start-Sleep { }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskList { [PSCustomObject]@{ error = 0; results = @() } }
	}

	It 'dispatches to Invoke-APIOnypheASDTaskList with no arguments' {
		Get-OnypheASDTaskList | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskList -Times 1 -Exactly
	}

	It 'sleeps for -wait seconds before requesting' {
		Get-OnypheASDTaskList -wait 3 | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Start-Sleep -Times 1 -Exactly -ParameterFilter {
			$Seconds -eq 3
		}
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Get-OnypheASDTaskList -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}
}
