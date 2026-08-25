	Function Invoke-APIBulkDiscoveryOnypheResolver {
	<#
		  .SYNOPSIS
		  create several input for Invoke-OnypheAPIV2 function and then call it to run bulk OQL queries against the resolver category based on a file input from Bulk/discovery/resolver API
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to run bulk OQL queries against the resolver category based on a file input from Bulk/discovery/resolver API
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

		  .OUTPUTS
		  TypeName: System.Management.Automation.PSCustomObject

		  .EXAMPLE
		  export resolver discovery results as JSON for all OQL queries contained in queries.txt
		  C:\PS> Invoke-APIBulkDiscoveryOnypheResolver -FilePath .\queries.txt -OutFile .\result.json

		  .EXAMPLE
		  export resolver discovery results as JSON for all OQL queries contained in queries.txt and set the API Key
		  C:\PS> Invoke-APIBulkDiscoveryOnypheResolver -FilePath .\queries.txt -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -OutFile .\result.json
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
				[hashtable]$FuncInput
		)
		process {
			$params = @{
				Endpoint = 'discovery/resolver/asset'
				FilePath = $FilePath
				OutFile  = $OutFile
			}
			if ($APIKey) { $params.APIKey = $APIKey }
			if ($FuncInput) { $params.FuncInput = $FuncInput }
			Invoke-OnypheBulkFileUpload @params
		}
	}
