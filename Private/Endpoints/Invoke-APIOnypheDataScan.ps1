	Function Invoke-APIOnypheDataScan {
  <#
		.SYNOPSIS 
		create several input for Invoke-OnypheAPIV2 function and then call it to get the data scan info from datascan API

		.DESCRIPTION
		create several input for Invoke-OnypheAPIV2 function and then call it to get the data scan info from datascan API
		
		.PARAMETER IPOrDataScanString
		-IPOrDataScanString string{IP}
		IP to be used for the DataScan API usage
		-IPOrDataScanString string
		string to be used for the DataScan API usage

		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.

		.PARAMETER Page
		-page string{page number}
		go directly to a specific result page (1 to 1000)
		
		.OUTPUTS
		TypeName: PSOnyphe

		.EXAMPLE
		get all data scan info for IP 27.251.29.154
		C:\PS> Invoke-APIOnypheDataScan -IPOrDataScanString 27.251.29.154

		.EXAMPLE
		get all info for info available for PanWeb web server
		C:\PS> Invoke-APIOnypheDataScan -IPOrDataScanString "PanWeb"

		.EXAMPLE
		get all data scan info for IP 27.251.29.154 and set the api key
		C:\PS> Invoke-APIOnypheDataScan -IPOrDataScanString 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #> 
 [cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateNotNullOrEmpty()]
			[string]$IPOrDataScanString,
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
			request = "v2/simple/datascan/$($IPOrDataScanString)"
			APIInput = "$($IPOrDataScanString)"
			APIInfo = "datascan"
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
