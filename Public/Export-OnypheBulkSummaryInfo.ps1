	Function Export-OnypheBulkSummaryInfo {
		<#
		 .SYNOPSIS 
		 main function/cmdlet - Export Search information on onyphe.io web service using bulk APIs
	 
		 .DESCRIPTION
		 main function/cmdlet - Export Search information on onyphe.io web service using bulk APIs
		 bulk APIs use input file containing ip, domain or hostname and sends back streamed json as result.
	 	 
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
		 full path to file to be imported to the bulk API.

		 .PARAMETER BulkAPISummary
		 -BulkAPISummary string {Get-OnypheSummaryAPIName}
		 Bulk API to be used : ip, domain, hostname
		 
		 .OUTPUTS
		 TypeName: System.Management.Automation.PSCustomObject
		 	 
		 .EXAMPLE
		 export summary IP information into Json file using myfile.txt as source IPs file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType ip
	 
		 .EXAMPLE
		 export summary domain information into Json file using myfile.txt as source domains file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType domain
	 
		 .EXAMPLE
		 export summary hostname information into Json file using myfileip.txt as source hostnames file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType hostname

		 .EXAMPLE
		 export summary hostname information into object using myfileip.txt as source hostnames file
		 C:\PS> Export-OnypheBulkInfo -FilePath .\myfile.txt -SaveInfoAsFile .\results.json -SearchType hostname
	 #>
		[cmdletbinding()]
		param(
			[parameter(Mandatory=$true)]
			[ValidateScript({test-path "$($_)"})]
				[string]$FilePath,
			[parameter(Mandatory=$false)]
				[string]$SaveInfoAsFile,
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
				[int]$wait
		)
		DynamicParam
		{
			$ParameterNameType = 'SearchType'
			$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
			$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
			$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
			$ParameterAttribute.ValueFromPipeline = $false
			$ParameterAttribute.ValueFromPipelineByPropertyName = $false
			$ParameterAttribute.Mandatory = $true
			$ParameterAttribute.Position = 2
			$AttributeCollection.Add($ParameterAttribute)
			$arrSet =  Get-OnypheSummaryAPIName
			if ($arrSet) {
				$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
				$AttributeCollection.Add($ValidateSetAttribute)
			}
			$ParameterNameAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList @("BulkAPISummary")
			$AttributeCollection.Add($ParameterNameAlias)
			$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
			$RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
			return $RuntimeParameterDictionary
	 	}
		Process {
			$Config = Read-OnypheConfigFile
			Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
			$SearchType = $PsBoundParameters[$ParameterNameType]
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
			$FunctionName = "Invoke-APIBulkSummaryOnyphe$($Searchtype)"
			if (Get-Command -Name $FunctionName -CommandType Function -ErrorAction SilentlyContinue) {
				$responsestream = & $FunctionName @params
			} else {
				throw "Bulk Summary API $($Searchtype) not implemented yet in this version of Use-Onyphe pwsh module"
			}
			if ($outputAsObject -and (test-path $SaveInfoAsFile)) {
				get-content $SaveInfoAsFile | convertfrom-json
			}
		}
	}
