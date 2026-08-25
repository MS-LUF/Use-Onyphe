	Function Invoke-APIOnypheListAlert {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-OnypheAPIv2 function and then call it to list alert already set from alert/list API
  
	  .DESCRIPTION
	  create several input for Invoke-OnypheAPIv2 function and then call it to list alert already set from alert/list API
	  	  
	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
		Set APIKEY as global variable.
		
		.PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe
	  
	  .OUTPUTS
	   TypeName: PSOnyphe

	  .EXAMPLE
	  get alert set and set api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	  C:\PS> Invoke-APIOnypheListAlert -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	  .EXAMPLE
	  get alert set
	  C:\PS> Invoke-APIOnypheListAlert
	#>
	[cmdletbinding()]
	Param ( 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$UseBetaFeatures,
		[parameter(mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
	)  
	  Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/alert/list/"
			APIInfo = "alert/list"
			APIInput = "none"
			APIKeyrequired = $true
		}
		if ($UseBetaFeatures) {
			$params.add("UseBetaFeatures", $true)
		}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		Invoke-OnypheAPIV2 @params
	  }
	}
