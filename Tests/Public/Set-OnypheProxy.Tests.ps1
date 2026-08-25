BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Set-OnypheProxy' -Tag 'Unit' {
	BeforeEach {
		$script:SavedProxyParams = $global:OnypheProxyParams
		$global:OnypheProxyParams = $null
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
	}

	AfterEach {
		$global:OnypheProxyParams = $script:SavedProxyParams
	}

	It 'clears $global:OnypheProxyParams with -DirectNoProxy' {
		$global:OnypheProxyParams = @{ Proxy = 'http://old:8080' }
		Set-OnypheProxy -DirectNoProxy
		$global:OnypheProxyParams | Should -BeNullOrEmpty
	}

	It 'sets only Proxy in $global:OnypheProxyParams with -Proxy alone' {
		Set-OnypheProxy -Proxy 'http://myproxy:8080'
		$global:OnypheProxyParams.Proxy | Should -Be 'http://myproxy:8080'
		$global:OnypheProxyParams.ContainsKey('ProxyCredential') | Should -BeFalse
		$global:OnypheProxyParams.ContainsKey('ProxyUseDefaultCredentials') | Should -BeFalse
	}

	It 'adds ProxyCredential (and no ProxyUseDefaultCredentials) when -ProxyCredential is supplied' {
		$Cred = New-Object Management.Automation.PSCredential('user', (ConvertTo-SecureString 'pass' -AsPlainText -Force))
		Set-OnypheProxy -Proxy 'http://myproxy:8080' -ProxyCredential $Cred
		$global:OnypheProxyParams.ProxyCredential | Should -Be $Cred
		$global:OnypheProxyParams.ContainsKey('ProxyUseDefaultCredentials') | Should -BeFalse
	}

	It 'adds ProxyUseDefaultCredentials (and no ProxyCredential) when -ProxyUseDefaultCredentials is supplied' {
		Set-OnypheProxy -Proxy 'http://myproxy:8080' -ProxyUseDefaultCredentials
		$global:OnypheProxyParams.ProxyUseDefaultCredentials | Should -BeTrue
		$global:OnypheProxyParams.ContainsKey('ProxyCredential') | Should -BeFalse
	}

	It 'sets only Proxy with -AnonymousProxy (no credential keys added)' {
		Set-OnypheProxy -Proxy 'http://myproxy:8080' -AnonymousProxy
		$global:OnypheProxyParams.Proxy | Should -Be 'http://myproxy:8080'
		$global:OnypheProxyParams.ContainsKey('ProxyCredential') | Should -BeFalse
		$global:OnypheProxyParams.ContainsKey('ProxyUseDefaultCredentials') | Should -BeFalse
	}

	It 'leaves $global:OnypheProxyParams untouched when neither -DirectNoProxy nor -Proxy is supplied' {
		$global:OnypheProxyParams = @{ Proxy = 'http://untouched:8080' }
		Set-OnypheProxy
		$global:OnypheProxyParams.Proxy | Should -Be 'http://untouched:8080'
	}

	It 'does not change $global:OnypheProxyParams when -WhatIf is used' {
		$global:OnypheProxyParams = @{ Proxy = 'http://untouched:8080' }
		Set-OnypheProxy -Proxy 'http://myproxy:8080' -WhatIf
		$global:OnypheProxyParams.Proxy | Should -Be 'http://untouched:8080'
	}
}
