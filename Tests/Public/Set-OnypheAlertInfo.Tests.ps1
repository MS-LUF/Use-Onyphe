BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Set-OnypheAlertInfo' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchCategories { @('datascan', 'threatlist') }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchFilters { @('country', 'port') }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchFunctions { @('monthago', 'exists') }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheAddAlert { [PSCustomObject]@{ status = 'added' } }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheDelAlert { [PSCustomObject]@{ status = 'deleted' } }
	}

	Context 'AlertAction new' {
		BeforeEach {
			Mock -ModuleName Use-Onyphe Get-OnypheAlertInfo { [PSCustomObject]@{ 'cli-Filtered_Results' = $null } }
		}

		It 'creates the alert when no existing alert has that name' {
			Set-OnypheAlertInfo -SearchValue 'RU' -SearchType threatlist -SearchFilter country -AlertAction new -AlertName 'from russia' -AlertMail 'a@x.com' | Out-Null
			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheAddAlert -Times 1 -Exactly -ParameterFilter {
				($AlertName -eq 'from russia') -and ($AlertEmail -eq 'a@x.com')
			}
		}

		It 'throws when -AlertMail is missing' {
			{ Set-OnypheAlertInfo -SearchValue 'RU' -SearchType threatlist -SearchFilter country -AlertAction new -AlertName 'from russia' } | Should -Throw '*mail address*'
		}

		It 'throws when neither search criteria nor -InputOnypheObject is supplied' {
			{ Set-OnypheAlertInfo -AlertAction new -AlertName 'from russia' -AlertMail 'a@x.com' } | Should -Throw '*search request*'
		}

		It 'does not create the alert when -WhatIf is used' {
			Set-OnypheAlertInfo -SearchValue 'RU' -SearchType threatlist -SearchFilter country -AlertAction new -AlertName 'from russia' -AlertMail 'a@x.com' -WhatIf | Out-Null
			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheAddAlert -Times 0
		}

		It 'creates the alert from -InputOnypheObject (an imported Search-OnypheInfo-shaped result)' {
			$InputObj = [PSCustomObject]@{
				'cli-func_input' = @{ SearchType = 'datascan'; AdvancedSearch = @('country:RU', 'port:3389') }
			}
			Set-OnypheAlertInfo -AlertAction new -AlertName 'RandR' -AlertMail 'robert.lespinasse@lesbronzesfontdusk.io' -InputOnypheObject $InputObj | Out-Null
			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheAddAlert -Times 1 -Exactly -ParameterFilter {
				($AlertName -eq 'RandR') -and ((@($AdvancedSearch) -join ',') -eq 'country:RU,port:3389')
			}
		}

		It 'creates the alert from a Search-OnypheInfo-shaped object piped in' {
			$InputObj = [PSCustomObject]@{
				'cli-func_input' = @{ SearchType = 'datascan'; AdvancedSearch = @('country:RU', 'port:3389') }
			}
			$InputObj | Set-OnypheAlertInfo -AlertAction new -AlertName 'RandR' -AlertMail 'robert.lespinasse@lesbronzesfontdusk.io' | Out-Null
			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheAddAlert -Times 1 -Exactly -ParameterFilter {
				$AlertName -eq 'RandR'
			}
		}
	}

	Context 'AlertAction new with an existing alert of the same name' {
		BeforeEach {
			Mock -ModuleName Use-Onyphe Get-OnypheAlertInfo {
				[PSCustomObject]@{ 'cli-Filtered_Results' = [PSCustomObject]@{ id = 1; name = 'from russia' } }
			}
		}

		It 'throws instead of creating a duplicate alert' {
			{ Set-OnypheAlertInfo -SearchValue 'RU' -SearchType threatlist -SearchFilter country -AlertAction new -AlertName 'from russia' -AlertMail 'a@x.com' } | Should -Throw '*already used*'
		}
	}

	Context 'AlertAction delete' {
		It 'deletes the alert by ID when it exists' {
			Mock -ModuleName Use-Onyphe Get-OnypheAlertInfo {
				[PSCustomObject]@{ 'cli-Filtered_Results' = [PSCustomObject]@{ ID = 42; name = 'from russia' } }
			}

			Set-OnypheAlertInfo -AlertAction delete -AlertName 'from russia' | Out-Null

			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheDelAlert -Times 1 -Exactly -ParameterFilter {
				$AlertID -eq 42
			}
		}

		It 'throws when the alert does not exist' {
			Mock -ModuleName Use-Onyphe Get-OnypheAlertInfo { [PSCustomObject]@{ 'cli-Filtered_Results' = $null } }

			{ Set-OnypheAlertInfo -AlertAction delete -AlertName 'nonexistent' } | Should -Throw '*not existing*'
		}

		It 'deletes the alert by ID when it exists and -UseBetaFeatures is set, without throwing on an uninitialized params hashtable' {
			Mock -ModuleName Use-Onyphe Get-OnypheAlertInfo {
				[PSCustomObject]@{ 'cli-Filtered_Results' = [PSCustomObject]@{ ID = 42; name = 'from russia' } }
			}

			Set-OnypheAlertInfo -AlertAction delete -AlertName 'from russia' -UseBetaFeatures | Out-Null

			Should -Invoke -ModuleName Use-Onyphe Get-OnypheAlertInfo -Times 1 -Exactly -ParameterFilter {
				$UseBetaFeatures -eq $true
			}
			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheDelAlert -Times 1 -Exactly -ParameterFilter {
				($AlertID -eq 42) -and ($UseBetaFeatures -eq $true)
			}
		}

		It 'does not delete the alert when -WhatIf is used' {
			Mock -ModuleName Use-Onyphe Get-OnypheAlertInfo {
				[PSCustomObject]@{ 'cli-Filtered_Results' = [PSCustomObject]@{ ID = 42; name = 'from russia' } }
			}

			Set-OnypheAlertInfo -AlertAction delete -AlertName 'from russia' -WhatIf | Out-Null

			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheDelAlert -Times 0
		}
	}

	Context 'AlertAction modify' {
		It 'deletes then re-adds the alert when it exists' {
			Mock -ModuleName Use-Onyphe Get-OnypheAlertInfo {
				[PSCustomObject]@{ 'cli-Filtered_Results' = [PSCustomObject]@{ ID = 7; name = 'from russia' } }
			}

			Set-OnypheAlertInfo -SearchValue 'FR' -SearchType threatlist -SearchFilter country -AlertAction modify -AlertName 'from russia' -AlertMail 'b@x.com' | Out-Null

			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheDelAlert -Times 1 -Exactly -ParameterFilter { $AlertID -eq 7 }
			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheAddAlert -Times 1 -Exactly
		}

		It 'does not delete or re-add the alert when -WhatIf is used' {
			Mock -ModuleName Use-Onyphe Get-OnypheAlertInfo {
				[PSCustomObject]@{ 'cli-Filtered_Results' = [PSCustomObject]@{ ID = 7; name = 'from russia' } }
			}

			Set-OnypheAlertInfo -SearchValue 'FR' -SearchType threatlist -SearchFilter country -AlertAction modify -AlertName 'from russia' -AlertMail 'b@x.com' -WhatIf | Out-Null

			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheDelAlert -Times 0
			Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheAddAlert -Times 0
		}

		It 'throws when the alert does not exist' {
			Mock -ModuleName Use-Onyphe Get-OnypheAlertInfo { [PSCustomObject]@{ 'cli-Filtered_Results' = $null } }

			{ Set-OnypheAlertInfo -SearchValue 'FR' -SearchType threatlist -SearchFilter country -AlertAction modify -AlertName 'nonexistent' -AlertMail 'b@x.com' } | Should -Throw '*not existing*'
		}
	}
}
