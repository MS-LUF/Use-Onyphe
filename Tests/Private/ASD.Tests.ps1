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
			@{ Function = 'Invoke-APIOnypheASDSubnetInventory'; ExpectedRequest = 'v1/asd/subnet/inventory'; ExpectedAPIInfo = 'asd/subnet/inventory'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDIpInventory'; ExpectedRequest = 'v1/asd/ip/inventory'; ExpectedAPIInfo = 'asd/ip/inventory'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDOrgInventory'; ExpectedRequest = 'v1/asd/org/inventory'; ExpectedAPIInfo = 'asd/org/inventory'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDIpCertso'; ExpectedRequest = 'v1/asd/ip/certso'; ExpectedAPIInfo = 'asd/ip/certso'; ParamName = 'Certso' }
			@{ Function = 'Invoke-APIOnypheASDIpDomain'; ExpectedRequest = 'v1/asd/ip/domain'; ExpectedAPIInfo = 'asd/ip/domain'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDVhostInventory'; ExpectedRequest = 'v1/asd/vhost/inventory'; ExpectedAPIInfo = 'asd/vhost/inventory'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDScoreInventory'; ExpectedRequest = 'v1/asd/score/inventory'; ExpectedAPIInfo = 'asd/score/inventory'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDDnsDomainMsTenantId'; ExpectedRequest = 'v1/asd/dns/domain/mstenantid'; ExpectedAPIInfo = 'asd/dns/domain/mstenantid'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDDnsDomainNsExist'; ExpectedRequest = 'v1/asd/dns/domain/ns/exist'; ExpectedAPIInfo = 'asd/dns/domain/ns/exist'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDDomainExist'; ExpectedRequest = 'v1/asd/domain/exist'; ExpectedAPIInfo = 'asd/domain/exist'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDWebSubdomainDomain'; ExpectedRequest = 'v1/asd/web/subdomain/domain'; ExpectedAPIInfo = 'asd/web/subdomain/domain'; ParamName = 'Domain' }
			@{ Function = 'Invoke-APIOnypheASDBootstrapCertsoWildcard'; ExpectedRequest = 'v1/asd/bootstrap/certso/wildcard'; ExpectedAPIInfo = 'asd/bootstrap/certso/wildcard'; ParamName = 'Certso' }
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

		It 'Invoke-APIOnypheASDIpCertso builds the JSON body under the "certso" key, not "domain"' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDIpCertso -Certso 'Example Organization' | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$Body = $Data | ConvertFrom-Json
				($Body.certso -eq 'Example Organization') -and
				(-not (Get-Member -InputObject $Body -Name 'domain')) -and
				(-not (Get-Member -InputObject $Body -Name 'inventory'))
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

		It 'Invoke-APIOnypheASDSubnetInventory builds the JSON body under the nested "inventory.domain" key, not a bare "domain"' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDSubnetInventory -Domain @('a.com', 'b.com') | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$Body = $Data | ConvertFrom-Json
				($Body.inventory.domain -join ',') -eq 'a.com,b.com' -and
				(-not (Get-Member -InputObject $Body -Name 'domain'))
			}
		}

		It 'Invoke-APIOnypheASDIpInventory builds the JSON body under the nested "inventory.domain" key, not a bare "domain"' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDIpInventory -Domain @('a.com', 'b.com') | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$Body = $Data | ConvertFrom-Json
				($Body.inventory.domain -join ',') -eq 'a.com,b.com' -and
				(-not (Get-Member -InputObject $Body -Name 'domain'))
			}
		}

		It 'Invoke-APIOnypheASDOrgInventory builds the JSON body under the nested "inventory.domain" key, not a bare "domain"' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDOrgInventory -Domain @('a.com', 'b.com') | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$Body = $Data | ConvertFrom-Json
				($Body.inventory.domain -join ',') -eq 'a.com,b.com' -and
				(-not (Get-Member -InputObject $Body -Name 'domain'))
			}
		}

		It 'Invoke-APIOnypheASDTaskId calls Invoke-OnypheAPIV2 with a plain GET, no request body, against v1/asd/task/id/<id>' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDTaskId -TaskId 'abc-123' | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				($request -eq 'v1/asd/task/id/abc-123') -and
				($APIInfo -eq 'asd/task/id') -and
				($APIKeyrequired -eq $true) -and
				($APIVersion -eq '1') -and
				(-not $data) -and
				(-not $Method -or $Method -eq 'GET')
			}
		}

		It 'Invoke-APIOnypheASDTaskPoll calls Invoke-OnypheAPIV2 with a plain GET, no request body, against v1/asd/task/poll/<id>' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDTaskPoll -TaskId 'abc-123' | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				($request -eq 'v1/asd/task/poll/abc-123') -and
				($APIInfo -eq 'asd/task/poll') -and
				($APIKeyrequired -eq $true) -and
				($APIVersion -eq '1') -and
				(-not $data)
			}
		}

		It 'Invoke-APIOnypheASDTaskList calls Invoke-OnypheAPIV2 against v1/asd/task/list, no TaskId needed' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDTaskList | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				($request -eq 'v1/asd/task/list') -and
				($APIInfo -eq 'asd/task/list') -and
				($APIKeyrequired -eq $true) -and
				($APIVersion -eq '1')
			}
		}

		It 'Invoke-APIOnypheASDTaskKill calls Invoke-OnypheAPIV2 with -Method DELETE against v1/asd/task/kill/<id>' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDTaskKill -TaskId 'abc-123' | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				($request -eq 'v1/asd/task/kill/abc-123') -and
				($APIInfo -eq 'asd/task/kill') -and
				($APIKeyrequired -eq $true) -and
				($APIVersion -eq '1') -and
				($Method -eq 'DELETE')
			}
		}

		It 'Invoke-APIOnypheASDVhostInventory builds the JSON body under the nested "inventory.domain" key, not a bare "domain"' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDVhostInventory -Domain @('a.com', 'b.com') | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$Body = $Data | ConvertFrom-Json
				($Body.inventory.domain -join ',') -eq 'a.com,b.com' -and
				(-not (Get-Member -InputObject $Body -Name 'domain'))
			}
		}

		It 'Invoke-APIOnypheASDScoreInventory builds the JSON body under the nested "inventory.domain" key, not a bare "domain"' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ error = 0 } }

			Invoke-APIOnypheASDScoreInventory -Domain @('a.com', 'b.com') | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$Body = $Data | ConvertFrom-Json
				($Body.inventory.domain -join ',') -eq 'a.com,b.com' -and
				(-not (Get-Member -InputObject $Body -Name 'domain'))
			}
		}

		It 'Invoke-APIOnypheASDDnsDomainExist does not expose -IncludePattern/-ExcludePattern/-Untrusted' {
			(Get-Command Invoke-APIOnypheASDDnsDomainExist).Parameters.Keys | Should -Not -Contain 'IncludePattern'
			(Get-Command Invoke-APIOnypheASDDnsDomainExist).Parameters.Keys | Should -Not -Contain 'ExcludePattern'
			(Get-Command Invoke-APIOnypheASDDnsDomainExist).Parameters.Keys | Should -Not -Contain 'Untrusted'
		}

		It 'Invoke-APIOnypheASDDnsDomainNsExist does not expose -IncludePattern/-ExcludePattern/-Untrusted' {
			(Get-Command Invoke-APIOnypheASDDnsDomainNsExist).Parameters.Keys | Should -Not -Contain 'IncludePattern'
			(Get-Command Invoke-APIOnypheASDDnsDomainNsExist).Parameters.Keys | Should -Not -Contain 'ExcludePattern'
			(Get-Command Invoke-APIOnypheASDDnsDomainNsExist).Parameters.Keys | Should -Not -Contain 'Untrusted'
		}

		It 'Invoke-APIOnypheASDDomainExist does not expose -IncludePattern/-ExcludePattern/-Untrusted' {
			(Get-Command Invoke-APIOnypheASDDomainExist).Parameters.Keys | Should -Not -Contain 'IncludePattern'
			(Get-Command Invoke-APIOnypheASDDomainExist).Parameters.Keys | Should -Not -Contain 'ExcludePattern'
			(Get-Command Invoke-APIOnypheASDDomainExist).Parameters.Keys | Should -Not -Contain 'Untrusted'
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
