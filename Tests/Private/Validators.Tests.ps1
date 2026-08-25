BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Private/Validators functions' -Tag 'Unit' {
	InModuleScope 'Use-Onyphe' {

		Context 'Test-OnypheIPAddress' {
			It 'accepts a valid IPv4 address' {
				Test-OnypheIPAddress -IPAddress '8.8.8.8' | Should -BeTrue
			}

			It 'accepts a valid IPv6 address' {
				Test-OnypheIPAddress -IPAddress '2001:4860:4860::8888' | Should -BeTrue
			}

			It 'accepts an IPv6 address with a zone id' {
				Test-OnypheIPAddress -IPAddress 'fe80::1%eth0' | Should -BeTrue
			}

			It 'rejects a string with a valid IP as a substring' {
				Test-OnypheIPAddress -IPAddress 'garbage8.8.8.8garbage' | Should -BeFalse
			}

			It 'rejects an IPv4-looking string followed by extra characters' {
				Test-OnypheIPAddress -IPAddress '8.8.8.8; rm -rf /' | Should -BeFalse
			}

			It 'rejects an out-of-range IPv4 octet' {
				Test-OnypheIPAddress -IPAddress '256.1.1.1' | Should -BeFalse
			}

			It 'rejects a non-IP string' {
				Test-OnypheIPAddress -IPAddress 'not an ip' | Should -BeFalse
			}

			It 'rejects an empty string' {
				Test-OnypheIPAddress -IPAddress '' | Should -BeFalse
			}
		}
	}
}
