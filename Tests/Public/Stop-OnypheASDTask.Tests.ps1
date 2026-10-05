BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Stop-OnypheASDTask' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Start-Sleep { }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskKill { [PSCustomObject]@{ error = 0 } }
	}

	It 'dispatches to Invoke-APIOnypheASDTaskKill with -TaskId when confirmed' {
		Stop-OnypheASDTask -TaskId 'abc-123' -Confirm:$false | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskKill -Times 1 -Exactly -ParameterFilter {
			$TaskId -eq 'abc-123'
		}
	}

	It 'accepts -TaskId from the pipeline' {
		'abc-123' | Stop-OnypheASDTask -Confirm:$false | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskKill -Times 1 -Exactly -ParameterFilter {
			$TaskId -eq 'abc-123'
		}
	}

	It 'does not kill the task when -WhatIf is used' {
		Stop-OnypheASDTask -TaskId 'abc-123' -WhatIf | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskKill -Times 0
	}

	It 'sleeps for -wait seconds before requesting' {
		Stop-OnypheASDTask -TaskId 'abc-123' -wait 3 -Confirm:$false | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Start-Sleep -Times 1 -Exactly -ParameterFilter {
			$Seconds -eq 3
		}
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Stop-OnypheASDTask -TaskId 'abc-123' -APIKey ('a' * 40) -Confirm:$false | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}
}
