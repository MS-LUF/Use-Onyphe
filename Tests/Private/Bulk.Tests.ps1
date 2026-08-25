BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Private/Bulk wrappers' -Tag 'Unit' {
	InModuleScope 'Use-Onyphe' {

		BeforeEach {
			$script:SavedAPIKey = $global:OnypheAPIKey
			$global:OnypheAPIKey = $null
			$script:InFile = Join-Path $TestDrive 'input.txt'
			Set-Content -Path $script:InFile -Value '9.9.9.9'
			$script:OutFilePath = Join-Path $TestDrive 'output.json'
		}

		AfterEach {
			$global:OnypheAPIKey = $script:SavedAPIKey
		}

		$cases = @(
			@{ Function = 'Invoke-APIBulkSummaryOnypheIP'; ExpectedRequest = 'v2/bulk/summary/ip'; ExpectedAPIInfo = 'bulk/summary/ip' }
			@{ Function = 'Invoke-APIBulkSummaryOnypheHostname'; ExpectedRequest = 'v2/bulk/summary/hostname'; ExpectedAPIInfo = 'bulk/summary/hostname' }
			@{ Function = 'Invoke-APIBulkSummaryOnypheDomain'; ExpectedRequest = 'v2/bulk/summary/domain'; ExpectedAPIInfo = 'bulk/summary/domain' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheCTL'; ExpectedRequest = 'v2/bulk/simple/ctl/ip'; ExpectedAPIInfo = 'bulk/simple/ctl/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheDataScan'; ExpectedRequest = 'v2/bulk/simple/datascan/ip'; ExpectedAPIInfo = 'bulk/simple/datascan/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheDataShot'; ExpectedRequest = 'v2/bulk/simple/datashot/ip'; ExpectedAPIInfo = 'bulk/simple/datashot/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheGeoloc'; ExpectedRequest = 'v2/bulk/simple/geoloc/ip'; ExpectedAPIInfo = 'bulk/simple/geoloc/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheInetnum'; ExpectedRequest = 'v2/bulk/simple/inetnum/ip'; ExpectedAPIInfo = 'bulk/simple/inetnum/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnyphePastries'; ExpectedRequest = 'v2/bulk/simple/pastries/ip'; ExpectedAPIInfo = 'bulk/simple/pastries/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheResolver'; ExpectedRequest = 'v2/bulk/simple/resolver/ip'; ExpectedAPIInfo = 'bulk/simple/resolver/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheSniffer'; ExpectedRequest = 'v2/bulk/simple/sniffer/ip'; ExpectedAPIInfo = 'bulk/simple/sniffer/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheSynScan'; ExpectedRequest = 'v2/bulk/simple/synscan/ip'; ExpectedAPIInfo = 'bulk/simple/synscan/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheThreatlist'; ExpectedRequest = 'v2/bulk/simple/threatlist/ip'; ExpectedAPIInfo = 'bulk/simple/threatlist/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheTopSite'; ExpectedRequest = 'v2/bulk/simple/topsite/ip'; ExpectedAPIInfo = 'bulk/simple/topsite/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheVulnscan'; ExpectedRequest = 'v2/bulk/simple/vulnscan/ip'; ExpectedAPIInfo = 'bulk/simple/vulnscan/ip' }
			@{ Function = 'Invoke-APIBulkSimpleOnypheWhoIs'; ExpectedRequest = 'v2/bulk/simple/whois/ip'; ExpectedAPIInfo = 'bulk/simple/whois/ip' }
			@{ Function = 'Invoke-APIBulkSimpleBestOnypheGeoloc'; ExpectedRequest = 'v2/bulk/simple/geoloc/best/ip'; ExpectedAPIInfo = 'bulk/simple/geoloc/best/ip' }
			@{ Function = 'Invoke-APIBulkSimpleBestOnypheInetnum'; ExpectedRequest = 'v2/bulk/simple/inetnum/best/ip'; ExpectedAPIInfo = 'bulk/simple/inetnum/best/ip' }
			@{ Function = 'Invoke-APIBulkSimpleBestOnypheThreatlist'; ExpectedRequest = 'v2/bulk/simple/threatlist/best/ip'; ExpectedAPIInfo = 'bulk/simple/threatlist/best/ip' }
			@{ Function = 'Invoke-APIBulkSimpleBestOnypheWhois'; ExpectedRequest = 'v2/bulk/simple/whois/best/ip'; ExpectedAPIInfo = 'bulk/simple/whois/best/ip' }
			@{ Function = 'Invoke-APIBulkDiscoveryOnypheDatascan'; ExpectedRequest = 'v2/bulk/discovery/datascan/asset'; ExpectedAPIInfo = 'bulk/discovery/datascan/asset' }
			@{ Function = 'Invoke-APIBulkDiscoveryOnypheResolver'; ExpectedRequest = 'v2/bulk/discovery/resolver/asset'; ExpectedAPIInfo = 'bulk/discovery/resolver/asset' }
			@{ Function = 'Invoke-APIBulkDiscoveryOnypheVulnscan'; ExpectedRequest = 'v2/bulk/discovery/vulnscan/asset'; ExpectedAPIInfo = 'bulk/discovery/vulnscan/asset' }
		)

		It '<Function> calls Invoke-OnypheAPIV2 with the expected request/APIInfo/file/Stream/OutFile and APIKeyrequired $true' -TestCases $cases {
			# PSScriptAnalyzer's PSReviewUnusedParameter can't see these are read inside the nested Should -ParameterFilter scriptblock below.
			param($Function, $ExpectedRequest, $ExpectedAPIInfo)

			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

			& $Function -FilePath $script:InFile -OutFile $script:OutFilePath | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				($request -eq $ExpectedRequest) -and
				($APIInfo -eq $ExpectedAPIInfo) -and
				($APIInput -eq "File:$($script:InFile)") -and
				($file -eq $script:InFile) -and
				($APIKeyrequired -eq $true) -and
				($Stream -eq $true) -and
				($OutFile -eq $script:OutFilePath)
			}
		}

		It 'Invoke-APIBulkSummaryOnypheIP passes -FuncInput through to Invoke-OnypheAPIV2' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

			Invoke-APIBulkSummaryOnypheIP -FilePath $script:InFile -OutFile $script:OutFilePath -FuncInput @{ BulkAPIType = 'ip' } | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$FuncInput['BulkAPIType'] -eq 'ip'
			}
		}

		It 'Invoke-APIBulkSummaryOnypheIP calls Set-OnypheAPIKey when -APIKey is supplied' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }
			Mock Set-OnypheAPIKey { }

			Invoke-APIBulkSummaryOnypheIP -FilePath $script:InFile -OutFile $script:OutFilePath -APIKey ('x' * 40) | Out-Null

			Should -Invoke Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
				$APIKey -eq ('x' * 40)
			}
		}

		It 'Invoke-APIBulkSummaryOnypheIP throws when -FilePath does not exist' {
			$missingPath = Join-Path $TestDrive 'does-not-exist.txt'

			{ Invoke-APIBulkSummaryOnypheIP -FilePath $missingPath -OutFile $script:OutFilePath } | Should -Throw
		}

		It 'Invoke-APIBulkSummaryOnypheIP throws when -OutFile already exists' {
			$existingOutFile = Join-Path $TestDrive 'already-there.json'
			Set-Content -Path $existingOutFile -Value '{}'

			{ Invoke-APIBulkSummaryOnypheIP -FilePath $script:InFile -OutFile $existingOutFile } | Should -Throw
		}

		Context 'Invoke-OnypheBulkFileUpload' {
			It 'builds request/APIInfo as v2/bulk/<Endpoint> and bulk/<Endpoint>' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-OnypheBulkFileUpload -Endpoint 'simple/ctl/ip' -FilePath $script:InFile -OutFile $script:OutFilePath | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($request -eq 'v2/bulk/simple/ctl/ip') -and
					($APIInfo -eq 'bulk/simple/ctl/ip') -and
					($APIInput -eq "File:$($script:InFile)") -and
					($file -eq $script:InFile) -and
					($APIKeyrequired -eq $true) -and
					($Stream -eq $true) -and
					($OutFile -eq $script:OutFilePath)
				}
			}

			It 'does not add a FuncInput key to the API call when -FuncInput is not supplied' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-OnypheBulkFileUpload -Endpoint 'summary/ip' -FilePath $script:InFile -OutFile $script:OutFilePath | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					-not $FuncInput
				}
			}
		}
	}
}
