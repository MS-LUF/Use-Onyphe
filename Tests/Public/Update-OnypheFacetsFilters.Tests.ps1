BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Update-OnypheFacetsFilters' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile {
			[PSCustomObject]@{
				version   = '1.0'
				DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null }
			}
		}
		Mock -ModuleName Use-Onyphe Save-OnypheConfigFile { }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Get-OnypheUserInfo {
			[PSCustomObject]@{
				results = [PSCustomObject]@{
					apis      = @('user', 'simple/ctl')
					filters   = @('ip')
					functions = @('exists')
				}
			}
		}
	}

	It 'writes apis/filters/functions from Get-OnypheUserInfo into Config.DataModel' {
		Update-OnypheFacetsFilters

		Should -Invoke -ModuleName Use-Onyphe Save-OnypheConfigFile -Times 1 -Exactly -ParameterFilter {
			(@($Config.DataModel.apis) -join ',') -eq 'user,simple/ctl' -and
			(@($Config.DataModel.filters) -join ',') -eq 'ip' -and
			(@($Config.DataModel.functions) -join ',') -eq 'exists'
		}
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Update-OnypheFacetsFilters -APIKey ('a' * 40)

		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}

	It 'does not call Set-OnypheAPIKey when -APIKey is omitted' {
		Update-OnypheFacetsFilters

		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 0
	}

	It 'passes -UseBetaFeatures through to Get-OnypheUserInfo' {
		Update-OnypheFacetsFilters -UseBetaFeatures

		Should -Invoke -ModuleName Use-Onyphe Get-OnypheUserInfo -Times 1 -Exactly -ParameterFilter {
			$UseBetaFeatures -eq $true
		}
	}

	It 'does not write the config file when -WhatIf is used' {
		Update-OnypheFacetsFilters -WhatIf

		Should -Invoke -ModuleName Use-Onyphe Save-OnypheConfigFile -Times 0
	}
}
