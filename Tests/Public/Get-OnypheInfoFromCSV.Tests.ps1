BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheInfoFromCSV' -Tag 'Unit' {
	BeforeAll {
		$Rows = @(
			[PSCustomObject]@{ API = 'Search'; 'search-category' = 'threatlist'; 'Search-Request' = 'country:RU'; 'Filter-Request' = ''; 'Page' = ''; 'API-Input' = ''; Best = '' }
			[PSCustomObject]@{ API = 'IP'; 'search-category' = ''; 'Search-Request' = ''; 'Filter-Request' = ''; 'Page' = ''; 'API-Input' = '8.8.8.8'; Best = '' }
			[PSCustomObject]@{ API = 'geoloc'; 'search-category' = ''; 'Search-Request' = ''; 'Filter-Request' = ''; 'Page' = ''; 'API-Input' = '9.9.9.9'; Best = 'True' }
		)
		$script:CsvPath = Join-Path $TestDrive 'input.csv'
		$Rows | Export-Csv -Path $script:CsvPath -Delimiter ';' -NoTypeInformation
	}

	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Search-OnypheInfo { [PSCustomObject]@{ source = 'search' } }
		Mock -ModuleName Use-Onyphe Get-OnypheSummary { [PSCustomObject]@{ source = 'summary' } }
		Mock -ModuleName Use-Onyphe Get-OnypheInfo { [PSCustomObject]@{ source = 'simple' } }
		# Search-OnypheInfo/Get-OnypheInfo/Get-OnypheSummary keep their real DynamicParam blocks
		# even when mocked, so their ValidateSet source functions still need a non-null result.
		Mock -ModuleName Use-Onyphe Get-OnypheSearchCategories { @('threatlist', 'datascan') }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchFilters { @('country', 'port') }
		Mock -ModuleName Use-Onyphe Get-OnypheSearchFunctions { @('monthago', 'exists') }
		Mock -ModuleName Use-Onyphe Get-OnypheSimpleAPIName { @('geoloc') }
		Mock -ModuleName Use-Onyphe Get-OnypheSummaryAPIName { @('ip', 'domain', 'hostname') }
	}

	It 'dispatches Search rows to Search-OnypheInfo with the AdvancedSearch built from Search-Request' {
		Get-OnypheInfoFromCSV -fromcsv $script:CsvPath | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Search-OnypheInfo -Times 1 -Exactly -ParameterFilter {
			($SearchType -eq 'threatlist') -and ((@($AdvancedSearch) -join ',') -eq 'country:RU')
		}
	}

	It 'dispatches IP/Domain/HostName rows to Get-OnypheSummary' {
		Get-OnypheInfoFromCSV -fromcsv $script:CsvPath | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Get-OnypheSummary -Times 1 -Exactly -ParameterFilter {
			($SearchType -eq 'IP') -and ($SearchValue -eq '8.8.8.8')
		}
	}

	It 'dispatches other rows to Get-OnypheInfo, honoring the Best column' {
		Get-OnypheInfoFromCSV -fromcsv $script:CsvPath | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Get-OnypheInfo -Times 1 -Exactly -ParameterFilter {
			($SearchType -eq 'geoloc') -and ($SearchValue -eq '9.9.9.9') -and ($Best -eq $true)
		}
	}

	It 'returns the combined results from all three dispatch paths' {
		$Result = @(Get-OnypheInfoFromCSV -fromcsv $script:CsvPath)
		$Result.Count | Should -Be 3
		@($Result.source) | Should -Contain 'search'
		@($Result.source) | Should -Contain 'summary'
		@($Result.source) | Should -Contain 'simple'
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Get-OnypheInfoFromCSV -fromcsv $script:CsvPath -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}

	It 'throws when -fromcsv does not point to an existing file' {
		{ Get-OnypheInfoFromCSV -fromcsv (Join-Path $TestDrive 'does-not-exist.csv') } | Should -Throw
	}

	It 'automatically passes -Wait 3 to each dispatch path to manage rate limiting' {
		Get-OnypheInfoFromCSV -fromcsv $script:CsvPath | Out-Null

		Should -Invoke -ModuleName Use-Onyphe Search-OnypheInfo -Times 1 -Exactly -ParameterFilter { $Wait -eq 3 }
		Should -Invoke -ModuleName Use-Onyphe Get-OnypheSummary -Times 1 -Exactly -ParameterFilter { $Wait -eq 3 }
		Should -Invoke -ModuleName Use-Onyphe Get-OnypheInfo -Times 1 -Exactly -ParameterFilter { $Wait -eq 3 }
	}

	It 'parses the CSV with a custom -csvdelimiter' {
		$CustomRows = @(
			[PSCustomObject]@{ API = 'geoloc'; 'search-category' = ''; 'Search-Request' = ''; 'Filter-Request' = ''; 'Page' = ''; 'API-Input' = '9.9.9.9'; Best = '' }
		)
		$CustomCsvPath = Join-Path $TestDrive 'input-comma.csv'
		$CustomRows | Export-Csv -Path $CustomCsvPath -Delimiter ',' -NoTypeInformation

		Get-OnypheInfoFromCSV -fromcsv $CustomCsvPath -csvdelimiter ',' | Out-Null

		Should -Invoke -ModuleName Use-Onyphe Get-OnypheInfo -Times 1 -Exactly -ParameterFilter {
			$SearchValue -eq '9.9.9.9'
		}
	}
}
