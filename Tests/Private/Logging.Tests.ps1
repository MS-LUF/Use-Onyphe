BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Private/Logging functions' -Tag 'Unit' {
	InModuleScope 'Use-Onyphe' {

		BeforeEach {
			$script:LoggingSinkFailed = $false
			$script:LoggingConfigWarned = $false
		}

		Context 'Resolve-OnypheLogFilePath' {
			It 'expands environment variables and date tokens, creating the directory' {
				$Dir = Join-Path $TestDrive 'LogsDir'
				$File = [PSCustomObject]@{ Path = $Dir; FileName = 'Use-Onyphe-{yyyyMMdd}.log' }

				$Result = Resolve-OnypheLogFilePath -File $File

				$Result | Should -Be (Join-Path $Dir "Use-Onyphe-$(Get-Date -Format 'yyyyMMdd').log")
				Test-Path $Dir | Should -BeTrue
			}
		}

		Context 'Write-OnypheFileLogEntry' {
			It 'appends a formatted line to the resolved log file' {
				$Dir = Join-Path $TestDrive 'FileLogs'
				$File = [PSCustomObject]@{ Path = $Dir; FileName = 'test.log' }
				$Entry = [PSCustomObject]@{ Timestamp = Get-Date '2026-01-01 10:00:00'; Level = 'Information'; UserName = 'tester'; CmdletName = 'Get-OnypheInfo'; Message = 'hello' }

				Write-OnypheFileLogEntry -File $File -Entry $Entry

				$Content = Get-Content (Join-Path $Dir 'test.log') -Raw
				$Content | Should -Match 'INFORMATION'
				$Content | Should -Match 'tester'
				$Content | Should -Match 'Get-OnypheInfo'
				$Content | Should -Match 'hello'
			}

			It 'never throws and warns once when resolving the log path fails' {
				Mock Resolve-OnypheLogFilePath { throw 'bad path' }
				$Entry = [PSCustomObject]@{ Timestamp = Get-Date; Level = 'Error'; UserName = 'tester'; CmdletName = 'X'; Message = 'boom' }

				{ Write-OnypheFileLogEntry -File ([PSCustomObject]@{ Path = 'x'; FileName = 'y' }) -Entry $Entry -WarningAction SilentlyContinue } | Should -Not -Throw
				$script:LoggingSinkFailed | Should -BeTrue
			}
		}

		Context 'Test-OnypheEventSourceExists' {
			It 'returns a boolean' {
				(Test-OnypheEventSourceExists -Source 'Application') | Should -BeOfType [bool]
			}
		}

		Context 'Write-OnypheEventLogEntry' {
			It 'warns once and skips when Write-EventLog is not available on this host' {
				Mock Get-Command { $null } -ParameterFilter { $Name -eq 'Write-EventLog' }

				$EventLog = [PSCustomObject]@{ LogName = 'Application'; Source = 'Use-Onyphe'; EventIdInformation = 1000; EventIdWarning = 2000; EventIdError = 3000 }
				$Entry = [PSCustomObject]@{ Timestamp = Get-Date; Level = 'Information'; UserName = 'tester'; CmdletName = 'X'; Message = 'hi' }

				{ Write-OnypheEventLogEntry -EventLog $EventLog -Entry $Entry -WarningAction SilentlyContinue } | Should -Not -Throw
				$script:LoggingSinkFailed | Should -BeTrue
			}
		}

		Context 'Write-OnypheLog' {
			It 'no-ops when logging is disabled (default)' {
				Mock Write-OnypheFileLogEntry { }
				Mock Write-OnypheEventLogEntry { }
				$Config = [PSCustomObject]@{ Logging = [PSCustomObject]@{ Enabled = $false } }

				Write-OnypheLog -Config $Config -Level Information -CmdletName 'X' -Message 'hi'

				Should -Invoke Write-OnypheFileLogEntry -Times 0
				Should -Invoke Write-OnypheEventLogEntry -Times 0
			}

			It 'no-ops when the entry level is below MinimumLevel' {
				Mock Write-OnypheFileLogEntry { }
				$Config = [PSCustomObject]@{ Logging = [PSCustomObject]@{ Enabled = $true; MinimumLevel = 'Warning'; Mode = 'File' } }

				Write-OnypheLog -Config $Config -Level Debug -CmdletName 'X' -Message 'hi'

				Should -Invoke Write-OnypheFileLogEntry -Times 0
			}

			It 'dispatches to Write-OnypheFileLogEntry when Mode is File and level meets MinimumLevel' {
				Mock Write-OnypheFileLogEntry { }
				$Config = [PSCustomObject]@{ Logging = [PSCustomObject]@{ Enabled = $true; MinimumLevel = 'Information'; Mode = 'File' } }

				Write-OnypheLog -Config $Config -Level Information -CmdletName 'X' -Message 'hi'

				Should -Invoke Write-OnypheFileLogEntry -Times 1 -Exactly
			}

			It 'dispatches to Write-OnypheEventLogEntry when Mode is EventLog' {
				Mock Write-OnypheEventLogEntry { }
				$Config = [PSCustomObject]@{ Logging = [PSCustomObject]@{ Enabled = $true; MinimumLevel = 'Information'; Mode = 'EventLog' } }

				Write-OnypheLog -Config $Config -Level Information -CmdletName 'X' -Message 'hi'

				Should -Invoke Write-OnypheEventLogEntry -Times 1 -Exactly
			}

			It 'redacts Credential/Password/Secret/Token/APIKey-named bound parameters' {
				Mock Write-OnypheFileLogEntry { }
				$Config = [PSCustomObject]@{ Logging = [PSCustomObject]@{ Enabled = $true; MinimumLevel = 'Debug'; Mode = 'File' } }
				$Bound = @{ APIKey = 'super-secret-key'; SearchValue = '9.9.9.9' }

				Write-OnypheLog -Config $Config -Level Debug -CmdletName 'X' -Message 'hi' -BoundParameters $Bound

				Should -Invoke Write-OnypheFileLogEntry -Times 1 -Exactly -ParameterFilter {
					($Entry.Message -notmatch 'super-secret-key') -and ($Entry.Message -match 'APIKey=<redacted>') -and ($Entry.Message -match 'SearchValue=9.9.9.9')
				}
			}

			It 'never throws even when Get-OnypheLoggingConfig fails' {
				Mock Get-OnypheLoggingConfig { throw 'boom' }
				$Config = [PSCustomObject]@{ Logging = [PSCustomObject]@{ Enabled = $true } }

				{ Write-OnypheLog -Config $Config -Level Information -CmdletName 'X' -Message 'hi' -WarningAction SilentlyContinue } | Should -Not -Throw
			}
		}
	}
}
