	Function Invoke-APIBulkSummaryOnypheDomain {
		<#
		  .SYNOPSIS 
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an array of domains based on a file input from Bulk/domain API
		  .DESCRIPTION
		  create several input for Invoke-OnypheAPIV2 function and then call it to get the all available info for an array of domains based on a file input from Bulk/domain API
		  
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
		  export all info available as JSON for all domains contained in listdom.txt
		  C:\PS> Invoke-APIBulkSummaryOnypheDomain -FilePath .\listdom.txt -OutFile .\results.json

		  .EXAMPLE
		  export all info available as JSON for all domains contained in listdom.txt and set the API Key
		  C:\PS> Invoke-APIBulkSummaryOnypheDomain -FilePath .\listdom.txt -APIKey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -OutFile .\results.json
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
				Endpoint = 'summary/domain'
				FilePath = $FilePath
				OutFile  = $OutFile
			}
			if ($APIKey) { $params.APIKey = $APIKey }
			if ($FuncInput) { $params.FuncInput = $FuncInput }
			Invoke-OnypheBulkFileUpload @params
		}
	}
