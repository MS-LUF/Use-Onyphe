BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Get-OnypheASDInfo' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Get-OnypheASDAPIName { @('domaintld', 'domaincertso', 'dnsdomainexist', 'bogus') }
		Mock -ModuleName Use-Onyphe Set-OnypheAPIKey { }
		Mock -ModuleName Use-Onyphe Start-Sleep { }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDDomainTld { [PSCustomObject]@{ error = 0 } }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDDomainCertso { [PSCustomObject]@{ error = 0 } }
		Mock -ModuleName Use-Onyphe Invoke-APIOnypheASDDnsDomainExist { [PSCustomObject]@{ error = 0 } }
	}

	It 'dispatches to Invoke-APIOnypheASDDomainTld with -Value mapped to -Domain for most ASDAPIType values' {
		Get-OnypheASDInfo -ASDAPIType domaintld -Value 'example.com' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDDomainTld -Times 1 -Exactly -ParameterFilter {
			($Domain -join ',') -eq 'example.com'
		}
	}

	It 'accepts -Value from the pipeline' {
		'example.com' | Get-OnypheASDInfo -ASDAPIType domaintld | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDDomainTld -Times 1 -Exactly -ParameterFilter {
			($Domain -join ',') -eq 'example.com'
		}
	}

	It 'dispatches to Invoke-APIOnypheASDDomainCertso with -Value mapped to -Certso for ASDAPIType domaincertso' {
		Get-OnypheASDInfo -ASDAPIType domaincertso -Value 'Example Organization' | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDDomainCertso -Times 1 -Exactly -ParameterFilter {
			($Certso -join ',') -eq 'Example Organization'
		}
	}

	It 'passes -IncludePattern/-ExcludePattern/-Untrusted through for a stdapis type that supports them' {
		Get-OnypheASDInfo -ASDAPIType domaintld -Value 'example.com' -IncludePattern 'foo' -ExcludePattern 'bar' -Untrusted | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDDomainTld -Times 1 -Exactly -ParameterFilter {
			($IncludePattern -join ',') -eq 'foo' -and ($ExcludePattern -join ',') -eq 'bar' -and ($Untrusted -eq $true)
		}
	}

	It 'silently drops -IncludePattern/-ExcludePattern/-Untrusted for ASDAPIType dnsdomainexist (unsupported by that endpoint)' {
		Get-OnypheASDInfo -ASDAPIType dnsdomainexist -Value 'example.com' -IncludePattern 'foo' -Untrusted | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Invoke-APIOnypheASDDnsDomainExist -Times 1 -Exactly -ParameterFilter {
			(-not $IncludePattern) -and (-not $Untrusted)
		}
	}

	It 'sleeps for -wait seconds before requesting' {
		Get-OnypheASDInfo -ASDAPIType domaintld -Value 'example.com' -wait 3 | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Start-Sleep -Times 1 -Exactly -ParameterFilter {
			$Seconds -eq 3
		}
	}

	It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
		Get-OnypheASDInfo -ASDAPIType domaintld -Value 'example.com' -APIKey ('a' * 40) | Out-Null
		Should -Invoke -ModuleName Use-Onyphe Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
			$APIKey -eq ('a' * 40)
		}
	}

	It 'throws for an ASDAPIType with no corresponding Invoke-APIOnypheASD* function' {
		{ Get-OnypheASDInfo -ASDAPIType bogus -Value 'example.com' } | Should -Throw '*not implemented*'
	}
}
