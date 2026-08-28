	Function Invoke-APIBulkDiscoveryOnypheGeoloc {
	<#
		  .SYNOPSIS
		  create several input for Invoke-OnypheAPIV2 function and then call it to run bulk OQL queries against the geoloc category based on a file input from Bulk/discovery/geoloc API
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to run bulk OQL queries against the geoloc category based on a file input from Bulk/discovery/geoloc API
		  requires a Griffin View subscription on Onyphe.

		  .PARAMETER FilePath
		  -FilePath string{full path to an existing text file}
		  full path to input file to send to onyphe API, one OQL query per line (e.g. "protocol:rdp domain:google.com")

		  .PARAMETER OutFile
		  -OutFile string{full path to a new file for exporting json data}
		  full path to output file used to write json data from Onyphe

		  .PARAMETER APIKEY
		 -APIKey string{APIKEY}
		 Set APIKEY as global variable.

		  .PARAMETER Size
		 -Size int{1-10000}
		 number of results Onyphe should return for this query (per query line) - Onyphe defaults to 100 per query line when omitted, silently, with no error or warning.

		  .OUTPUTS
		  TypeName: System.Management.Automation.PSCustomObject

		  .EXAMPLE
		  export geoloc discovery results as JSON for all OQL queries contained in queries.txt
		  C:\PS> Invoke-APIBulkDiscoveryOnypheGeoloc -FilePath .\queries.txt -OutFile .\result.json

		  .EXAMPLE
		  export geoloc discovery results as JSON for all OQL queries contained in queries.txt and set the API Key
		  C:\PS> Invoke-APIBulkDiscoveryOnypheGeoloc -FilePath .\queries.txt -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -OutFile .\result.json
	#>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({(test-path $_)})]
				[string]$FilePath,
			[parameter(Mandatory=$true)]
			[ValidateScript({!(test-path $_)})]
				[string]$OutFile,
			  [parameter(Mandatory=$false)]
			  [ValidateLength(40,40)]
				  [string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateNotNullOrEmpty()]
				[hashtable]$FuncInput,
		[parameter(Mandatory=$false)]
		[ValidateRange(1,10000)]
			[int]$Size
		)
		process {
			$params = @{
				Endpoint = 'discovery/geoloc/asset'
				FilePath = $FilePath
				OutFile  = $OutFile
			}
			if ($APIKey) { $params.APIKey = $APIKey }
			if ($FuncInput) { $params.FuncInput = $FuncInput }
			if ($Size) { $params.Size = $Size }
			Invoke-OnypheBulkFileUpload @params
		}
	}
