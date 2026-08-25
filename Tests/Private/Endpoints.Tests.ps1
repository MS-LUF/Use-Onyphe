BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Private/Endpoints wrappers' -Tag 'Unit' {
	InModuleScope 'Use-Onyphe' {

		BeforeEach {
			$script:SavedAPIKey = $global:OnypheAPIKey
			$global:OnypheAPIKey = $null
		}

		AfterEach {
			$global:OnypheAPIKey = $script:SavedAPIKey
		}

		$cases = @(
			@{ Function = 'Invoke-APIOnypheUser'; Params = @{}; ExpectedRequest = 'v2/user/'; ExpectedAPIInfo = 'user'; ExpectedAPIInput = 'none' }
			@{ Function = 'Invoke-APIOnypheWhois'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/whois/9.9.9.9'; ExpectedAPIInfo = 'whois'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIBestOnypheWhois'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/whois/best/9.9.9.9'; ExpectedAPIInfo = 'whois/best'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheInetnum'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/inetnum/9.9.9.9'; ExpectedAPIInfo = 'inetnum'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIBestOnypheInetnum'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/inetnum/best/9.9.9.9'; ExpectedAPIInfo = 'inetnum/best'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnyphePastries'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/pastries/9.9.9.9'; ExpectedAPIInfo = 'pastries'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheSynScan'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/synscan/9.9.9.9'; ExpectedAPIInfo = 'synscan'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheSniffer'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/sniffer/9.9.9.9'; ExpectedAPIInfo = 'sniffer'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheCtl'; Params = @{ Domain = 'example.com' }; ExpectedRequest = 'v2/simple/ctl/example.com'; ExpectedAPIInfo = 'ctl'; ExpectedAPIInput = @('example.com') }
			@{ Function = 'Invoke-APIOnypheDatascanDataMD5'; Params = @{ MD5 = '0123456789abcdef0123456789abcdef' }; ExpectedRequest = 'v2/simple/datascan/md5/0123456789abcdef0123456789abcdef'; ExpectedAPIInfo = 'md5'; ExpectedAPIInput = @('0123456789abcdef0123456789abcdef') }
			@{ Function = 'Invoke-APIOnypheOnionScan'; Params = @{ Onion = 'abcdefghij234567.onion' }; ExpectedRequest = 'v2/simple/onionscan/abcdefghij234567.onion'; ExpectedAPIInfo = 'onionscan'; ExpectedAPIInput = @('abcdefghij234567.onion') }
			@{ Function = 'Invoke-APIOnypheResolver'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/resolver/9.9.9.9'; ExpectedAPIInfo = 'resolver'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheResolverReverse'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/resolver/reverse/9.9.9.9'; ExpectedAPIInfo = 'reverse'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheResolverForward'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/resolver/forward/9.9.9.9'; ExpectedAPIInfo = 'forward'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheThreatlist'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/threatlist/9.9.9.9'; ExpectedAPIInfo = 'threatlist'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIBestOnypheThreatlist'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/threatlist/best/9.9.9.9'; ExpectedAPIInfo = 'threatlist/best'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheTopSite'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/topsite/9.9.9.9'; ExpectedAPIInfo = 'topsite'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheVulnscan'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/vulnscan/9.9.9.9'; ExpectedAPIInfo = 'vulnscan'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheDataScan'; Params = @{ IPOrDataScanString = '9.9.9.9' }; ExpectedRequest = 'v2/simple/datascan/9.9.9.9'; ExpectedAPIInfo = 'datascan'; ExpectedAPIInput = '9.9.9.9' }
			@{ Function = 'Invoke-APIOnypheDataShot'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/datashot/9.9.9.9'; ExpectedAPIInfo = 'datashot'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheOnionShot'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/onionshot/9.9.9.9'; ExpectedAPIInfo = 'onionshot'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIOnypheGeoloc'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/geoloc/9.9.9.9'; ExpectedAPIInfo = 'geoloc'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APIBestOnypheGeoloc'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/simple/geoloc/best/9.9.9.9'; ExpectedAPIInfo = 'geoloc/best'; ExpectedAPIInput = @('9.9.9.9') }
		)

		It '<Function> calls Invoke-OnypheAPIV2 with the expected request/APIInfo/APIInput and APIKeyrequired $true' -TestCases $cases {
			# PSScriptAnalyzer's PSReviewUnusedParameter can't see these are read inside the nested Should -ParameterFilter scriptblock below.
			param($Function, $Params, $ExpectedRequest, $ExpectedAPIInfo, $ExpectedAPIInput)

			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

			& $Function @Params | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$actualInput = @($APIInput)
				$expectedInput = @($ExpectedAPIInput)
				($request -eq $ExpectedRequest) -and
				($APIInfo -eq $ExpectedAPIInfo) -and
				($APIKeyrequired -eq $true) -and
				($actualInput.Count -eq $expectedInput.Count) -and
				(-not (Compare-Object -ReferenceObject $expectedInput -DifferenceObject $actualInput))
			}
		}

		It 'Invoke-APIOnypheWhois appends a page query parameter when -Page is supplied' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

			Invoke-APIOnypheWhois -IP '9.9.9.9' -Page '2' | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$page -eq '2'
			}
		}

		It 'Invoke-APIOnypheWhois passes -FuncInput through to Invoke-OnypheAPIV2' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

			Invoke-APIOnypheWhois -IP '9.9.9.9' -FuncInput @{ SearchType = 'whois' } | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$FuncInput['SearchType'] -eq 'whois'
			}
		}

		It 'Invoke-APIOnypheWhois calls Set-OnypheAPIKey when -APIKey is supplied' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }
			Mock Set-OnypheAPIKey { }

			Invoke-APIOnypheWhois -IP '9.9.9.9' -APIKey ('x' * 40) | Out-Null

			Should -Invoke Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
				$APIKey -eq ('x' * 40)
			}
		}

		It 'Invoke-APIOnypheUser passes -UseBetaFeatures through to Invoke-OnypheAPIV2' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

			Invoke-APIOnypheUser -UseBetaFeatures | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$UseBetaFeatures -eq $true
			}
		}
	}
}
