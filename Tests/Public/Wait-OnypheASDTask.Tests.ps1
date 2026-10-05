BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Wait-OnypheASDTask' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Get-OnypheASDTask { [PSCustomObject]@{ error = 0; results = @('final-result') } }
	}

	It 'returns the final result immediately, without polling, when the task is already finished' {
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskList {
			[PSCustomObject]@{ error = 0; results = @([PSCustomObject]@{ taskid = 'abc-123'; running = 'false' }) }
		}
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskPoll { [PSCustomObject]@{ error = 0 } }

		$Result = Wait-OnypheASDTask -TaskId 'abc-123'

		$Result.results | Should -Be 'final-result'
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskPoll -Times 0
		Should -Invoke -ModuleName Use-Onyphe Get-OnypheASDTask -Times 1 -Exactly -ParameterFilter {
			$TaskId -eq 'abc-123'
		}
	}

	It 'polls Invoke-APIOnypheASDTaskPoll and Invoke-APIOnypheASDTaskList while the task is still running, then fetches the result once finished' {
		Mock -ModuleName Use-Onyphe Start-Sleep { }
		$script:callCount = 0
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskList {
			$script:callCount++
			$running = if ($script:callCount -lt 3) { 'true' } else { 'false' }
			[PSCustomObject]@{ error = 0; results = @([PSCustomObject]@{ taskid = 'abc-123'; running = $running }) }
		}
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskPoll { [PSCustomObject]@{ error = 0 } }

		$Result = Wait-OnypheASDTask -TaskId 'abc-123' -PollIntervalSec 1

		$Result.results | Should -Be 'final-result'
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskList -Times 3 -Exactly
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskPoll -Times 2 -Exactly
		Should -Invoke -ModuleName Use-Onyphe Start-Sleep -Times 2 -Exactly -ParameterFilter {
			$Seconds -eq 1
		}
	}

	It 'falls back to Get-OnypheASDTask directly when the TaskId is not found in Get-OnypheASDTaskList' {
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskList {
			[PSCustomObject]@{ error = 0; results = @() }
		}
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskPoll { [PSCustomObject]@{ error = 0 } }

		$Result = Wait-OnypheASDTask -TaskId 'not-tracked'

		$Result.results | Should -Be 'final-result'
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskPoll -Times 0
		Should -Invoke -ModuleName Use-Onyphe Get-OnypheASDTask -Times 1 -Exactly -ParameterFilter {
			$TaskId -eq 'not-tracked'
		}
	}

	It 'gives up and returns the last Get-OnypheASDTaskList status with a warning after -TimeoutSec elapses' {
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskList {
			[PSCustomObject]@{ error = 0; results = @([PSCustomObject]@{ taskid = 'abc-123'; running = 'true' }) }
		}
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskPoll { [PSCustomObject]@{ error = 0 } }

		$warnings = Wait-OnypheASDTask -TaskId 'abc-123' -PollIntervalSec 1 -TimeoutSec 1 3>&1 |
			Where-Object { $_ -is [System.Management.Automation.WarningRecord] }

		$warnings.Count | Should -Be 1
		$warnings[0].Message | Should -Match 'timed out after 1 second'
		Should -Invoke -ModuleName Use-Onyphe Get-OnypheASDTask -Times 0
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDTaskList {
			[PSCustomObject]@{ error = 0; results = @([PSCustomObject]@{ taskid = 'abc-123'; running = 'false' }) }
		}

		Wait-OnypheASDTask -TaskId 'abc-123' -APIKey ('a' * 40) | Out-Null

		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}
}
