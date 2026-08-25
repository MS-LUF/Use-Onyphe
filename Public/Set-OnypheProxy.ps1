	Function Set-OnypheProxy {
	<#
	  .SYNOPSIS 
	  Set an internet proxy to use onyphe web api
  
	  .DESCRIPTION
	  Set an internet proxy to use onyphe web api

	  .PARAMETER DirectNoProxy
	  -DirectNoProxy
	  Remove proxy and configure Onyphe powershell functions to use a direct connection
	
	  .PARAMETER Proxy
	  -Proxy{Proxy}
	  Set the proxy URL

	  .PARAMETER ProxyCredential
	  -ProxyCredential{ProxyCredential}
	  Set the proxy credential to be authenticated with the internet proxy set

	  .PARAMETER ProxyUseDefaultCredentials
	  -ProxyUseDefaultCredentials
	  Use current security context to be authenticated with the internet proxy set

	  .PARAMETER AnonymousProxy
	  -AnonymousProxy
	  No authentication (open proxy) with the internet proxy set

	  .OUTPUTS
	  none
	  
	  .EXAMPLE
	  Remove Internet Proxy and set a direct connection
	  C:\PS> Set-OnypheProxy -DirectNoProxy

	  .EXAMPLE
	  Set Internet Proxy and with manual authentication
	  $credentials = get-credential 
	  C:\PS> Set-OnypheProxy -Proxy "http://myproxy:8080" -ProxyCredential $credentials

	  .EXAMPLE
	  Set Internet Proxy and with automatic authentication based on current security context
	  C:\PS> Set-OnypheProxy -Proxy "http://myproxy:8080" -ProxyUseDefaultCredentials

	  .EXAMPLE
	  Set Internet Proxy and with no authentication 
	  C:\PS> Set-OnypheProxy -Proxy "http://myproxy:8080" -AnonymousProxy
	#>
	[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Low')]
	Param (
	  [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
		  [switch]$DirectNoProxy,
	  [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true)]
	    [string]$Proxy,
	  [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
	    [Management.Automation.PSCredential]$ProxyCredential,
	  [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
		  [Switch]$ProxyUseDefaultCredentials,
	  [Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$false)]
		  [Switch]$AnonymousProxy
	)
	$Config = Read-OnypheConfigFile
	Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
	if ($DirectNoProxy.IsPresent){
		if ($PSCmdlet.ShouldProcess('Use-Onyphe session proxy settings', 'Remove')) {
			$global:OnypheProxyParams = $null
		}
	} ElseIf ($Proxy) {
		if ($PSCmdlet.ShouldProcess('Use-Onyphe session proxy settings', 'Set')) {
			$global:OnypheProxyParams = @{}
			$OnypheProxyParams.Add('Proxy', $Proxy)
			if ($ProxyCredential){
				$OnypheProxyParams.Add('ProxyCredential', $ProxyCredential)
				If ($OnypheProxyParams.ProxyUseDefaultCredentials) {$OnypheProxyParams.Remove('ProxyUseDefaultCredentials')}
			} Elseif ($ProxyUseDefaultCredentials.IsPresent){
				$OnypheProxyParams.Add('ProxyUseDefaultCredentials', $ProxyUseDefaultCredentials)
				If ($OnypheProxyParams.ProxyCredential) {$OnypheProxyParams.Remove('ProxyCredential')}
			} ElseIf ($AnonymousProxy.IsPresent) {
				If ($OnypheProxyParams.ProxyUseDefaultCredentials) {$OnypheProxyParams.Remove('ProxyUseDefaultCredentials')}
				If ($OnypheProxyParams.ProxyCredential) {$OnypheProxyParams.Remove('ProxyCredential')}
			}
		}
	}
  	}
