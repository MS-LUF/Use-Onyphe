	Function Invoke-APIOnyphePastries {
  <#
	.SYNOPSIS 
	create several input for Invoke-OnypheAPIV2 function and then call it to get the pastries (pastebin) info from pastries API

	.DESCRIPTION
	create several input for Invoke-OnypheAPIV2 function and then call it to get the pastries (pastebin) info from pastries API
	
	.PARAMETER IP
	-IP string{IP}
	IP to be used for the pastries API usage
	
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
	get all pastries info for IP 8.8.8.8
	C:\PS> Invoke-APIOnyphePastries -IP 8.8.8.8

	.EXAMPLE
	get all pastries info for IP 8.8.8.8 and set the api key
	C:\PS> Invoke-APIOnyphePastries -IP 8.8.8.8 -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
  [cmdletbinding()]
  Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[Alias("input")]
		[ValidateScript({Test-OnypheIPAddress -IPAddress $_})]
			[string[]]$IP, 
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
			request = "v2/simple/pastries/$($IP)"
			APIInfo = "pastries"
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
