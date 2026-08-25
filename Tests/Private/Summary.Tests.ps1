BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Private/Summary wrappers' -Tag 'Unit' {
	InModuleScope 'Use-Onyphe' {

		BeforeEach {
			$script:SavedAPIKey = $global:OnypheAPIKey
			$global:OnypheAPIKey = $null
		}

		AfterEach {
			$global:OnypheAPIKey = $script:SavedAPIKey
		}

		$cases = @(
			@{ Function = 'Invoke-APISummaryOnypheIP'; Params = @{ IP = '9.9.9.9' }; ExpectedRequest = 'v2/summary/ip/9.9.9.9'; ExpectedAPIInfo = 'summary/ip'; ExpectedAPIInput = @('9.9.9.9') }
			@{ Function = 'Invoke-APISummaryOnypheHostname'; Params = @{ Hostname = 'example.com' }; ExpectedRequest = 'v2/summary/hostname/example.com'; ExpectedAPIInfo = 'summary/hostname'; ExpectedAPIInput = @('example.com') }
			@{ Function = 'Invoke-APISummaryOnypheDomain'; Params = @{ Domain = 'example.com' }; ExpectedRequest = 'v2/summary/domain/example.com'; ExpectedAPIInfo = 'summary/domain'; ExpectedAPIInput = @('example.com') }
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

		It 'Invoke-APISummaryOnypheIP appends a page query parameter when -Page is supplied' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

			Invoke-APISummaryOnypheIP -IP '9.9.9.9' -Page '2' | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$page -eq '2'
			}
		}

		It 'Invoke-APISummaryOnypheIP passes -FuncInput through to Invoke-OnypheAPIV2' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

			Invoke-APISummaryOnypheIP -IP '9.9.9.9' -FuncInput @{ SummaryAPIType = 'ip' } | Out-Null

			Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
				$FuncInput['SummaryAPIType'] -eq 'ip'
			}
		}

		It 'Invoke-APISummaryOnypheIP calls Set-OnypheAPIKey when -APIKey is supplied' {
			Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }
			Mock Set-OnypheAPIKey { }

			Invoke-APISummaryOnypheIP -IP '9.9.9.9' -APIKey ('x' * 40) | Out-Null

			Should -Invoke Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
				$APIKey -eq ('x' * 40)
			}
		}
	}
}
