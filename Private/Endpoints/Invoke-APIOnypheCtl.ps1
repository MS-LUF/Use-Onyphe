	Function Invoke-APIOnypheCtl {
	<#
	.SYNOPSIS 
	create several input for Invoke-OnypheAPIV2 function and then call it to get the CTL (certificate transparancy) info from ctl API

	.DESCRIPTION
	create several input for Invoke-OnypheAPIV2 function and then call it to get the CTL (certificate transparancy) info from ctl API
	
	.PARAMETER Domain
	-Domain string{Domain or FQDN}
	Domain or FQDN to be used for the ctl API usage
	
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
	get CTL info for fnac.com
	C:\PS> Invoke-APIOnypheCtl -Domain fnac.com

	.EXAMPLE
	get CTL info for fnac.com and set the api key
	C:\PS> Invoke-APIOnypheCtl -Domain fnac.com -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  #>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$")})]
				[string[]]$Domain, 
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
				request = "v2/simple/ctl/$($Domain)"
				APIInfo = "ctl"
				APIInput = @("$($Domain)")
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
