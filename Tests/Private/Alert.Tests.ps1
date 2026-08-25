BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Private/Alert wrappers' -Tag 'Unit' {
	InModuleScope 'Use-Onyphe' {

		BeforeEach {
			$script:SavedAPIKey = $global:OnypheAPIKey
			$global:OnypheAPIKey = $null
		}

		AfterEach {
			$global:OnypheAPIKey = $script:SavedAPIKey
		}

		Context 'Invoke-APIOnypheListAlert' {
			It 'calls Invoke-OnypheAPIV2 with the alert/list request' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheListAlert | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($request -eq 'v2/alert/list/') -and
					($APIInfo -eq 'alert/list') -and
					($APIInput -eq 'none') -and
					($APIKeyrequired -eq $true)
				}
			}

			It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }
				Mock Set-OnypheAPIKey { }

				Invoke-APIOnypheListAlert -APIKey ('x' * 40) | Out-Null

				Should -Invoke Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
					$APIKey -eq ('x' * 40)
				}
			}
		}

		Context 'Invoke-APIOnypheDelAlert' {
			It 'calls Invoke-OnypheAPIV2 with a POST to alert/del/<AlertID>' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheDelAlert -AlertID '123' | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($request -eq 'v2/alert/del/123') -and
					($APIInfo -eq 'alert/del') -and
					($APIInput -eq '123') -and
					($Method -eq 'POST') -and
					($APIKeyrequired -eq $true)
				}
			}

			It 'does not call Invoke-OnypheAPIV2 when -WhatIf is used' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheDelAlert -AlertID '123' -WhatIf | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 0
			}
		}

		Context 'Invoke-APIOnypheAddAlert' {
			It 'builds the alert/add JSON body from AlertName/AlertEmail/SearchValue/SearchFilter' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheAddAlert -AlertName 'My Alert' -AlertEmail 'alert@example.com' -SearchType 'threatlist' -SearchValue 'RU' -SearchFilter 'country' | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					$body = $data | ConvertFrom-Json
					($request -eq 'v2/alert/add/') -and
					($APIInfo -eq 'alert/add') -and
					($APIKeyrequired -eq $true) -and
					($body.name -eq 'My Alert') -and
					($body.email -eq 'alert@example.com') -and
					($body.query -eq 'category:threatlist country:RU')
				}
			}

			It 'does not throw when an -AdvancedFilter entry has no colon' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				{ Invoke-APIOnypheAddAlert -AlertName 'My Alert' -AlertEmail 'alert@example.com' -SearchType 'datascan' -AdvancedSearch @('port:443') -AdvancedFilter @('exists') } | Should -Not -Throw
			}

			It 'does not call Invoke-OnypheAPIV2 when -WhatIf is used' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheAddAlert -AlertName 'My Alert' -AlertEmail 'alert@example.com' -SearchType 'threatlist' -SearchValue 'RU' -SearchFilter 'country' -WhatIf | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 0
			}
		}
	}
}
