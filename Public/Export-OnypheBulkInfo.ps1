	Function Export-OnypheBulkInfo {
		<#
		 .SYNOPSIS 
		 main function/cmdlet - Export Search information on onyphe.io web service using bulk simple APIs
	 
		 .DESCRIPTION
		 main function/cmdlet - Export Search information on onyphe.io web service using bulk simple APIs
		 bulk APIs use input file containing ip sends back streamed json as result.
		 NOTE: the Simple API this cmdlet wraps does not paginate - each entry in -FilePath is
		 capped at 100 results with no error or warning, and no parameter here can raise that.
		 Use Export-OnypheInfo instead if a category needs more than 100 results per entry - it
		 uses the Search/Export API, which supports real pagination and -Size up to 10000.

		 .PARAMETER APIKey
		 -APIKey string{APIKEY}
		 set your APIKEY to be able to use Onyphe API.
	 	 
		 .PARAMETER Wait
		 -Wait int{second}
		 wait for x second before sending the request to manage rate limiting restriction
	
		 .PARAMETER SaveInfoAsFile
		 -SaveInfoAsFile string
		 full path to file where json data will be exported.

		 .PARAMETER FilePath
		 -FilePath string
		 full path to file to be imported to the bulk simple APIs.

		 .PARAMETER Category
		 -Category string {Get-OnypheBulkCategories}
		 Bulk Simple Category to be used : ctl,datascan,datashot,geoloc,inetnum,pastries,resolver,sniffer,synscan,threatlist,topsite,vulnscan,whois

		 .PARAMETER Best
		 -Best switch
		 Enable Best mode for Simple API

		 .OUTPUTS
		 TypeName: System.Management.Automation.PSCustomObject
		 	 
		 .EXAMPLE
		 export ctl information into Json file using myfile.txt as source IPs file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -Category ctl
	 
		 .EXAMPLE
		 export datascan information into Json file using myfile.txt as source IPs file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -Category datascan
	 
		 .EXAMPLE
		 export threatlist information into Json file using myfileip.txt as source IPs file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -Category threatlist

		 .EXAMPLE
		 export threatlist information into object file using myfileip.txt as source IPs file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -Category threatlist
	 #>
		[cmdletbinding()]
		param(
			[parameter(Mandatory=$true)]
			[ValidateScript({test-path "$($_)"})]
				[string]$FilePath,
			[parameter(Mandatory=$false)]
				[string]$SaveInfoAsFile,
			[parameter(Mandatory=$false)]
				[switch]$Best,
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
				[int]$wait
		)
		DynamicParam
		{
			$ParameterNameType = 'Category'
			$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
			$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
			$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
			$ParameterAttribute.ValueFromPipeline = $false
			$ParameterAttribute.ValueFromPipelineByPropertyName = $false
			$ParameterAttribute.Mandatory = $true
			$ParameterAttribute.Position = 2
			$AttributeCollection.Add($ParameterAttribute)
			$arrSet =  Get-OnypheBulkCategories
			if ($arrSet) {
				$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
				$AttributeCollection.Add($ValidateSetAttribute)
			}
			$ParameterNameAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList @("BulkCategory")
			$AttributeCollection.Add($ParameterNameAlias)
			$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
			$RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
			return $RuntimeParameterDictionary
	 	}
		Process {
			$Config = Read-OnypheConfigFile
			Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
			$Category = $PsBoundParameters[$ParameterNameType]
			if ($wait) {start-sleep -s $wait}
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			if (!($SaveInfoAsFile)) {
				$outputAsObject = $true
				$SaveInfoAsFile = [System.IO.Path]::GetTempFileName()
				remove-item -path $SaveInfoAsFile -force
			}
			$params = @{
				OutFile = $SaveInfoAsFile
				FilePath = $FilePath
			}
			if ($Best.IsPresent) {
				if ((Get-OnypheSimpleBestAPIName) -contains $Category) {
					$FunctionName = "Invoke-APIBulkSimpleBestOnyphe$($Category)"
					if (Get-Command -Name $FunctionName -CommandType Function -ErrorAction SilentlyContinue) {
						$responsestream = & $FunctionName @params
					} else {
						throw "Simple Best API $($Category) not implemented yet in this version of Use-Onyphe pwsh module"
					}
				} else {
					throw "Simple Best API $($Category) not available on Onyphe"
				}
			} else {
				if ((get-OnypheSimpleAPIName) -contains $Category) {
					$FunctionName = "Invoke-APIBulkSimpleOnyphe$($Category)"
					if (Get-Command -Name $FunctionName -CommandType Function -ErrorAction SilentlyContinue) {
						$responsestream = & $FunctionName @params
					} else {
						throw "Simple API $($Category) not implemented yet in this version of Use-Onyphe pwsh module"
					}
				} else {
					throw "Simple API $($Category) not available on Onyphe"
				}
			}
			if ($outputAsObject -and (test-path $SaveInfoAsFile)) {
				get-content $SaveInfoAsFile | convertfrom-json
			}
		}
	}
