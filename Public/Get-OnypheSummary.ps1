	Function Get-OnypheSummary {
		<#
		  .SYNOPSIS 
		  main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Summary API available
	  
		  .DESCRIPTION
		  main function/cmdlet - Get information from onyphe.io web service using dedicated subfunctions by Summary API available
		  send HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
		  
		  .PARAMETER SummaryAPIType
		  -SummaryAPIType string (ip,domain,hostname)
		  -SearchValue string -SummaryAPIType ip -APIKey string{APIKEY}
		  look for an all info available regarding an ip address in onyphe database
		  -SearchValue string -SummaryAPIType domain -APIKey string{APIKEY}
		  look for an all info available regarding a domain in onyphe database
		  -SearchValue string -SummaryAPIType hostname -APIKey string{APIKEY}
		  look for an all info available regarding an hostname in onyphe database
		  
		  .PARAMETER APIKey
		  -APIKey string{APIKEY}
		  set your APIKEY to be able to use Onyphe API.
	  
		  .PARAMETER Page
		  -page string{page number}
		  go directly to a specific result page (1 to 1000)
		  you can set a list of page using x-y like 1-100 to read the first 100 pages
		  NOTE: this API does not actually paginate - live-confirmed (2026-08-28) that any
		  -page value returns the same first page of results, with no error or warning
		  (the server always reports page:1 back, regardless of what page was requested).
		  Use Search-OnypheInfo/Export-OnypheInfo instead if you need more results than a
		  single page returns for this category.

		  .PARAMETER Wait
		  -Wait int{second}
		  wait for x second before sending the request to manage rate limiting restriction
		  
		  .OUTPUTS
		  TypeName: System.Management.Automation.PSCustomObject
		  
		  .EXAMPLE
		  Request all information for ip 8.8.8.8 
		  C:\PS> Get-OnypheSummary -SearchValue "8.8.8.8" -SummaryAPIType ip
		  
		  .EXAMPLE
		  Request all information for perdu.com domain and set the API key
		  C:\PS> Get-OnypheSummary -SearchValue "perdu.com" -SummaryAPIType domain -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
		  
		  .EXAMPLE
		  Request all information for www.perdu.com hostname  and see page 2 of results
		  C:\PS> Get-OnypheSummary -SearchValue "www.perdu.com" -SummaryAPIType hostname -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -page "2"
		  
	  #>
		[cmdletbinding()]
		Param (
		  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false)]
			  [ValidateNotNullOrEmpty()]
			  [string]$SearchValue,
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
			  $ParameterAttribute.Mandatory = $true
			  $ParameterAttribute.Position = 2
			  $AttributeCollection.Add($ParameterAttribute)
			  $arrSet =  Get-OnypheSummaryAPIName
			  if ($arrSet) {
				  $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
				  $AttributeCollection.Add($ValidateSetAttribute)
			  }
			  $ParameterNameAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList @("SummaryAPIType")
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
				  throw "Please provide a valid searchvalue and summary API type parameters"
			  }
			  if ($wait) {start-sleep -s $wait}
			  if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			  If ($searchtype) {
				  if ($SearchValue) {
					  $params = @{
						  input = $SearchValue
					  }
					  $FunctionName = "Invoke-APISummaryOnyphe$($Searchtype)"
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
						  throw "API $($Searchtype) not implemented yet in this version of Use-Onyphe pwsh module"
					  }
				  } else {
					  throw "-SearchValue parameter must be used with -SummaryAPIType"
				  }
			  } 
		  }
	}
