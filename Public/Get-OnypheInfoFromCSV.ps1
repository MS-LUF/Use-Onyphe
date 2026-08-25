	Function Get-OnypheInfoFromCSV {
 <#
	.SYNOPSIS 
	Get IP information from onyphe.io web service using as an input a CSV file containing all information

	.DESCRIPTION
	get various ip data information from onyphe.io web service using as an input a csv file (; separator)
	
	.PARAMETER fromcsv
	-fromcsv string{full path to csv file}
	automate onyphe.io request for multiple IP request
	
	.PARAMETER APIKey
	-APIKey string{APIKEY}
	set your APIKEY to be able to use Onyphe API.

	.PARAMETER csvdelimiter
	-csvdelimiter string{csv separator}
	set your csv separator. default is ;
	
	.OUTPUTS
	TypeName: System.Management.Automation.PSCustomObject
		
	.EXAMPLE
	Request info for several IP information from a csv formated file and your API key is already set as global variable
	C:\PS> Get-onypheinfofromcsv -fromcsv .\input.csv
	
	.EXAMPLE
	Request info for several IP information from a csv formated file and set the API key as global variable
	C:\PS> Get-onypheinfofromcsv -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

	.EXAMPLE
	Request info for several IP information from a csv formated file using ',' separator and set the API key as global variable
	C:\PS> Get-onypheinfofromcsv -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -csvdelimiter ","
#>
  [cmdletbinding()]
  Param (
  	[parameter(Mandatory=$true)]
  	[ValidateScript({test-path "$($_)"})]
		  $fromcsv,
  	[parameter(Mandatory=$false)]
	  [ValidateLength(40,40)]
		  [string]$APIKey,
	  [parameter(Mandatory=$false)]
    	$csvdelimiter
	)
	process {
		$Config = Read-OnypheConfigFile
		Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
		$Script:Result = @()
		if ($APIKey) {
			Set-OnypheAPIKey -APIKEY $APIKey | out-null
		}
		if (!$csvdelimiter) {$csvdelimiter = ";"}
		if (($fromcsv -is [System.String]) -and (test-path $fromcsv)) {
				$csvcontent = import-csv $fromcsv -delimiter $csvdelimiter
		} ElseIf (($fromcsv -is [System.Management.Automation.PSCustomObject]) -and $fromcsv.'API-Input') {
			$csvcontent = $fromcsv
		} Else {
			write-verbose -message "provide a valid csv file as input or valid System.Management.Automation.PSCustomObject object"
			write-verbose -message "please use the following column in your file : ip, searchtype, datascanstring"
			throw "please provide a valid csv file as input or valid System.Management.Automation.PSCustomObject object"
		}
		$APISearchEntries = $csvcontent | where-object {$_.API -eq "Search"}
		foreach ($entry in $APISearchEntries) {
			$params = @{
				SearchType = $entry.'search-category'
				Wait = 3
			 }
			if ($entry.'Search-Request'.contains("+")) {
				$tmparray = $entry.'Search-Request'.split("+")
				$params.add('AdvancedSearch',$tmparray)
			} else {
				$params.add('AdvancedSearch',@($entry.'Search-Request'))
			}
			if ($entry.'Filter-Request') {
				if ($entry.'Filter-Request'.contains("+")) {
					$tmparray = $entry.'Filter-Request'.split("+")
					$params.add('AdvancedFilter',$tmparray)
				} else {
					$params.add('AdvancedFilter', $entry.'Filter-Request')
				}
			}
			if ($entry.'Page') {
				$params.add('Page', $entry.'Page')
			}
			$Script:Result += Search-OnypheInfo @params
		}
		$SummaryEntries = $csvcontent | where-object {($_.API -eq "IP") -or ($_.API -eq "Domain") -or ($_.API -eq "HostName")}
		foreach ($entry in $SummaryEntries) {
				$Script:Result += Get-OnypheSummary -SummaryAPIType $entry.API -SearchValue $entry.'API-Input' -wait 3
		}
		$SimpleEntries = $csvcontent | where-object {($_.API -ne "IP") -and ($_.API -ne "Domain") -and ($_.API -ne "HostName") -and ($_.API -ne "Search")}
		foreach ($entry in $SimpleEntries) {
			if ($entry.Best -eq "True") {
				$Script:Result += Get-OnypheInfo -Category $entry.API -SearchValue $entry.'API-Input' -best -wait 3
			} else {
				$Script:Result += Get-OnypheInfo -Category $entry.API -SearchValue $entry.'API-Input' -wait 3
			}
		}
		$Script:Result
	}
	}
