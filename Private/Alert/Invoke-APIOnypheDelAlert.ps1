	Function Invoke-APIOnypheDelAlert {
	<#
	  .SYNOPSIS 
	  create several input for Invoke-OnypheAPIv2 function and then call it to delete an alert already create using alert/del API
  
	  .DESCRIPTION
	  create several input for Invoke-OnypheAPIv2 function and then call it to delete an alert already create using alert/del API
	  	  
	  .PARAMETER APIKEY
	  -APIKey string{APIKEY}
	  Set APIKEY as global variable.
	  
	  .PARAMETER AlertID
	  -AlertID string{ID}
	   mandatory input containing the ID of the alert to be deleted
		
	  .PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe
	  
	  .OUTPUTS
	   TypeName: PSOnyphe

	  .EXAMPLE
	  Delete Onyphe Alert with ID 0 and set api key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	  C:\PS> Invoke-APIOnypheDelAlert -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -AlertID 0

	  .EXAMPLE
	  Delete Onyphe Alert with ID 0
	  C:\PS> Invoke-APIOnypheDelAlert -AlertID 0
	#>
	[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
	Param (
		[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
			[string]$APIKey,
		[parameter(Mandatory=$false)]
			[switch]$UseBetaFeatures,
		[parameter(Mandatory=$true)]
		[ValidateScript({($_ -match "^[0-9]*$")})]
			[string]$AlertID,
		[parameter(mandatory=$false)]
		[ValidateNotNullOrEmpty()]
			[hashtable]$FuncInput
	) 
	  Process {
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		$params = @{
			request = "v2/alert/del/$($AlertID)"
			APIInfo = "alert/del"
			APIInput = "$($AlertID)"
			Method = "POST"
			APIKeyrequired = $true
		}
		if ($UseBetaFeatures) {
			$params.add("UseBetaFeatures", $true)
		}
		if ($FuncInput) {
			$params.add("FuncInput", $FuncInput)
		}
		Write-Verbose -message "URL Info : $($params.request)"
		if ($PSCmdlet.ShouldProcess($AlertID, 'Delete Onyphe alert')) {
			Invoke-OnypheAPIV2 @params
		}
	  }
	}
