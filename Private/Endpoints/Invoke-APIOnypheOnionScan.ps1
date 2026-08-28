	Function Invoke-APIOnypheOnionScan {
	<#
		.SYNOPSIS 
		create several input for Invoke-OnypheAPIV2 function and then call it to get info for a .onion link using OnionScan API

		.DESCRIPTION
		create several input for Invoke-OnypheAPIV2 function and then call it to get info for a .onion link using OnionScan API
		
		.PARAMETER Onion
		-Onion string{Onion URL}
		Onion link to be used for the Onion API usage
		
		.PARAMETER APIKEY
		-APIKey string{APIKEY}
		Set APIKEY as global variable.

		.PARAMETER Page
		-page string{page number}
		go directly to a specific result page (1 to 1000)
		NOTE: this API does not actually paginate - live-confirmed (2026-08-28) that any
		-page value returns the same first 100 results, with no error or warning. Use
		Search-OnypheInfo/Export-OnypheInfo instead if you need more than the first 100
		results for this category.
		
		.OUTPUTS
		TypeName: PSOnyphe

		.EXAMPLE
		get md5 info for 3g2upl4pq6kufc4m.onion URL
		C:\PS> Invoke-APIOnypheOnionScan -Onion "3g2upl4pq6kufc4m.onion"

		.EXAMPLE
		get md5 info for 3g2upl4pq6kufc4m.onion URL and set the api key
		C:\PS> Invoke-APIOnypheOnionScan -Onion "3g2upl4pq6kufc4m.onion" -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "[a-z2-7]{16}\.onion") -or ($_ -match "[a-z2-7]{56}\.onion")})]
				[string]$Onion, 
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
				request = "v2/simple/onionscan/$($Onion)"
				APIInfo = "onionscan"
				APIInput = @("$($Onion)")
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
