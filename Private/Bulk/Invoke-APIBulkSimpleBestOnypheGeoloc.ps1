	Function Invoke-APIBulkSimpleBestOnypheGeoloc {
	<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get Geoloc info for an array of ips based on a file input from Bulk/simple/Geoloc/Best API
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to get Geoloc info for an array of ips based on a file input from Bulk/simple/Geoloc/Best API
		  
		  .PARAMETER FilePath
		  -FilePath string{full path to an existing text file}
		  full path to input file to send to onyphe API

		  .PARAMETER OutFile
		  -OutFile string{full path to a new file for exporting json data}
		  full path to output file used to write json data from Onyphe

		  .PARAMETER APIKEY
		 -APIKey string{APIKEY}
		 Set APIKEY as global variable.

		  .OUTPUTS
		  TypeName: System.Management.Automation.PSCustomObject
		  
		  .EXAMPLE
		  export all Geoloc best info available as JSON for all ips contained in listips.txt
		  C:\PS> Invoke-APIBulkSimpleBestOnypheGeoloc -FilePath .\listips.txt -OutFile .\result.json

		  .EXAMPLE
		  export all Geoloc best info available as JSON for all ips contained in listips.txt and set the API Key
		  C:\PS> Invoke-APIBulkSimpleBestOnypheGeoloc -FilePath .\listips.txt -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -OutFile .\result.json
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
				Endpoint = 'simple/geoloc/best/ip'
				FilePath = $FilePath
				OutFile  = $OutFile
			}
			if ($APIKey) { $params.APIKey = $APIKey }
			if ($FuncInput) { $params.FuncInput = $FuncInput }
			Invoke-OnypheBulkFileUpload @params
		}
	}
