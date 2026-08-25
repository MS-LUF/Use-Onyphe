	Function Get-OnypheInfo {
  <#
	.SYNOPSIS 
	main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Simple API available

	.DESCRIPTION
	main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Simple API available
	send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
	
	.PARAMETER Category
	-Category string (ctl,datascan,geoloc,inetnum,pastries,resolver,sniffer,synscan,threatlist,datashot,onionscan,onionshot,topsite,vulnscan,resolverreverse,resolverforward,datascandatamd5,whois)
	
	.PARAMETER SearchValue
	-SearchValue string -Category Inetnum -APIKey string{APIKEY}
	look for an ip address in onyphe database
	-SearchValue string -Category Threatlist -APIKey string{APIKEY}
	look for threat info about a specific IP in onyphe database.
	-SearchValue string -Category Pastries -APIKey string{APIKEY}
	look for an pastbin data about a specific IP in onyphe database.
	-SearchValue string -Category Synscan -APIKey string{APIKEY}
	
	.PARAMETER APIKey
	-APIKey string{APIKEY}
	set your APIKEY to be able to use Onyphe API.

    .PARAMETER Page
	-page string{page number}
	go directly to a specific result page (1 to 1000)
	you can set a list of page using x-y like 1-100 to read the first 100 pages

    .PARAMETER Wait
	-Wait int{second}
	wait for x second before sending the request to manage rate limiting restriction

	.PARAMETER Best
	-best
	enable best mode when supported by simple API
	
	.OUTPUTS
	TypeName: System.Management.Automation.PSCustomObject
		
	.EXAMPLE
	Request geoloc information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -Category Geoloc
	
	.EXAMPLE
	Request dns reverse information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -Category ResolverReverse -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	request IIS keyword datascan information
	C:\PS> Get-OnypheInfo -Category DataScan -SearchValue "IIS" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	request datascan information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -Category DataScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request pastebin content information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -Category Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	.EXAMPLE
	Request pastebin content information for ip 8.8.8.8 and see page 2 of results
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -Category Pastries -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -page "2"
	
	.EXAMPLE
	Request dns forward information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -Category ResolverForward -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request threatlist information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -Category Threatlist -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request inetnum information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -Category Inetnum -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	
	.EXAMPLE
	Request synscan information for ip 8.8.8.8 
	C:\PS> Get-OnypheInfo -SearchValue "8.8.8.8" -Category SynScan -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"	
#>
  [cmdletbinding()]
  Param (
	[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false)]
		[ValidateNotNullOrEmpty()]
		[string]$SearchValue,
	[parameter(Mandatory=$false)]
		[switch]$Best,
	[parameter(Mandatory=$false)]
		[ValidateLength(40,40)]
		[string]$APIKey,
	[parameter(Mandatory=$false)]
	[ValidateScript({($_ -match "^((?!0)\d+)$") -or ($_ -match "^((?!0)\d+)(-)((?!0)\d+)$")})]
		[string[]]$Page,
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
		$ParameterAttribute.Mandatory = $false
		$ParameterAttribute.Position = 2
		$AttributeCollection.Add($ParameterAttribute)
		$arrSet =  Get-OnypheSimpleAPIName
		if ($arrSet) {
			$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
			$AttributeCollection.Add($ValidateSetAttribute)
		}
		$ParameterNameAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList @("SimpleAPIType","Category")
		$AttributeCollection.Add($ParameterNameAlias)
		$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
		$RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
		return $RuntimeParameterDictionary
 }
	process {
		$Config = Read-OnypheConfigFile
		Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		$SearchType = $PsBoundParameters[$ParameterNameType]
		if (!($SearchType -and $SearchValue)) {
			throw "Please provide a valid searchvalue and simple API type parameters"
		}
		if ($wait) {start-sleep -s $wait}
		if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
		if ($best.IsPresent) {
			$APIfunctionprefix = "Invoke-APIBestOnyphe"
		} else {
			$APIfunctionprefix = "Invoke-APIOnyphe"
		}
		If ($searchtype) {
			if ($SearchValue) {
				$params = @{
					input = $SearchValue
				}
				$FunctionName = "$($APIfunctionprefix)$($Searchtype)"
				if (Get-Command -Name $FunctionName -CommandType Function -ErrorAction SilentlyContinue) {
					Write-OnypheLog -Config $Config -Level Information -CmdletName $MyInvocation.MyCommand.Name -Message "Dispatching to $($FunctionName)"
					if ($Page) {
						switch -regex ($page) {
							"^((?!0)\d+)(-)((?!0)\d+)$" {
								$page = $page -split "-"
								for ($i=[int]$page[0];$i -le [int]$page[1];$i++) {
									if ($params.page) {
										$params.Page = $i.tostring()
									} else {
										$params.add('Page', $i.tostring())
									}
									& $FunctionName @params
								}
							}
							"^((?!0)\d+)$" {
								$params.add('Page', $page[0])
								& $FunctionName @params
							}
						}
					} else {
						& $FunctionName @params
					}
				} else {
					if ($best.IsPresent) {
						throw "Simple Best API $($Searchtype) not implemented yet in this version of Use-Onyphe pwsh module or missing in Category / Simple API"
					} else {
						throw "Simple API $($Searchtype) not implemented yet in this version of Use-Onyphe pwsh module"
					}
				}
			} else {
				throw "-SearchValue parameter must be used with -Category"
			}
		} 
	}
	}
