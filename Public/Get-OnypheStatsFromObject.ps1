	Function Get-OnypheStatsFromObject {
 <#
	.SYNOPSIS 
	Get Some stats (count, total, min, max, average) for one or multiple properties of a onyphe result powershell object

	.DESCRIPTION
	Get Some stats (count, total, min, max, average) for one or multiple properties of a onyphe result powershell object
	
	.PARAMETER InputOnypheObject
	-InputOnypheObject PSCustomObject{Onyphe result PSCustomObject}
	Onyphe object used for the stat
	
	.PARAMETER AdvancedFacets
	-AdvancedFacets ARRAY{list of onyphe objects' properties}
	Onyphe result object's property requested for the stat (results = on object per property requested)

	.PARAMETER Facets
	-Facets string{onyphe objects' property}
	Onyphe result object's property requested for the stat
	
	.OUTPUTS
   	TypeName: PSOnyphe
		
	.EXAMPLE
	Search SynScan info and request stats for 'ip','port','tag' and 'organization' properties
	C:\PS> Search-OnypheInfo -AdvancedSearch @('country:FR','port:23','os:Linux') -SearchType synscan | Get-OnypheStatsFromObject -AdvancedFacets @('ip','port','tag','organization')

	.EXAMPLE
	Search SynScan info and request stats for 'ip' property
	C:\PS> $onypheobj = Search-OnypheInfo -AdvancedSearch @('country:FR','port:23','os:Linux') -SearchType synscan
	C:\PS> Get-OnypheStatsFromObject -Facets 'ip' -InputOnypheObject $onypheobj
#>
	[cmdletbinding()]
	Param (
		[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
		[ValidateScript({$_ -is [System.Management.Automation.PSCustomObject]})]
			[array]$InputOnypheObject,
		[parameter(Mandatory=$false)] 
		[ValidateNotNullOrEmpty()]
			[Array]$AdvancedFacets
	)
	DynamicParam
	{		
		$ParameterNameFilter = 'Facets'
		$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		$AttributeCollection2 = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		$ParameterAttribute2 = New-Object System.Management.Automation.ParameterAttribute
		$ParameterAttribute2.ValueFromPipeline = $false
		$ParameterAttribute2.ValueFromPipelineByPropertyName = $false
		$ParameterAttribute2.Mandatory = $false
		$AttributeCollection2.Add($ParameterAttribute2)
		$arrSet =  Get-OnypheCliFacets
		if ($arrSet) {
			$ValidateSetAttribute2 = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)
			$AttributeCollection2.Add($ValidateSetAttribute2)
		}
		$RuntimeParameter2 = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterNameFilter, [string], $AttributeCollection2)
		$RuntimeParameterDictionary.Add($ParameterNameFilter, $RuntimeParameter2)
		return $RuntimeParameterDictionary
	}
	Process {
		$Config = Read-OnypheConfigFile
		Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		$Facets = $PsBoundParameters[$ParameterNameFilter]
		if (!$Facets -and !$AdvancedFacets) {
			Write-Verbose -Message "both AdvancedFacets and Facets options are empty, please use at least one of this parameter to set the facets to be used for the stats"
			throw "Please provide a valid facets option"
		}
		$script:results = @()
		$script:TemplateFacetObject = new-object psobject -Property @{
			'Onyphe-Facet' = $null
			'Onyphe-Property-value' = $null
			'Onyphe-Property-Count' = $null
		}
		If ($AdvancedFacets) {
			foreach ($facet in $AdvancedFacets) {
				$tmp = $InputOnypheObject.results."$($Facet)" | sort-object | get-unique
				$script:AllFacetObjects = @()
				foreach ($object in $tmp) {
					$tmpobj = $script:TemplateFacetObject | Select-Object *
					$tmpobj.'Onyphe-Property-value' = $object
					if (($InputOnypheObject.results | Where-Object {$_."$($Facet)" -eq "$($object)"}).count) {
						$tmpobj.'Onyphe-Property-Count' = ($InputOnypheObject.results | Where-Object {$_."$($Facet)" -eq "$($object)"}).count
					} Else {
						$tmpobj.'Onyphe-Property-Count' = 1
					}
					$tmpobj.'Onyphe-Facet' = $facet
					$script:AllFacetObjects += $tmpobj
				}
				$tmpmeasureobj = $script:AllFacetObjects.'Onyphe-Property-Count' | measure-object -Sum -Maximum -Minimum -Average
				$script:results += New-Object psobject -Property @{
					Stats = $script:AllFacetObjects
					Count = $tmpmeasureobj.Count
					Sum = $tmpmeasureobj.Sum
					Min = $tmpmeasureobj.Minimum
					Max = $tmpmeasureobj.Maximum
					Average = $tmpmeasureobj.Average
				}
			}
		} Else {
			$script:AllFacetObjects = @()
			$tmp = $InputOnypheObject.results."$($Facets)" | sort-object | get-unique
			foreach ($object in $tmp) {
				$tmpobj = $script:TemplateFacetObject | Select-Object *
				$tmpobj.'Onyphe-Property-value' = $object
				if (($InputOnypheObject.results | Where-Object {$_."$($Facets)" -eq "$($object)"}).count) {
					$tmpobj.'Onyphe-Property-Count' = ($InputOnypheObject.results | Where-Object {$_."$($Facets)" -eq "$($object)"}).count
				} Else {
					$tmpobj.'Onyphe-Property-Count' = 1
				}
				$tmpobj.'Onyphe-Facet' = $Facets
				$script:AllFacetObjects += $tmpobj
			}
			$tmpmeasureobj = $script:AllFacetObjects.'Onyphe-Property-Count' | measure-object -Sum -Maximum -Minimum -Average
			$script:results = New-Object psobject -Property @{
				Stats = $script:AllFacetObjects
				Count = $tmpmeasureobj.Count
				Sum = $tmpmeasureobj.Sum
				Min = $tmpmeasureobj.Minimum
				Max = $tmpmeasureobj.Maximum
				Average = $tmpmeasureobj.Average
			}
		}
		$results
	}
	}
