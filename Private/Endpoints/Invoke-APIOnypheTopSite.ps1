	Function Invoke-APIOnypheTopSite {
	<#
			  .SYNOPSIS
			  create several input for Invoke-OnypheAPIV2 function and then call it to get the topsite info from topsite API

			  .DESCRIPTION
			  create several input for Invoke-OnypheAPIV2 function and then call it to get the topsite info from topsite API
			  
			  .PARAMETER IP
			  -IP string{IP}
			  IP to be used for the topsite API usage
			  
			  .PARAMETER APIKEY
			  -APIKey string{APIKEY}
			  Set APIKEY as global variable.
	  
			  .PARAMETER Page
			  -page string{page number}
			  go directly to a specific result page (1 to 1000)
				  
			  .OUTPUTS
			  TypeName: PSOnyphe
	  
			  .EXAMPLE
			  get all topsite info for IP 178.250.241.22
			  C:\PS> Invoke-APIOnypheTopsite -IP 178.250.241.22
	  
			  .EXAMPLE
			  get all topsite info for IP 178.250.241.22 and set the api key
			  C:\PS> Invoke-APIOnypheTopsite -IP 178.250.241.22 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
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
				  request = "v2/simple/topsite/$($IP)"
				  APIInfo = "topsite"
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
