BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Invoke-OnyphePivot' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchCategories { @('ctl', 'resolver') }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchFilters { @('organization', 'subject.organization') }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Start-Sleep { }
		Mock -ModuleName Use-Onyphe Search-OnypheInfo { [PSCustomObject]@{ results = @([PSCustomObject]@{ domain = 'example.com' }) } }
	}

	It 'fires one Search-OnypheInfo call per distinct -PivotField value found across -InputObject' {
		$InputObject = @(
			[PSCustomObject]@{ subject = [PSCustomObject]@{ organization = 'Org A' } },
			[PSCustomObject]@{ subject = [PSCustomObject]@{ organization = 'Org B' } },
			[PSCustomObject]@{ subject = [PSCustomObject]@{ organization = 'Org A' } }
		)

		$InputObject | Invoke-OnyphePivot -PivotField 'subject.organization' -PivotCategory ctl -PivotFilter 'subject.organization' | Out-Null

		Should -Invoke -ModuleName Use-Onyphe Search-OnypheInfo -Times 2 -Exactly
		Should -Invoke -ModuleName Use-Onyphe Search-OnypheInfo -Times 1 -Exactly -ParameterFilter {
			($SearchValue -eq 'Org A') -and ($SearchFilter -eq 'subject.organization') -and ($SearchType -eq 'ctl')
		}
		Should -Invoke -ModuleName Use-Onyphe Search-OnypheInfo -Times 1 -Exactly -ParameterFilter {
			$SearchValue -eq 'Org B'
		}
	}

	It 'reads a dotted -PivotField path off nested properties' {
		$InputObject = [PSCustomObject]@{ issuer = [PSCustomObject]@{ organization = 'Issuer Org' } }

		$InputObject | Invoke-OnyphePivot -PivotField 'issuer.organization' -PivotCategory ctl -PivotFilter 'organization' | Out-Null

		Should -Invoke -ModuleName Use-Onyphe Search-OnypheInfo -Times 1 -Exactly -ParameterFilter {
			$SearchValue -eq 'Issuer Org'
		}
	}

	It 'expands an array -PivotField value into one call per element' {
		$InputObject = [PSCustomObject]@{ subject = [PSCustomObject]@{ altname = @('a.example.com', 'b.example.com') } }

		$InputObject | Invoke-OnyphePivot -PivotField 'subject.altname' -PivotCategory ctl -PivotFilter 'organization' | Out-Null

		Should -Invoke -ModuleName Use-Onyphe Search-OnypheInfo -Times 2 -Exactly
	}

	It 'skips input objects where the -PivotField path resolves to null without throwing' {
		$InputObject = @(
			[PSCustomObject]@{ subject = [PSCustomObject]@{ organization = 'Org A' } },
			[PSCustomObject]@{ subject = [PSCustomObject]@{} }
		)

		{ $InputObject | Invoke-OnyphePivot -PivotField 'subject.organization' -PivotCategory ctl -PivotFilter 'organization' | Out-Null } | Should -Not -Throw
		Should -Invoke -ModuleName Use-Onyphe Search-OnypheInfo -Times 1 -Exactly
	}

	It 'warns and does not call Search-OnypheInfo when no -InputObject item has a non-empty -PivotField value' {
		$InputObject = [PSCustomObject]@{ subject = [PSCustomObject]@{} }

		$warnings = $InputObject | Invoke-OnyphePivot -PivotField 'subject.organization' -PivotCategory ctl -PivotFilter 'organization' 3>&1 |
			Where-Object { $_ -is [System.Management.Automation.WarningRecord] }

		$warnings.Count | Should -Be 1
		Should -Invoke -ModuleName Use-Onyphe Search-OnypheInfo -Times 0 -Exactly
	}

	It 'tags every returned result with cli-pivot_source_field and cli-pivot_source_value' {
		$InputObject = [PSCustomObject]@{ subject = [PSCustomObject]@{ organization = 'Org A' } }

		$result = $InputObject | Invoke-OnyphePivot -PivotField 'subject.organization' -PivotCategory ctl -PivotFilter 'organization'

		$result.'cli-pivot_source_field' | Should -Be 'subject.organization'
		$result.'cli-pivot_source_value' | Should -Be 'Org A'
	}

	It 'sleeps for -Wait seconds before each follow-up call' {
		$InputObject = @(
			[PSCustomObject]@{ subject = [PSCustomObject]@{ organization = 'Org A' } },
			[PSCustomObject]@{ subject = [PSCustomObject]@{ organization = 'Org B' } }
		)

		$InputObject | Invoke-OnyphePivot -PivotField 'subject.organization' -PivotCategory ctl -PivotFilter 'organization' -Wait 2 | Out-Null

		Should -Invoke -ModuleName Use-Onyphe Start-Sleep -Times 2 -Exactly -ParameterFilter {
			$Seconds -eq 2
		}
	}

	It 'passes -Size/-TrackQuery/-Calculated/-UseBetaFeatures/-Post through to each Search-OnypheInfo call' {
		$InputObject = [PSCustomObject]@{ subject = [PSCustomObject]@{ organization = 'Org A' } }

		$InputObject | Invoke-OnyphePivot -PivotField 'subject.organization' -PivotCategory ctl -PivotFilter 'organization' -Size 250 -TrackQuery -Calculated -UseBetaFeatures -Post | Out-Null

		Should -Invoke -ModuleName Use-Onyphe Search-OnypheInfo -Times 1 -Exactly -ParameterFilter {
			($Size -eq 250) -and ($TrackQuery -eq $true) -and ($Calculated -eq $true) -and ($UseBetaFeatures -eq $true) -and ($Post -eq $true)
		}
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		$InputObject = [PSCustomObject]@{ subject = [PSCustomObject]@{ organization = 'Org A' } }

		$InputObject | Invoke-OnyphePivot -PivotField 'subject.organization' -PivotCategory ctl -PivotFilter 'organization' -APIKey ('x' * 40) | Out-Null

		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('x' * 40)
		}
	}
}
