	Function Invoke-APISummaryOnypheIP {
	<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an IP from Geoloc Summary/IP API
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an IP from Geoloc Summary/IP API
		  
		  .PARAMETER IP
		  -IP string{IP}
		  IP to be used for the Summary/IP API usage

		  .PARAMETER APIKEY
		 -APIKey string{APIKEY}
		 Set APIKEY as global variable.

	      .PARAMETER Page
	      -page string{page number}
	      go directly to a specific result page (1 to 1000)

		  .OUTPUTS
		  TypeName: PSOnyphe
		  
		  .EXAMPLE
		  get all onyphe info for IP 8.8.8.8
		  C:\PS> Invoke-APISummaryOnypheIP -IP 8.8.8.8

		  .EXAMPLE
		  get all onyphe info for IP 8.8.8.8 and set the API Key
		  C:\PS> Invoke-APISummaryOnypheIP -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
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
		process {
			 if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null} 
			 $params = @{
				  request = "v2/summary/ip/$($IP)"
				  APIInfo = "summary/ip"
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
