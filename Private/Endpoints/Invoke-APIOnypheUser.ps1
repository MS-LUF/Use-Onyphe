	Function Invoke-APIOnypheUser {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-OnypheAPIV2 function and then call it to get the user account info from user API
  
	  .DESCRIPTION
	  create several input for Invoke-OnypheAPIV2 function and then call it to get the user account info from user API
	  	  
	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
		Set APIKEY as global variable.
		
		.PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe
	  
	  .OUTPUTS
		 TypeName: PSOnyphe
  
	  .EXAMPLE
	  get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx and set the api key
	  C:\PS> Invoke-APIOnypheUser -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	  .EXAMPLE
	  get user account info for api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx already set as global variable
	  C:\PS> Invoke-APIOnypheUser
	#>
	[cmdletbinding()]
	Param ( 
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$UseBetaFeatures,
		[parameter(Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
	)  
	  Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{
				request = "v2/user/"
				APIInfo = "user"
				APIInput = "none"
				APIKeyrequired = $true
			}
			if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			}
			if ($UseBetaFeatures) {
				$params.add("UseBetaFeatures", $true)
			}
			Write-Verbose -message "URL Info : $($params.request)"  
			Invoke-OnypheAPIV2 @params
		}
    }
