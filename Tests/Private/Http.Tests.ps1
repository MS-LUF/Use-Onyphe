BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Invoke-OnypheAPIV2' -Tag 'Unit' {
	InModuleScope 'Use-Onyphe' {

		BeforeEach {
			$script:SavedAPIKey = $global:OnypheAPIKey
			$script:SavedProxyParams = $global:OnypheProxyParams
			$global:OnypheAPIKey = $null
			$global:OnypheProxyParams = $null
		}

		AfterEach {
			$global:OnypheAPIKey = $script:SavedAPIKey
			$global:OnypheProxyParams = $script:SavedProxyParams
		}

		It 'returns a PSOnyphe-typed object built from the JSON response body on a successful GET request' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok","count":1,"results":[{"ip":"9.9.9.9"}]}'
					Headers = @{}
				}
			}

			$result = Invoke-OnypheAPIV2 -request 'ip/9.9.9.9' -APIInfo 'ip' -APIInput '9.9.9.9' -APIKeyrequired $false

			$result.PSObject.TypeNames | Should -Contain 'PSOnyphe'
			$result.status | Should -Be 'ok'
			$result.'cli-API_info' | Should -Be 'ip'
			$result.'cli-API_input' | Should -Be '9.9.9.9'
			$result.'cli-API_version' | Should -Be '2'
			$result.'cli-key_required' | Should -Be $false
			Should -Invoke Invoke-WebRequest -Times 1 -Exactly
		}

		It 'throws when an API key is required but $global:OnypheAPIKey is not set' {
			{ Invoke-OnypheAPIV2 -request 'user' -APIInfo 'user' -APIInput 'me' -APIKeyrequired $true } |
				Should -Throw 'Please provide an APIKey with -APIKEY parameter'
		}

		It 'attaches an Authorization header built from $global:OnypheAPIKey when the API key is required' {
			$global:OnypheAPIKey = 'test-api-key'
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok"}'
					Headers = @{}
				}
			}

			Invoke-OnypheAPIV2 -request 'user' -APIInfo 'user' -APIInput 'me' -APIKeyrequired $true | Out-Null

			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
				$Headers['Authorization'] -eq 'apikey test-api-key'
			}
		}

		It 'appends a page query string parameter to the request URL when -page is supplied' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok"}'
					Headers = @{}
				}
			}

			Invoke-OnypheAPIV2 -request 'search' -APIInfo 'search' -APIInput 'q' -APIKeyrequired $false -page '2' | Out-Null

			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
				$URI -eq 'https://www.onyphe.io/api/search?page=2'
			}
		}

		It 'appends a size query string parameter to the request URL when -size is supplied' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok"}'
					Headers = @{}
				}
			}

			Invoke-OnypheAPIV2 -request 'search' -APIInfo 'search' -APIInput 'q' -APIKeyrequired $false -size 500 | Out-Null

			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
				$URI -eq 'https://www.onyphe.io/api/search?size=500'
			}
		}

		It 'appends trackquery and calculated query string parameters to the request URL when supplied' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok"}'
					Headers = @{}
				}
			}

			Invoke-OnypheAPIV2 -request 'search' -APIInfo 'search' -APIInput 'q' -APIKeyrequired $false -TrackQuery -Calculated | Out-Null

			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
				$URI -eq 'https://www.onyphe.io/api/search?trackquery=true&calculated=true'
			}
		}

		It 'combines page, size, trackquery and calculated into a single query string, joined with &' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok"}'
					Headers = @{}
				}
			}

			Invoke-OnypheAPIV2 -request 'search' -APIInfo 'search' -APIInput 'q' -APIKeyrequired $false -page '2' -size 500 -TrackQuery -Calculated | Out-Null

			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
				$URI -eq 'https://www.onyphe.io/api/search?page=2&size=500&trackquery=true&calculated=true'
			}
		}

		It 'encodes -QueryValue as a q= query string parameter via EscapeDataString (so a literal "?" OR-prefix survives instead of being parsed as the start of the query string)' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok"}'
					Headers = @{}
				}
			}

			Invoke-OnypheAPIV2 -request 'v2/search/' -APIInfo 'search' -APIInput 'q' -APIKeyrequired $false -QueryValue 'category:resolver ?domain:a.com ?domain:b.com' | Out-Null

			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
				$URI -eq 'https://www.onyphe.io/api/v2/search/?q=category%3Aresolver%20%3Fdomain%3Aa.com%20%3Fdomain%3Ab.com'
			}
		}

		It 'puts -QueryValue before page/size/trackquery/calculated in the combined query string' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok"}'
					Headers = @{}
				}
			}

			Invoke-OnypheAPIV2 -request 'v2/search/' -APIInfo 'search' -APIInput 'q' -APIKeyrequired $false -QueryValue 'category:resolver domain:a.com' -page '2' -size 50 | Out-Null

			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
				$URI -eq 'https://www.onyphe.io/api/v2/search/?q=category%3Aresolver%20domain%3Aa.com&page=2&size=50'
			}
		}

		It 'warns when the server returns fewer results per page than requested via -size, and total indicates more are available' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok","count":10,"total":5020,"results":[]}'
					Headers = @{}
				}
			}

			$warnings = Invoke-OnypheAPIV2 -request 'v2/search/' -APIInfo 'search' -APIInput 'q' -APIKeyrequired $false -size 1000 3>&1 |
				Where-Object { $_ -is [System.Management.Automation.WarningRecord] }

			$warnings.Count | Should -Be 1
			$warnings[0].Message | Should -Match 'fewer than the requested -Size 1000'
		}

		It 'does not warn when the returned count already matches the requested -size' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok","count":100,"total":5020,"results":[]}'
					Headers = @{}
				}
			}

			$warnings = Invoke-OnypheAPIV2 -request 'v2/search/' -APIInfo 'search' -APIInput 'q' -APIKeyrequired $false -size 100 3>&1 |
				Where-Object { $_ -is [System.Management.Automation.WarningRecord] }

			$warnings.Count | Should -Be 0
		}

		It 'does not warn when total does not exceed the returned count (nothing more to fetch)' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok","count":10,"total":10,"results":[]}'
					Headers = @{}
				}
			}

			$warnings = Invoke-OnypheAPIV2 -request 'v2/search/' -APIInfo 'search' -APIInput 'q' -APIKeyrequired $false -size 1000 3>&1 |
				Where-Object { $_ -is [System.Management.Automation.WarningRecord] }

			$warnings.Count | Should -Be 0
		}

		It 'does not append a query string when none of -page/-size/-TrackQuery/-Calculated are supplied' {
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok"}'
					Headers = @{}
				}
			}

			Invoke-OnypheAPIV2 -request 'search' -APIInfo 'search' -APIInput 'q' -APIKeyrequired $false | Out-Null

			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
				$URI -eq 'https://www.onyphe.io/api/search'
			}
		}

		It 'merges $global:OnypheProxyParams into the Invoke-WebRequest call when set' {
			$global:OnypheProxyParams = @{ Proxy = 'http://myproxy:3128'; ProxyUseDefaultCredentials = $true }
			Mock Invoke-WebRequest {
				[pscustomobject]@{
					Content = '{"status":"ok"}'
					Headers = @{}
				}
			}

			Invoke-OnypheAPIV2 -request 'user' -APIInfo 'user' -APIInput 'me' -APIKeyrequired $false | Out-Null

			Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
				$Proxy -eq 'http://myproxy:3128' -and $ProxyUseDefaultCredentials -eq $true
			}
		}
	}
}
