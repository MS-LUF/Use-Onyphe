	Function Invoke-APIBestOnypheInetnum {
  <#
	.SYNOPSIS 
	create several input for Invoke-OnypheAPIV2 function and then call it to get the inetnum info from inetnum best API

	.DESCRIPTION
	create several input for Invoke-OnypheAPIV2 function and then call it to get the inetnum info from inetnum best API
	
	.PARAMETER IP
	-IP string{IP}
	IP to be used for the geoloc API usage
	
	.PARAMETER APIKEY
	-APIKey string{APIKEY}
	Set APIKEY as global variable.

	.PARAMETER Page
	-page string{page number}
	go directly to a specific result page (1 to 1000)
	
	.OUTPUTS
	TypeName: PSOnyphe

	.EXAMPLE
	get inetnum info for subnet 93.184.208.0
	C:\PS> Invoke-APIBestOnypheInetnum -IP 93.184.208.0

	.EXAMPLE
	get inetnum info for subnet 93.184.208.0 and set the api key
	C:\PS> Invoke-APIBestOnypheInetnum -IP 93.184.208.0 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
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
			request = "v2/simple/inetnum/best/$($IP)"
			APIInfo = "inetnum/best"
			APIInput = @("$($IP)")
			APIKeyrequired = $true
		}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		if ($page) {$params.add('page',$page)}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	}
	}
