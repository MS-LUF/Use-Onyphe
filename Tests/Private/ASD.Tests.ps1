BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Private/ASD wrappers' -Tag 'Unit' {
	InModuleScope 'Use-Onyphe' {

		BeforeEach {
			$script:SavedAPIKey = $global:OnypheAPIKey
			$global:OnypheAPIKey = $null
		}

		AfterEach {
			$global:OnypheAPIKey = $script:SavedAPIKey
		}

		$cases = @(
			@{ Function = 'Invoke-APIOnypheASDDomainTld'; ExpectedRequest = 'v1/asd/domain/tld'; ExpectedAPIInfo = 'asd/domain/tld'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDDomainWildcard'; ExpectedRequest = 'v1/asd/domain/wildcard'; ExpectedAPIInfo = 'asd/domain/wildcard'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDDomainCertso'; ExpectedRequest = 'v1/asd/domain/certso'; ExpectedAPIInfo = 'asd/domain/certso'; ParamName = 'Certso' }
			@{ Function = 'Invoke-APIOnypheASDCertsoDomain'; ExpectedRequest = 'v1/asd/certso/domain'; ExpectedAPIInfo = 'asd/certso/domain'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDCertsoWildcard'; ExpectedRequest = 'v1/asd/certso/wildcard'; ExpectedAPIInfo = 'asd/certso/wildcard'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDDnsDomainNs'; ExpectedRequest = 'v1/asd/dns/domain/ns'; ExpectedAPIInfo = 'asd/dns/domain/ns'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDDnsDomainMx'; ExpectedRequest = 'v1/asd/dns/domain/mx'; ExpectedAPIInfo = 'asd/dns/domain/mx'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDDnsDomainSoa'; ExpectedRequest = 'v1/asd/dns/domain/soa'; ExpectedAPIInfo = 'asd/dns/domain/soa'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDDnsDomainExist'; ExpectedRequest = 'v1/asd/dns/domain/exist'; ExpectedAPIInfo = 'asd/dns/domain/exist'; ParamName = 'Domain' }
		)

		It '<Function> calls Invoke-OnypheAPIV2 with the expected request/APIInfo/APIVersion "1"/APIKeyrequired $true and a JSON body carrying the input value' -TestCases $cases {
			# PSScriptAnalyzer's PSReviewUnusedParameter can't see these are read inside the nested Should -ParameterFilter scriptblock below.
			param($Function, $ExpectedRequest, $ExpectedAPIInfo, $ParamName)

			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			$callParams = @{ $ParamName = 'example.com' }
			& $Function @callParams | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				($request -eq $ExpectedRequest) -and
				($APIInfo -eq $ExpectedAPIInfo) -and
				($APIKeyrequired -eq $true) -and
				($APIVersion -eq '1') -and
				($Data -like '*example.com*')
			}
		}

		It 'Invoke-APIOnypheASDDomainTld builds the JSON body from -Domain/-IncludePattern/-ExcludePattern/-Untrusted/-AsLines' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDDomainTld -Domain @('a.com', 'b.com') -IncludePattern 'foo' -ExcludePattern 'bar' -Untrusted -AsLines | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$Body = $Data | ConvertFrom-Json
				($Body.domain -join ',') -eq 'a.com,b.com' -and
				($Body.includep -join ',') -eq 'foo' -and
				($Body.excludep -join ',') -eq 'bar' -and
				($Body.trusted -eq $false) -and
				($Body.aslines -eq $true)
			}
		}

		It 'Invoke-APIOnypheASDDomainTld omits trusted/aslines from the JSON body when not requested' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDDomainTld -Domain 'a.com' | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$Body = $Data | ConvertFrom-Json
				(-not (Get-Member -InputObject $Body -Name 'trusted')) -and
				(-not (Get-Member -InputObject $Body -Name 'aslines'))
			}
		}

		It 'Invoke-APIOnypheASDDomainCertso builds the JSON body under the "certso" key, not "domain"' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDDomainCertso -Certso 'Example Organization' | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$Body = $Data | ConvertFrom-Json
				($Body.certso -eq 'Example Organization') -and
				(-not (Get-Member -InputObject $Body -Name 'domain'))
			}
		}

		It 'Invoke-APIOnypheASDDnsDomainExist does not expose -IncludePattern/-ExcludePattern/-Untrusted' {
			(Get-Command Invoke-APIOnypheASDDnsDomainExist).Parameters.Keys | Should -Not -Contain 'IncludePattern'
			(Get-Command Invoke-APIOnypheASDDnsDomainExist).Parameters.Keys | Should -Not -Contain 'ExcludePattern'
			(Get-Command Invoke-APIOnypheASDDnsDomainExist).Parameters.Keys | Should -Not -Contain 'Untrusted'
		}

		It 'Invoke-APIOnypheASDDomainTld passes -FuncInput through to Invoke-OnypheAPIV2' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDDomainTld -Domain 'a.com' -FuncInput @{ ASDAPIType = 'domaintld' } | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$FuncInput['ASDAPIType'] -eq 'domaintld'
			}
		}

		It 'Invoke-APIOnypheASDDomainTld calls Set-OnypheAPIKey when -APIKey is supplied' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }
			Mock Set-OnypheAPIKey { }

			Invoke-APIOnypheASDDomainTld -Domain 'a.com' -APIKey ('x' * 40) | Out-Null

			Should -Invoke Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
				$APIKey -eq ('x' * 40)
			}
		}
	}
}
