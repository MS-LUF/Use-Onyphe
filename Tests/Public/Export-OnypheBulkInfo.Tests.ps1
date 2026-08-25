BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Export-OnypheBulkInfo' -Tag 'Unit' {
	BeforeAll {
		$script:InFile = Join-Path $TestDrive 'input.txt'
		Set-Content -Path $script:InFile -Value '9.9.9.9'
	}

	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheBulkCategories { @('ctl', 'geoloc') }
		Mock -ModuleName Use-Onyphe Get-OnypheSimpleAPIName { @('ctl', 'geoloc') }
		Mock -ModuleName Use-Onyphe Get-OnypheSimpleBestAPIName { @('geoloc') }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Invoke-APIBulkSimpleOnypheCTL {
			param($OutFile)
			Set-Content -Path $OutFile -Value '{"status":"ok-ctl"}'
		}
		Mock -ModuleName Use-Onyphe Invoke-APIBulkSimpleBestOnypheGeoloc {
			param($OutFile)
			Set-Content -Path $OutFile -Value '{"status":"ok-best-geoloc"}'
		}
	}

	It 'dispatches to the non-best Invoke-APIBulkSimpleOnyphe<Category> function' {
		Export-OnypheBulkInfo -FilePath $script:InFile -Category ctl | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIBulkSimpleOnypheCTL -Times 1 -Exactly -ParameterFilter {
			$FilePath -eq $script:InFile
		}
	}

	It 'dispatches to the best variant when -Best is used' {
		Export-OnypheBulkInfo -FilePath $script:InFile -Category geoloc -Best | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIBulkSimpleBestOnypheGeoloc -Times 1 -Exactly
	}

	It 'throws when -Best is used with a category not in Get-OnypheSimpleBestAPIName' {
		{ Export-OnypheBulkInfo -FilePath $script:InFile -Category ctl -Best } | Should -Throw '*not available*'
	}

	It 'returns the parsed object from the output file when -SaveInfoAsFile is omitted' {
		$Result = Export-OnypheBulkInfo -FilePath $script:InFile -Category ctl
		$Result.status | Should -Be 'ok-ctl'
	}

	It 'does not return an object when -SaveInfoAsFile is explicitly supplied' {
		$SaveFile = Join-Path $TestDrive 'explicit-output.json'
		$Result = Export-OnypheBulkInfo -FilePath $script:InFile -Category ctl -SaveInfoAsFile $SaveFile
		$Result | Should -BeNullOrEmpty
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Export-OnypheBulkInfo -FilePath $script:InFile -Category ctl -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}
}
