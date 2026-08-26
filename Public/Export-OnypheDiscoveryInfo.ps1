	Function Export-OnypheDiscoveryInfo {
		<#
		 .SYNOPSIS
		 main function/cmdlet - Export bulk OQL search results from onyphe.io web service using the Discovery API

		 .DESCRIPTION
		 main function/cmdlet - Export bulk OQL search results from onyphe.io web service using the Discovery API
		 the Discovery API runs one OQL query per line of the input file and sends back streamed json as result.
		 requires a Griffin View subscription on Onyphe - without one, -Category has no valid values and every
		 call will fail server-side.

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
		 full path to file to be imported to the Discovery API, one OQL query per line (e.g. "protocol:rdp domain:google.com").

		 .PARAMETER Category
		 -Category string {Get-OnypheDiscoveryCategories}
		 Discovery category to be used : ctiscan,ctiurl,ctl,datascan,datashot,domain,geoloc,hostname,inetnum,ip,onionscan,onionshot,pastries,resolver,riskscan,sniffer,threatlist,topsite,vulnscan,whois

		 .OUTPUTS
		 TypeName: System.Management.Automation.PSCustomObject

		 .EXAMPLE
		 export datascan discovery information into Json file using myqueries.txt as source OQL queries file
		 C:\PS> Export-OnypheDiscoveryInfo -FilePath .\myqueries.txt -SaveInfoAsFile .\results.json -Category datascan

		 .EXAMPLE
		 export resolver discovery information into object using myqueries.txt as source OQL queries file
		 C:\PS> Export-OnypheDiscoveryInfo -FilePath .\myqueries.txt -Category resolver
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
			$ParameterNameType = 'Category'
			$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
			$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
			$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
			$ParameterAttribute.ValueFromPipeline = $false
			$ParameterAttribute.ValueFromPipelineByPropertyName = $false
			$ParameterAttribute.Mandatory = $true
			$ParameterAttribute.Position = 2
			$AttributeCollection.Add($ParameterAttribute)
			$arrSet =  Get-OnypheDiscoveryCategories
			if ($arrSet) {
				$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
				$AttributeCollection.Add($ValidateSetAttribute)
			}
			$ParameterNameAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList @("DiscoveryCategory")
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
			if ((Get-OnypheDiscoveryCategories) -contains $Category) {
				$FunctionName = "Invoke-APIBulkDiscoveryOnyphe$($Category)"
				if (Get-Command -Name $FunctionName -CommandType Function -ErrorAction SilentlyContinue) {
					& $FunctionName @params | out-null
				} else {
					throw "Discovery API $($Category) not implemented yet in this version of Use-Onyphe pwsh module"
				}
			} else {
				throw "Discovery API $($Category) not available on Onyphe"
			}
			if ($outputAsObject -and (test-path $SaveInfoAsFile)) {
				get-content $SaveInfoAsFile | convertfrom-json
			}
		}
	}
