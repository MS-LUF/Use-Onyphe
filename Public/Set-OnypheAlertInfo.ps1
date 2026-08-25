	Function Set-OnypheAlertInfo {
<#
	 .SYNOPSIS 
	 main function/cmdlet - create, modify, delete an alert on onyphe.io web service using alert APIs
 
	 .DESCRIPTION
	 main function/cmdlet - create, modify, delete an alert on onyphe.io web service using alert APIs
	 post JSON content through HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
 
	 .PARAMETER AdvancedSearch
	 -AdvancedSearch ARRAY{filter:value,filter:value}
	 Search with multiple criterias

	 .PARAMETER AdvancedFilter
	 -AdvancedFilter ARRAY{filter:value,filter:value}
	 Filter with multiple criterias
 
	 .PARAMETER SearchValue
	 -SearchValue STRING{value}
	 string to be searched with -SearchFilter parameter
 
	 .PARAMETER SearchFilter
	 -SearchFilter STRING{Get-OnypheSearchFilters}
	 Filter to be used with string set with SearchValue parameter
 
	 .PARAMETER SearchType
	 -SearchType STRING{Get-OnypheSearchCategories}
	 Search Type or Category

	 .PARAMETER FilterFunction
	 -FilterFunction String{Get-OnypheSearchFunctions}
	 Filter search function

	 .PARAMETER FilterValue
	 -FilterValue String
	 value to use as input for FilterFunction
	 
	 .PARAMETER APIKey
	 -APIKey string{APIKEY}
	 set your APIKEY to be able to use Onyphe API.
 
	 .PARAMETER UseBetaFeatures
	 -UseBetaFeatures switch
	 use test.onyphe.io to use new beat features of Onyphe
	
	 .PARAMETER AlertAction
	 -AlertAction String {"new","delete","modify" - default value "new"} 
	 Mandatory parameter used to select what kind of action is requested : creation, deletion, modification of an alert
	 
	 .PARAMETER AlertName
	 -AlertName String
	 Name of the alert. Only alphanumeric and space characters allowed.

	 .PARAMETER AlertMail
	 -AlertMail String
	 Mail address used to send you back the alert when a new event is matching your query

	 .OUTPUTS
	 TypeName: System.Management.Automation.PSCustomObject
	 		 
	 .EXAMPLE
	 New alert for AdvancedSearch with multiple criteria/filters
	 Set a new alert named "windows apache" matching datascan for all IP matching the criteria : Apache web server listening on 443 tcp port hosted on Windows, and sent back the alert on "jeanclaude.dusse@lesbronzesfontdusk.io"
	 C:\PS> Set-OnypheAlert -AdvancedSearch @("product:Apache","port:443","os:Windows") -SearchType datascan -AlertAction new -AlertName "windows apache" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"
 
	 .EXAMPLE
	 New alert for simple search with one filter/criteria
	 Set a new alert named "from russia with lv" matching threatlist for all IP matching the criteria : all IP from russia tagged by threat lists, and sent back the alert on "jeanclaude.dusse@lesbronzesfontdusk.io"
	 C:\PS> Set-OnypheAlert -SearchValue RU -SearchType threatlist -SearchFilter country -AlertAction new -AlertName "from russia with lv" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"
 	 
	 .EXAMPLE
	 New alert for simple search with one filter/criteria and use a server filter to retrieve only objects indexed since 2 month, 
	 Set an new alert named "from russia with lv 2 m" matching threatlist for all IP matching the criteria : all IP from russia tagged by threat lists
	 C:\PS> Set-OnypheAlert -SearchValue RU -SearchType threatlist -SearchFilter country -FilterFunction monthago -FilterValue "2" -AlertAction new -AlertName "from russia with lv 2 m" -AlertMail "jeanclaude.dusse@lesbronzesfontdusk.io"

	 .EXAMPLE
	 Modify an existing alert named "from paris with lv" and update mail and query
	 Modify an existing alert named "from paris with lv" an update it to match threatlist for all IP matching the criteria : all IP from russia tagged by threat lists and filter the result and show me only the answer with os property not null, finally sent back the alert to new mail "robert.lespinasse@lesbronzesfontdusk.io"
	 C:\PS> Set-OnypheAlert -SearchValue FR -SearchType threatlist -SearchFilter country -FilterFunction exist -FilterValue os -AlertAction modify -AlertName "from paris with lv" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"

	 .EXAMPLE
	 New alert for advanced search and filter
	 Set a new alert named "RandR" matching datascan for all IP matching the criteria : all ip from RU with TCP 3389 port opened, filter the results using multiple filters (only os property known and from all organization like *company*), and finally sent back the alert to "robert.lespinasse@lesbronzesfontdusk.io"
	 C:\PS> Set-OnypheAlert -AdvancedFilter @("wildcard:organization,*company*","exists:os") -AdvancedSearch @("country:RU","port:3389") -SearchType datascan -AlertAction new -AlertName "RandR" -AlertMail "robert.lespinasse@lesbronzesfontdusk.io"

	 .EXAMPLE
     Delete an existing alert named "windows apache"
	 C:\PS> Set-OnypheAlert -AlertAction delete -AlertName "windows apache"
 #>
		[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='Medium')]
		param(
			[parameter(Mandatory=$false,Position=5)]
			[ValidateNotNullOrEmpty()]  
				[string]$SearchValue,
			[parameter(Mandatory=$false,Position=8)] 
			[ValidateNotNullOrEmpty()]
				[string[]]$FilterValue,
			[parameter(Mandatory=$false,Position=9)] 
			[ValidateNotNullOrEmpty()]
				[Array]$AdvancedSearch,
			[Parameter(Mandatory=$true,Position=1)]
			[validateSet("new","delete","modify")]
				[string]$AlertAction = "new",
			[Parameter(Mandatory=$false,Position=2)]
			[ValidateScript({$_ -match "^[a-zA-Z0-9.!£#$%&'^_`{}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$"})]
				[string]$AlertMail,
			[Parameter(Mandatory=$true, Position=3)]
			[ValidateScript({$_ -match "^[a-zA-Z0-9 ]*$"})]
				[string]$AlertName,
			[parameter(Mandatory=$false,Position=11)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false,Position=12)]
				[switch]$UseBetaFeatures,
			[parameter(Mandatory=$false,Position=10)] 
			[ValidateNotNullOrEmpty()]
				[Array]$AdvancedFilter,
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false)]
			[ValidateScript({($_ -is [System.Management.Automation.PSCustomObject]) -or ($_ -is [Deserialized.System.Management.Automation.PSCustomObject])})]
				[array]$InputOnypheObject
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
			$ParameterAttribute.Position = 4
			$AttributeCollection.Add($ParameterAttribute)
			$arrSet = Get-OnypheSearchCategories
			if ($arrSet) {
				$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
				$AttributeCollection.Add($ValidateSetAttribute)
			}
			$ParameterNameAlias = New-Object System.Management.Automation.AliasAttribute -ArgumentList @("Category")
			$AttributeCollection.Add($ParameterNameAlias)
			$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameType, [string], $AttributeCollection)
			$RuntimeParameterDictionary.Add($ParameterNameType, $RuntimeParameter)
			
			$ParameterNameFilter = 'SearchFilter'
			$AttributeCollection2 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
			$ParameterAttribute2 = New-Object System.Management.Automation.ParameterAttribute
			$ParameterAttribute2.ValueFromPipeline = $false
			$ParameterAttribute2.ValueFromPipelineByPropertyName = $false
			$ParameterAttribute2.Mandatory = $false
			$ParameterAttribute2.Position = 6
			$AttributeCollection2.Add($ParameterAttribute2)
			$arrSet =  Get-OnypheSearchFilters
			if ($arrSet) {
				$ValidateSetAttribute2 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
				$AttributeCollection2.Add($ValidateSetAttribute2)
			}
			$RuntimeParameter2 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFilter, [string], $AttributeCollection2)
			$RuntimeParameterDictionary.Add($ParameterNameFilter, $RuntimeParameter2)
   
			$ParameterNameFunction = 'FilterFunction'
			$AttributeCollection3 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
			$ParameterAttribute3 = New-Object System.Management.Automation.ParameterAttribute
			$ParameterAttribute3.ValueFromPipeline = $false
			$ParameterAttribute3.ValueFromPipelineByPropertyName = $false
			$ParameterAttribute3.Mandatory = $false
			$ParameterAttribute3.Position = 7
			$AttributeCollection3.Add($ParameterAttribute3)
			$arrSet =  Get-OnypheSearchFunctions
			if ($arrSet) {
				$ValidateSetAttribute3 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
				$AttributeCollection3.Add($ValidateSetAttribute3)
			}
			$RuntimeParameter3 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFunction, [string], $AttributeCollection3)
			$RuntimeParameterDictionary.Add($ParameterNameFunction, $RuntimeParameter3)
			
			return $RuntimeParameterDictionary
	   }
		 process {
			$Config = Read-OnypheConfigFile
			Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
			$SearchType = $PsBoundParameters[$ParameterNameType]
			$SearchFilter = $PsBoundParameters[$ParameterNameFilter]
			$SearchFunction = $PsBoundParameters[$ParameterNameFunction]
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$params = @{}
			if ($SearchValue -or $AdvancedSearch) {
				$params = @{
					SearchType = $SearchType
					AlertName = $AlertName
					AlertEmail = $AlertMail
					FuncInput = $PsBoundParameters
				}
			} elseif ($InputOnypheObject) {
				if (!$AlertName -and !$AlertMail) {
					throw "please use AlertName, AlertMail and AlertAction parameters when using InputOnypheObject parameter"
				} else {
					if ($InputOnypheObject.'cli-func_input') {
						$params = $InputOnypheObject.'cli-func_input'.clone()
						$params.add('FuncInput', $InputOnypheObject.'cli-func_input'.clone())
						$params.add('AlertName',$AlertName)
						$params.add('AlertEmail',$Alertmail)
						if ($params.Page) {
							$params.remove('Page')
						}
					} else {
						throw "invalid input object, missing property cli-func_input"
					}
				}
			}
			if ($SearchFilter -and !($SearchValue)) {
				throw "please use the SearchValue parameter when using SearchFilter parameter or used AdvancedSearch instead"
			}
			if ($SearchFunction -and !($FilterValue)) {
				throw "please use the FilterValue parameter when using FilterFunction parameter"
			}
			if ($AdvancedSearch) {
				 $params.add('AdvancedSearch',$AdvancedSearch)
			} elseif ($SearchValue) {
				$params.add('SearchValue',$SearchValue)
				$params.add('SearchFilter',$SearchFilter)
			}
			if ($AdvancedFilter) {
				$params.add('AdvancedFilter',$AdvancedFilter)
			} elseif ($SearchFunction) {
				$params.add('FilterFunction', $SearchFunction)
				$params.add('FilterValue',$FilterValue)
			}
			if ($UseBetaFeatures) {
				$params.add('UseBetaFeatures', $true)
			}
			if ($UseBetaFeatures) {
				$AlertCheck = Get-OnypheAlertInfo -SearchValue $AlertName -UseBetaFeatures
			} else {
				$AlertCheck = Get-OnypheAlertInfo -SearchValue $AlertName
			}
			switch ($AlertAction) {
				new {
					if (!$AlertMail) {
						throw "please provide a mail address using AlertMail parameter"
					}
					if (!$AdvancedSearch -and !$SearchValue -and !$InputOnypheObject) {
						throw "please provide valid search request for the alert query system using AdvancedSearch or SearchValue parameters. Or Please provide a valid input object using InputOnypheObject parameter."
					}
					if ($AlertCheck.'cli-Filtered_Results') {
						throw "$($Alertname) is already used as an existing alert"
					} elseif ($PSCmdlet.ShouldProcess($AlertName, 'Create Onyphe alert')) {
						Invoke-APIOnypheAddAlert @params
					}
				}
				delete {
					if ($AlertCheck.'cli-Filtered_Results') {
						if ($PSCmdlet.ShouldProcess($AlertName, 'Delete Onyphe alert')) {
							if ($UseBetaFeatures) {
								Invoke-APIOnypheDelAlert -AlertID $AlertCheck.'cli-Filtered_Results'.ID -UseBetaFeatures
							} else {
								Invoke-APIOnypheDelAlert -AlertID $AlertCheck.'cli-Filtered_Results'.ID
							}
						}
					} else {
						throw "$($Alertname) not existing"
					}
				}
				modify {
					if (!$AlertMail) {
						throw "please provide a mail address using AlertMail parameter"
					}
					if (!$AdvancedSearch -and !$SearchValue -and !$InputOnypheObject) {
						throw "please provide valid search request for the alert query system using AdvancedSearch or SearchValue parameters. Or Please provide a valid input object using InputOnypheObject parameter."
					}
					if ($AlertCheck.'cli-Filtered_Results') {
						if ($PSCmdlet.ShouldProcess($AlertName, 'Delete and re-create Onyphe alert')) {
							if ($UseBetaFeatures) {
								Invoke-APIOnypheDelAlert -AlertID $AlertCheck.'cli-Filtered_Results'.ID -UseBetaFeatures
							} else {
								Invoke-APIOnypheDelAlert -AlertID $AlertCheck.'cli-Filtered_Results'.ID
							}
							Invoke-APIOnypheAddAlert @params
						}
					} else {
						throw "$($Alertname) not existing"
					}
				}
			}
		 }
	}
