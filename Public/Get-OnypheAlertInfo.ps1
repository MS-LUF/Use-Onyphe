	Function Get-OnypheAlertInfo {
<#
	 .SYNOPSIS 
	 main function/cmdlet - get existing alert on onyphe.io web service using alert APIs
 
	 .DESCRIPTION
	 main function/cmdlet - get all alert on onyphe.io web service using alert APIs and filter alert with query or mail criteria at client side
	 get content through HTTP request to onyphe.io web service and convert back JSON information to a powershell custom object
 	 
	 .PARAMETER APIKey
	 -APIKey string{APIKEY}
	 set your APIKEY to be able to use Onyphe API.
 
	 .PARAMETER UseBetaFeatures
	 -UseBetaFeatures switch
	 use test.onyphe.io to use new beat features of Onyphe
	
	 .PARAMETER SearchFilter
	 -SearchFilter String {"query","name", "email", "id" - default value "name"} 
	 Selected field to be used for searching/filtering process at client side
	 
	 .PARAMETER SearchOperator
	 -SearchOperator String {"eq","ne","like","notlike","match","notmatch" - default value "eq"}
	 Powershell Search operator to be used for filtering

	 .PARAMETER SearchValue
	 -SearchValue String
	 Value to be used as main filter could be a word or expression depending of chosen search operator

	 .OUTPUTS
	 TypeName: System.Management.Automation.PSCustomObject
	 		 
	 .EXAMPLE
	 Get all existing alert using "jeanclaude.dusse@lesbronzesfontdusk.io"
	 C:\PS> Get-OnypheAlert -SearchValue "jeanclaude.dusse@lesbronzesfontdusk.io" -SearchOperator eq -SearchFilter email

	 .EXAMPLE
     Get all existing alert for your onyphe account
	 C:\PS> Get-OnypheAlert
 #>
		[cmdletbinding()]
		Param (
		 [parameter(Mandatory=$false)]
		 [ValidateLength(40,40)]
			 [string]$APIKey,
		 [parameter(Mandatory=$false,Position=10)]
			 [switch]$UseBetaFeatures,
		 [Parameter(Mandatory=$false)]
		 [validateSet("query","name", "email", "id")]
			 [string]$SearchFilter = "name",
		 [Parameter(Mandatory=$false)]
		 [ValidateNotNullOrEmpty()]
			 [string]$SearchValue,
	     [Parameter(Mandatory=$false)]
	     [validateSet("eq","ne","like","notlike","match","notmatch")]
			 [string]$SearchOperator = "eq"
		)
		 process {
			 $Config = Read-OnypheConfigFile
			 Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
			 if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			 if ($UseBetaFeatures) {
				$results = Invoke-APIOnypheListAlert -UseBetaFeatures
			 } else {
				$results = Invoke-APIOnypheListAlert
			 }
			 if (!$SearchValue) {
				$results
			 } else {
				switch ($SearchOperator) {
					eq {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -eq $SearchValue})}
					ne {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -ne $SearchValue})}
					like {$results| add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -like $SearchValue})}
					notlike {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -notlike $SearchValue})}
					match {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -match $SearchValue})}
					notmatch {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -notmatch $SearchValue})}
					Default {$results | add-member -MemberType NoteProperty -Name 'cli-Filtered_Results' -Value ($results.results | Where-Object {$_."$($SearchFilter)" -eq $SearchValue})}
				}
				$results
			 }
		 }
	}
