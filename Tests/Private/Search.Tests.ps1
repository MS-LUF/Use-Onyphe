BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Private/Search wrappers' -Tag 'Unit' {
	InModuleScope 'Use-Onyphe' {

		BeforeEach {
			$script:SavedAPIKey = $global:OnypheAPIKey
			$global:OnypheAPIKey = $null
			$script:OutFilePath = Join-Path $TestDrive 'search-output.json'
		}

		AfterEach {
			$global:OnypheAPIKey = $script:SavedAPIKey
		}

		Context 'Invoke-APIOnypheSearch' {
			It 'builds the request from -AdvancedSearch criteria' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'datascan' -AdvancedSearch @('product:Apache', 'port:443', 'os:Windows') | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($request -eq 'v2/search/') -and
					($QueryValue -eq 'category:datascan product:Apache port:443 os:Windows') -and
					($APIInfo -eq 'search/datascan') -and
					($APIKeyrequired -eq $true) -and
					(@($APIInput)[0] -eq 'product:Apache port:443 os:Windows')
				}
			}

			It 'builds the request from -SearchValue/-SearchFilter' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'threatlist' -SearchValue 'RU' -SearchFilter 'country' | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($request -eq 'v2/search/') -and
					($QueryValue -eq 'category:threatlist country:RU') -and
					($APIInfo -eq 'search/threatlist') -and
					($APIKeyrequired -eq $true) -and
					(@($APIInput)[0] -eq 'country:RU')
				}
			}

			It 'passes the OQL query as -QueryValue rather than embedding it in the URL path (so a literal "?" OR-prefix cannot be mistaken for the start of the query string)' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'resolver' -AdvancedSearch @('?domain:a.com', '?domain:b.com') | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($request -eq 'v2/search/') -and
					($QueryValue -eq 'category:resolver ?domain:a.com ?domain:b.com')
				}
			}

			It 'passes OQLv2 condition-group parentheses through untouched when "(" and ")" are their own -AdvancedSearch elements' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'resolver' -AdvancedSearch @('(', '?domain:a.com', '?domain:b.com', ')', '(', '?tld:fr', ')') | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($request -eq 'v2/search/') -and
					($QueryValue -eq 'category:resolver ( ?domain:a.com ?domain:b.com ) ( ?tld:fr )')
				}
			}

			It 'documents the known gotcha: an OQLv2 group and a filter:value pair combined in one -AdvancedSearch string element get corrupted by multi-word auto-quoting' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				# "(" and the condition must be separate array elements (see the test above) - combining them
				# in one element like this is a real, documented footgun, not a supported usage.
				Invoke-APIOnypheSearch -SearchType 'resolver' -AdvancedSearch @('( domain:a.com )') | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					$QueryValue -eq 'category:resolver ( domain:"a.com )"'
				}
			}

			It 'appends a page query parameter when -Page is supplied' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'threatlist' -SearchValue 'RU' -SearchFilter 'country' -Page '2' | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					$page -eq '2'
				}
			}

			It 'calls Set-OnypheAPIKey when -APIKey is supplied' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }
				Mock Set-OnypheAPIKey { }

				Invoke-APIOnypheSearch -SearchType 'threatlist' -SearchValue 'RU' -SearchFilter 'country' -APIKey ('x' * 40) | Out-Null

				Should -Invoke Set-OnypheAPIKey -Times 1 -Exactly -ParameterFilter {
					$APIKey -eq ('x' * 40)
				}
			}

			It 'does not throw when an -AdvancedFilter entry has no colon' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				{ Invoke-APIOnypheSearch -SearchType 'datascan' -AdvancedSearch @('port:443') -AdvancedFilter @('exists') } | Should -Not -Throw
			}

			It 'passes -Size through to Invoke-OnypheAPIV2 as -size' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'threatlist' -SearchValue 'RU' -SearchFilter 'country' -Size 500 | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					$size -eq 500
				}
			}

			It 'passes -TrackQuery and -Calculated through to Invoke-OnypheAPIV2' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'threatlist' -SearchValue 'RU' -SearchFilter 'country' -TrackQuery -Calculated | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($TrackQuery -eq $true) -and ($Calculated -eq $true)
				}
			}

			It 'passes a "!"-prefixed filter name through -AdvancedSearch unchanged (OQL NOT)' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'threatlist' -AdvancedSearch @('category:threatlist', '!country:RU') | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					(@($APIInput)[0]) -eq 'category:threatlist !country:RU'
				}
			}

			It 'passes a "?"-prefixed filter name through -AdvancedSearch unchanged (OQL OR)' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'threatlist' -AdvancedSearch @('?country:RU', '?country:CN') | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					(@($APIInput)[0]) -eq '?country:RU ?country:CN'
				}
			}

			It 'keeps each -orwildcard condition as its own function occurrence (repeated -AdvancedFilter entries, not comma-packed)' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'resolver' -AdvancedFilter @('orwildcard:domain,g?ogle.com', 'orwildcard:domain,googl?.com') | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					(@($APIInput)[0]) -eq '-orwildcard:domain,g?ogle.com -orwildcard:domain,googl?.com'
				}
			}

			It 'quotes the whole value after the first comma when it itself contains a comma and needs quoting (was previously only checking the 2nd segment, dropping quoting for anything after a 2nd comma)' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheSearch -SearchType 'ctl' -AdvancedFilter @('wildcard:organization,foo,bar baz') | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					(@($APIInput)[0]) -eq '-wildcard:organization,"foo,bar baz"'
				}
			}
		}

		Context 'Invoke-APIOnypheExport' {
			It 'builds the request from -SearchValue/-SearchFilter and streams to -OutFile' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheExport -SearchType 'threatlist' -SearchValue 'RU' -SearchFilter 'country' -OutFile $script:OutFilePath | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($request -eq 'v2/export/') -and
					($QueryValue -eq 'category:threatlist country:RU') -and
					($APIInfo -eq 'export/threatlist') -and
					($APIKeyrequired -eq $true) -and
					($Stream -eq $true) -and
					($OutFile -eq $script:OutFilePath) -and
					(@($APIInput)[0] -eq 'country:RU')
				}
			}

			It 'throws when -OutFile already exists' {
				$existingOutFile = Join-Path $TestDrive 'already-there.json'
				Set-Content -Path $existingOutFile -Value '{}'

				{ Invoke-APIOnypheExport -SearchType 'threatlist' -SearchValue 'RU' -SearchFilter 'country' -OutFile $existingOutFile } | Should -Throw
			}

			It 'does not throw when an -AdvancedFilter entry has no colon' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				{ Invoke-APIOnypheExport -SearchType 'datascan' -AdvancedSearch @('port:443') -AdvancedFilter @('exists') -OutFile (Join-Path $TestDrive 'export-advfilter.json') } | Should -Not -Throw
			}

			It 'passes -TrackQuery and -Calculated through to Invoke-OnypheAPIV2' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheExport -SearchType 'threatlist' -SearchValue 'RU' -SearchFilter 'country' -TrackQuery -Calculated -OutFile $script:OutFilePath | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($TrackQuery -eq $true) -and ($Calculated -eq $true)
				}
			}

			It 'keeps each -orwildcard condition as its own function occurrence (repeated -AdvancedFilter entries, not comma-packed)' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheExport -SearchType 'resolver' -AdvancedFilter @('orwildcard:domain,g?ogle.com', 'orwildcard:domain,googl?.com') -OutFile $script:OutFilePath | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					(@($APIInput)[0]) -eq '-orwildcard:domain,g?ogle.com -orwildcard:domain,googl?.com'
				}
			}

			It 'passes OQLv2 condition-group parentheses through untouched when "(" and ")" are their own -AdvancedSearch elements' {
				Mock Invoke-OnypheAPIV2 { [pscustomobject]@{ status = 'ok' } }

				Invoke-APIOnypheExport -SearchType 'resolver' -AdvancedSearch @('(', '?domain:a.com', '?domain:b.com', ')', '(', '?tld:fr', ')') -OutFile $script:OutFilePath | Out-Null

				Should -Invoke Invoke-OnypheAPIV2 -Times 1 -Exactly -ParameterFilter {
					($request -eq 'v2/export/') -and
					($QueryValue -eq 'category:resolver ( ?domain:a.com ?domain:b.com ) ( ?tld:fr )')
				}
			}
		}
	}
}
