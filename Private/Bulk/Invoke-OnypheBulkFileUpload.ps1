	Function Invoke-OnypheBulkFileUpload {
	<#
		  .SYNOPSIS
		  shared implementation behind every Invoke-APIBulk*Onyphe* wrapper: create the
		  input for Invoke-OnypheAPIV2 and call it to stream a bulk API's JSON response
		  to -OutFile based on a file input

		  .DESCRIPTION
		  shared implementation behind every Invoke-APIBulk*Onyphe* wrapper: create the
		  input for Invoke-OnypheAPIV2 and call it to stream a bulk API's JSON response
		  to -OutFile based on a file input. Every Invoke-APIBulk*Onyphe* function in
		  this module is a thin, endpoint-specific caller of this function that only
		  supplies -Endpoint -- see each wrapper's own comment-based help for
		  endpoint-specific documentation and examples.

		  .PARAMETER Endpoint
		  -Endpoint string
		  the bulk API path segment after "v2/bulk/" and "bulk/", e.g. "simple/ctl/ip",
		  "simple/whois/best/ip", or "summary/ip"

		  .PARAMETER FilePath
		  -FilePath string{full path to an existing text file}
		  full path to input file to send to onyphe API

		  .PARAMETER OutFile
		  -OutFile string{full path to a new file for exporting json data}
		  full path to output file used to write json data from Onyphe

		  .PARAMETER APIKEY
		 -APIKey string{APIKEY}
		 Set APIKEY as global variable.

		  .PARAMETER FuncInput
		  -FuncInput hashtable
		  original bound parameters of the calling wrapper, threaded through to the
		  result object's cli-func_input property

		  .OUTPUTS
		  TypeName: System.Management.Automation.PSCustomObject

		  .EXAMPLE
		  Invoke-OnypheBulkFileUpload -Endpoint 'simple/ctl/ip' -FilePath .\listips.txt -OutFile .\result.json
	#>
		[cmdletbinding()]
		Param (
			[parameter(Mandatory=$true)]
			[ValidateNotNullOrEmpty()]
				[string]$Endpoint,
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
			 if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			 $params = @{
				  request = "v2/bulk/$($Endpoint)"
				  APIInfo = "bulk/$($Endpoint)"
				  APIInput = @("File:$($FilePath)")
				  file = $FilePath
				  APIKeyrequired = $true
				  Stream = $true
				  OutFile = $OutFile
			  }
			  if ($FuncInput) {
				$params.add("FuncInput", $FuncInput)
			  }
			  Write-Verbose -message "URL Info : $($params.request)"
			  write-verbose -message "File uploaded to Onyphe API : $($FilePath)"
			  write-verbose -message "JSON Data exported to : $($OutFile)"
			  Invoke-OnypheAPIV2 @params
		}
	}
