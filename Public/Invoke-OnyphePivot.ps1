	Function Invoke-OnyphePivot {
	<#
	  .SYNOPSIS
	  main function/cmdlet - pivot from a prior Onyphe result set to a follow-up search, per distinct value of a field

	  .DESCRIPTION
	  main function/cmdlet - takes a prior Onyphe result set (e.g. from Search-OnypheInfo/Get-OnypheInfo),
	  extracts every distinct value of -PivotField from it, and fires one follow-up Search-OnypheInfo call
	  per distinct value using -PivotFilter as the target OQL filter name. Captures the "auto-pivot" idea
	  from the official onyphe/cli's opp companion tool (Andlookup/Orlookup/Pivots/Whois processors,
	  which issue new Onyphe API calls off a field pulled from a prior result set) without porting the
	  rest of that tool's 24 purely client-side formatting/filtering processors - those are already
	  covered natively and idiomatically by PowerShell's own object pipeline (Where-Object/Group-Object/
	  Sort-Object -Unique/etc.).

	  One API call is made per distinct pivot value (not a single OR-combined query) - this mirrors the
	  manual multi-step technique this project's own OSINT sessions have already used by hand (e.g.
	  Results/CertAndDNS/sovcloud_domains_analysis.md's organization-to-domain and subnet-to-domain
	  enumeration passes), and keeps clear provenance (which pivot value produced which hits) at the cost
	  of one API call/credit per distinct value. Each returned result object is tagged with two extra
	  NoteProperty fields, 'cli-pivot_source_field' and 'cli-pivot_source_value', recording which
	  -PivotField value produced it.

	  Only the first page of results is retrieved per pivot value (no -Page support) - use -Size to widen
	  that first page if needed.

	  .PARAMETER InputObject
	  -InputObject PSOnyphe object[]
	  a prior Onyphe result set (e.g. piped in from Search-OnypheInfo/Get-OnypheInfo) to pivot from

	  .PARAMETER PivotField
	  -PivotField string
	  dotted property path to read off each -InputObject item (e.g. "subject.organization",
	  "geolocus.organization") - the source of the distinct values to pivot on. If the resolved property
	  value is itself an array (e.g. a SAN list), every element is treated as its own distinct value.

	  .PARAMETER PivotCategory
	  -PivotCategory string {Get-OnypheSearchCategories}
	  Search Type or Category to use for the follow-up query (same meaning as Search-OnypheInfo's
	  -Category)

	  .PARAMETER PivotFilter
	  -PivotFilter string {Get-OnypheSearchFilters}
	  OQL filter name to use in the follow-up query (same meaning as Search-OnypheInfo's -SearchFilter) -
	  deliberately a separate parameter from -PivotField, since the property name on the source object and
	  the OQL filter name on the target category can differ (e.g. reading "organization" off a resolver
	  result but pivoting into ctl using its "subject.organization" filter)

	  .PARAMETER APIKey
	  -APIKey string{APIKEY}
	  set your APIKEY to be able to use Onyphe API.

	  .PARAMETER Size
	  -Size int{1 to 10000}
	  number of results per page (server default is 100 when omitted), applied to every follow-up query

	  .PARAMETER TrackQuery
	  -TrackQuery switch
	  ask Onyphe to return, for each result, which OQL filter matched it (applied to every follow-up query)

	  .PARAMETER Calculated
	  -Calculated switch
	  ask Onyphe to enrich results with computed fields (applied to every follow-up query)

	  .PARAMETER UseBetaFeatures
	  -UseBetaFeatures switch
	  use test.onyphe.io to use new beat features of Onyphe

	  .PARAMETER Post
	  -Post switch
	  send each follow-up query's OQL as a POST request body instead of a GET query-string parameter (see
	  Search-OnypheInfo's -Post)

	  .PARAMETER Wait
	  -Wait int{second}
	  wait for x second before sending each follow-up query, to manage rate limiting across the (potentially
	  many) API calls this cmdlet can fire - one per distinct pivot value

	  .OUTPUTS
	  TypeName: PSOnyphe

	  .EXAMPLE
	  pivot from a ctl result set to every other certificate sharing the same subject.organization value(s), using -PivotField and -PivotFilter as the same field name here (both live on the ctl category)
	  C:\PS> Search-OnypheInfo -AdvancedSearch @("domain:example.com") -Category ctl | Invoke-OnyphePivot -PivotField "subject.organization" -PivotCategory ctl -PivotFilter "subject.organization"

	  .EXAMPLE
	  pivot from a resolver result set to every other hostname hosted on the same organization, waiting 2s between each follow-up call
	  C:\PS> Search-OnypheInfo -AdvancedSearch @("domain:example.com") -Category resolver | Invoke-OnyphePivot -PivotField organization -PivotCategory resolver -PivotFilter organization -Wait 2
	#>
		[cmdletbinding()]
		Param (
			[parameter(ValueFromPipeline=$true,Mandatory=$true,Position=1)]
			[ValidateNotNullOrEmpty()]
				[array]$InputObject,
			[parameter(Mandatory=$true,Position=2)]
			[ValidateNotNullOrEmpty()]
				[string]$PivotField,
			[parameter(Mandatory=$false)]
			[ValidateLength(40,40)]
				[string]$APIKey,
			[parameter(Mandatory=$false)]
			[ValidateRange(1,10000)]
				[int]$Size,
			[parameter(Mandatory=$false)]
				[switch]$TrackQuery,
			[parameter(Mandatory=$false)]
				[switch]$Calculated,
			[parameter(Mandatory=$false)]
				[switch]$UseBetaFeatures,
			[parameter(Mandatory=$false)]
				[switch]$Post,
			[parameter(Mandatory=$false)]
				[int]$Wait
		)
		DynamicParam
		{
			$ParameterNameCategory = 'PivotCategory'
			$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
			$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
			$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
			$ParameterAttribute.ValueFromPipeline = $false
			$ParameterAttribute.ValueFromPipelineByPropertyName = $false
			$ParameterAttribute.Mandatory = $true
			$AttributeCollection.Add($ParameterAttribute)
			$arrSet = Get-OnypheSearchCategories
			if ($arrSet) {
				$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
				$AttributeCollection.Add($ValidateSetAttribute)
			}
			$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameCategory, [string], $AttributeCollection)
			$RuntimeParameterDictionary.Add($ParameterNameCategory, $RuntimeParameter)

			$ParameterNameFilter = 'PivotFilter'
			$AttributeCollection2 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
			$ParameterAttribute2 = New-Object System.Management.Automation.ParameterAttribute
			$ParameterAttribute2.ValueFromPipeline = $false
			$ParameterAttribute2.ValueFromPipelineByPropertyName = $false
			$ParameterAttribute2.Mandatory = $true
			$AttributeCollection2.Add($ParameterAttribute2)
			$arrSet2 = Get-OnypheSearchFilters
			if ($arrSet2) {
				$ValidateSetAttribute2 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet2)
				$AttributeCollection2.Add($ValidateSetAttribute2)
			}
			$RuntimeParameter2 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFilter, [string], $AttributeCollection2)
			$RuntimeParameterDictionary.Add($ParameterNameFilter, $RuntimeParameter2)

			return $RuntimeParameterDictionary
		}
		Begin {
			$Config = Read-OnypheConfigFile
			Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
			$script:PivotCollectedObjects = @()
		}
		Process {
			$script:PivotCollectedObjects += $InputObject
		}
		End {
			$PivotCategory = $PsBoundParameters[$ParameterNameCategory]
			$PivotFilter = $PsBoundParameters[$ParameterNameFilter]
			if ($APIKey) {Set-OnypheAPIKey -APIKey $APIKey | out-null}
			$PathSegments = $PivotField -split '\.'
			$PivotValues = foreach ($obj in $script:PivotCollectedObjects) {
				$current = $obj
				foreach ($segment in $PathSegments) {
					if ($null -eq $current) { break }
					$current = $current.$segment
				}
				if ($null -ne $current) { $current }
			}
			$DistinctValues = $PivotValues | Where-Object { $_ } | Select-Object -Unique
			if (-not $DistinctValues) {
				Write-Warning -Message "No non-empty value found for -PivotField '$($PivotField)' across the supplied -InputObject set - nothing to pivot on"
				return
			}
			foreach ($Value in $DistinctValues) {
				if ($Wait) { Start-Sleep -s $Wait }
				$SearchParams = @{
					SearchValue = $Value
					SearchFilter = $PivotFilter
					Category = $PivotCategory
				}
				if ($Size) { $SearchParams.Size = $Size }
				if ($TrackQuery) { $SearchParams.TrackQuery = $true }
				if ($Calculated) { $SearchParams.Calculated = $true }
				if ($UseBetaFeatures) { $SearchParams.UseBetaFeatures = $true }
				if ($Post) { $SearchParams.Post = $true }
				Write-OnypheLog -Config $Config -Level Information -CmdletName $MyInvocation.MyCommand.Name -Message "Pivoting on $($PivotField)=$($Value)"
				$Results = Search-OnypheInfo @SearchParams
				foreach ($Result in $Results) {
					if ($Result) {
						$Result | Add-Member -MemberType NoteProperty -Name 'cli-pivot_source_field' -Value $PivotField -Force
						$Result | Add-Member -MemberType NoteProperty -Name 'cli-pivot_source_value' -Value $Value -Force
						$Result
					}
				}
			}
		}
	}
