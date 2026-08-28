	Function Invoke-APISummaryOnypheDomain {
	<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an internet domain from Summary/domain API
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an internet domain from  Summary/domain API
		  
		  .PARAMETER Domain
		  -Domain string{Domain}
		  Domain to be used for the Summary/domain API API usage

		  .PARAMETER APIKEY
		 -APIKey string{APIKEY}
		 Set APIKEY as global variable.

	      .PARAMETER Page
	      -page string{page number}
	      go directly to a specific result page (1 to 1000)
	      NOTE: this API does not actually paginate - live-confirmed (2026-08-28) that any
	      -page value returns the same first page of results, with no error or warning
	      (the server always reports page:1 back, regardless of what page was requested).
	      Use Search-OnypheInfo/Export-OnypheInfo instead if you need more results than a
	      single page returns for this category.

		  .OUTPUTS
		  TypeName: PSOnyphe
		  
		  .EXAMPLE
		  get all onyphe info for domain perdu.com
		  C:\PS> Invoke-APISummaryOnypheDomain -Domain perdu.com

		  .EXAMPLE
		  get all onyphe info for domain perdu.com and set the API Key
		  C:\PS> Invoke-APISummaryOnypheDomain -Domain perdu.com -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	#> 
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -match "^([a-z0-9]+(-[a-z0-9]+)*\.)+[a-z]{2,}$")})]
				[string]$Domain, 
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
				request = "v2/summary/domain/$($Domain)"
				APIInfo = "summary/domain"
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
