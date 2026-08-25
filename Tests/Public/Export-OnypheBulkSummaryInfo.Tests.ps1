BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Export-OnypheBulkSummaryInfo' -Tag 'Unit' {
	BeforeAll {
		$script:InFile = Join-Path $TestDrive 'input.txt'
		Set-Content -Path $script:InFile -Value '9.9.9.9'
	}

	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheSummaryAPIName { @('ip', 'domain') }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Invoke-APIBulkSummaryOnypheIP {
			param($OutFile)
			Set-Content -Path $OutFile -Value '{"status":"ok-ip"}'
		}
	}

	It 'dispatches to Invoke-APIBulkSummaryOnyphe<Type>' {
		Export-OnypheBulkSummaryInfo -FilePath $script:InFile -BulkAPISummary ip | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIBulkSummaryOnypheIP -Times 1 -Exactly -ParameterFilter {
			$FilePath -eq $script:InFile
		}
	}

	It 'returns the parsed object from the output file when -SaveInfoAsFile is omitted' {
		$Result = Export-OnypheBulkSummaryInfo -FilePath $script:InFile -BulkAPISummary ip
		$Result.status | Should -Be 'ok-ip'
	}

	It 'does not return an object when -SaveInfoAsFile is explicitly supplied' {
		$SaveFile = Join-Path $TestDrive 'explicit-output.json'
		$Result = Export-OnypheBulkSummaryInfo -FilePath $script:InFile -BulkAPISummary ip -SaveInfoAsFile $SaveFile
		$Result | Should -BeNullOrEmpty
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Export-OnypheBulkSummaryInfo -FilePath $script:InFile -BulkAPISummary ip -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}
}
