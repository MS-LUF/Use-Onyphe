	Function Invoke-APIOnypheResolverReverse {
  <#
		.SYNOPSIS 
		create several input for Invoke-OnypheAPIV2 function and then call it to get the reverse dns info from reverse API

		.DESCRIPTION
		create several input for Invoke-OnypheAPIV2 function and then call it to get the reverse dns info from reverse API
		
		.PARAMETER IP
		-IP string{IP}
		IP to be used for the reverse API usage
		
		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.

		.PARAMETER Page
		-page string{page number}
		go directly to a specific result page (1 to 1000)
		
		.OUTPUTS
		TypeName: PSOnyphe
		
		.EXAMPLE
		get reverse dns info info for IP 8.8.8.8
		C:\PS> Invoke-APIOnypheReverse -IP 8.8.8.8

		.EXAMPLE
		get reverse dns info info for IP 8.8.8.8 ans set the api key
		C:\PS> Invoke-APIOnypheResolverReverse -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
  [cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateScript({Test-OnypheIPAddress -IPAddress $_})]
			[string]$IP, 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
		[ValidateScript({$_ -match "^((?!0)\d+)$"})]
			[string]$Page,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
  )
	Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/simple/resolver/reverse/$($IP)"
			APIInfo = "reverse"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($page) {$params.add('page',$page)}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	}
	}
