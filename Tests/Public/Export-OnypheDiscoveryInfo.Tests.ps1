BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Export-OnypheDiscoveryInfo' -Tag 'Unit' {
	BeforeAll {
		$script:InFile = Join-Path $TestDrive 'queries.txt'
		Set-Content -Path $script:InFile -Value 'protocol:rdp domain:google.com'
	}

	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheDiscoveryCategories { @('datascan', 'resolver', 'vulnscan') }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Invoke-APIBulkDiscoveryOnypheDatascan {
			param($OutFile)
			Set-Content -Path $OutFile -Value '{"status":"ok-datascan"}'
		}
	}

	It 'dispatches to the Invoke-APIBulkDiscoveryOnyphe<Category> function' {
		Export-OnypheDiscoveryInfo -FilePath $script:InFile -Category datascan | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIBulkDiscoveryOnypheDatascan -Times 1 -Exactly -ParameterFilter {
			$FilePath -eq $script:InFile
		}
	}

	It 'throws when -Category is not in Get-OnypheDiscoveryCategories (e.g. no Griffin View subscription)' {
		Mock -ModuleName Use-Onyphe Get-OnypheDiscoveryCategories { @() }
		{ Export-OnypheDiscoveryInfo -FilePath $script:InFile -Category datascan } | Should -Throw '*not available*'
	}

	It 'dispatches to a category beyond the original datascan/resolver/vulnscan set (e.g. whois)' {
		Mock -ModuleName Use-Onyphe Get-OnypheDiscoveryCategories { @('datascan', 'resolver', 'vulnscan', 'whois') }
		Mock -ModuleName Use-Onyphe Invoke-APIBulkDiscoveryOnypheWhois {
			param($OutFile)
			Set-Content -Path $OutFile -Value '{"status":"ok-whois"}'
		}
		$Result = Export-OnypheDiscoveryInfo -FilePath $script:InFile -Category whois
		$Result.status | Should -Be 'ok-whois'
	}

	It 'returns the parsed object from the output file when -SaveInfoAsFile is omitted' {
		$Result = Export-OnypheDiscoveryInfo -FilePath $script:InFile -Category datascan
		$Result.status | Should -Be 'ok-datascan'
	}

	It 'does not return an object when -SaveInfoAsFile is explicitly supplied' {
		$SaveFile = Join-Path $TestDrive 'explicit-output.json'
		Mock -ModuleName Use-Onyphe Invoke-APIBulkDiscoveryOnypheDatascan {
			param($OutFile)
			Set-Content -Path $OutFile -Value '{"status":"ok-datascan"}'
		}
		$Result = Export-OnypheDiscoveryInfo -FilePath $script:InFile -Category datascan -SaveInfoAsFile $SaveFile
		$Result | Should -BeNullOrEmpty
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Export-OnypheDiscoveryInfo -FilePath $script:InFile -Category datascan -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}

	It 'rejects a -FilePath that does not exist' {
		$missingPath = Join-Path $TestDrive 'does-not-exist.txt'
		{ Export-OnypheDiscoveryInfo -FilePath $missingPath -Category datascan } | Should -Throw
	}
}
