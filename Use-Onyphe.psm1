#
# Created by: lucas.cueff[at]lucas-cueff.com
#
# v0.3 : add a new function to export psobject content to files
# Released on: 12/2017
#
#'(c) 2017 lucas-cueff.com - Distributed under Artistic Licence 2.0 (https://opensource.org/licenses/artistic-license-2.0).'
<#
	.SYNOPSIS 
	commandline interface to use onyphe.io web service

	.DESCRIPTION
	use-onyphe.psm1 module provides a commandline interface to onyphe.io web service.
	Require PoshRSJob PowerShell module to use multithreading option of get-onypheinfo function.
	
	.EXAMPLE
	C:\PS> import-module use-onyphe.psm1
#>
function Get-OnypheInfoFromCSV {
  [cmdletbinding()]
  Param (
  [parameter(Mandatory=$true)]
  [ValidateScript({test-path "$($_)"})]
	$fromcsv,
  [parameter(Mandatory=$false)]
	[switch]$multithreading,
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey
  )
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
	
	.PARAMETER multithreading
	-multithreading switch
	 use .Net RunSpace to run invoke-webonypherequest in parallel to decrease execution time.
	 warning : do not provide more than 10 requests in a csv using this option or some of your requests could be blocked by rate limiting feature of the web server.
	
	.OUTPUTS
	TypeName: System.Management.Automation.PSCustomObject
	
	count   : 32
	error   : 0
	myip    : 127.0.0.1
	results : {@{@category=geoloc; @timestamp=2017-12-16T12:12:00.000Z; @type=ip; asn=AS15169; city=; country=US;
			  country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
			  longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}, @{@category=inetnum;
			  @timestamp=1970-01-01T00:00:00.000Z; @type=ip; country=US; information=System.Object[]; netname=Undisclosed;
			  seen_date=1970-01-01; source=Undisclosed; subnet=Undisclosed}, @{@category=pastries;
			  @timestamp=2017-12-16T11:29:53.000Z; @type=pastebin; domain=System.Object[]; hostname=System.Object[];
			  ip=System.Object[]; key=fuMJJB9i; seen_date=2017-12-16}, @{@category=pastries;
			  @timestamp=2017-12-16T08:37:28.000Z; @type=pastebin; domain=System.Object[]; hostname=System.Object[];
			  ip=System.Object[]; key=UMbLWStd; seen_date=2017-12-16}...}
	status  : ok
	took    : 0.106
	total   : 3607

	count   : 1
	error   : 0
	myip    : 127.0.0.1
	results : {@{@category=geoloc; @timestamp=2017-12-16T12:12:00.000Z; @type=ip; asn=; city=; country=US;
			  country_name=United States; geolocation=37.7510,-97.8220; ip=7.7.7.7; ipv6=false; latitude=37.7510;
			  longitude=-97.8220; organization=; subnet=7.0.0.0/11}}
	status  : ok
	took    : 0.001661
	total   : 1

	.EXAMPLE
	C:\PS> Get-onypheinfo -fromcsv .\input.csv -multithreading
	C:\PS> Get-onypheinfo -fromcsv .\input.csv
	C:\PS> Get-onypheinfo -fromcsv .\input.csv -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#>
  Begin {
	$global:Result = @()
	$global:FromcsvType = $fromcsv | Get-Member | Select-Object -ExpandProperty TypeName -Unique
	if (!$global:OnypheAPIKey) {
		if (!$APIKEY) {
			$errorvalue = @()
			$errorvalue += "Please provide an APIKey with -APIKEY parameter"
			if ($debug -or $verbose) {
				write-warning "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
			}
		} Else {
			Set-OnypheAPIKey -APIKEY $APIKey | out-null
		} 
	}
  } Process {
	if ($errorvalue) {return "Please provide an APIKey with -APIKEY parameter"}
	if (($global:FromcsvType -eq 'System.String') -and (test-path $fromcsv)) {
			$csvcontent = import-csv $fromcsv -delimiter ";"
			if (-not($csvcontent | select-string ";")) {
				write-warning "Please use a semicolon separator in $($fromcsv) CSV file"
				return -1
			}
		} ElseIf (($global:FromcsvType -eq 'System.Management.Automation.PSCustomObject') -and $fromcsv.ip) {
			$csvcontent = $fromcsv
		} Else {
			if ($debug -or $verbose) {
				write-warning "provide a valid csv file as input or valid System.Management.Automation.PSCustomObject object"
				write-warning "please use a semicolon separator in your CSV file"
				write-warning "please use the following column in your file : ip, searchtype, datascanstring"
			}
			return @{"error" = "System.Management.Automation.PSCustomObject"}
		}
		If ($multithreading) {
			try {
				import-module PoshRSJob
			} catch {
				if ($debug -or $verbose) {
					write-warning "please install PoshRSJob module to manage .Net RunSpace"
					write-warning "to install it from powershell gallery :"
					write-host "==> Install-Module -Name PoshRSJob" -foreground 'Green'
				}
				$errorvalue = @()
				$errorvalue += "please install PoshRSJob module to manage .Net RunSpace. To install it from powershell gallery : ==> Install-Module -Name PoshRSJob"
				return $errorvalue
			}
			$global:currentmodulepath = join-path (Get-ScriptDirectory) "Use-onyphe.psm1"
		}
		foreach ($entry in $csvcontent) {
			If (($entry.searchtype -ne 'DataScan') -and ($entry.searchtype -ne '') -and $entry.ip) {
				If ($multithreading) {
					$ipReq = $entry.ip
					$searhtypeReq = $entry.searchtype
					$APIKEYReq = $OnypheAPIKey
					start-rsjob -ModulesToImport $currentmodulepath -scriptblock {invoke-webonypherequest -IP $using:ipReq -searchtype $using:searhtypeReq -apikey $using:OnypheAPIKey} | out-null
				} Else {
					$global:Result += invoke-webonypherequest -IP $entry.ip -searchtype $entry.searchtype
				}
			} ElseIf (($entry.searchtype -eq 'DataScan')-and $entry.datascanstring -and $entry.ip) {
				If ($multithreading) {
					$ipReq = $entry.ip
					$searhtypeReq = $entry.searchtype
					$datascanstringReq = $entry.datascanstring
					$APIKEYReq = $OnypheAPIKey
					start-rsjob -ModulesToImport $currentmodulepath -scriptblock {invoke-webonypherequest -IP $using:ipReq -searchtype $using:searhtypeReq -datascanstring $using:datascanstringReq -apikey $using:OnypheAPIKey} | out-null
				} Else {
					$global:Result += invoke-webonypherequest -IP $entry.ip -searchtype $entry.searchtype -datascanstring $entry.datascanstring
				}
			} Else {
				If ($entry.ip) {
					If ($multithreading) {
						$ipReq = $entry.ip
						$APIKEYReq = $OnypheAPIKey
						start-rsjob -ModulesToImport $currentmodulepath -scriptblock {invoke-webonypherequest -IP $using:ipReq -APIKEY $using:OnypheAPIKey} | out-null
					} Else {
						$global:Result += invoke-webonypherequest -IP $entry.ip
					}
				}
			}
		}
  } End {
	If ($multithreading.IsPresent -eq $true) {
		get-rsjob | wait-rsjob | out-null
		$global:Result = get-rsjob | receive-rsjob
		get-rsjob | remove-rsjob | out-null
		write-warning "when using multithreading option some of your requests could be blocked because of rate limiting feature used by onyphe.io (no more than 10 requests at the same time)"
		return $global:Result
	} Else {
		return $global:Result
	}
  }
}

function Invoke-WebOnypheRequest {
  [cmdletbinding()]
  Param (
  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$false)]
    #[ValidatePattern("(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])")]
	[ValidateScript({($_ -match "(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])") -or ($_ -match "s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?")})]
    [string[]]$IP,
  [parameter(Mandatory=$false)] 
     [ValidateSet('Geoloc','Inetnum','Pastries','SynScan','Reverse','Forward','Threatlist','DataScan')]
     [String]$searchtype, 
  [parameter(Mandatory=$false)]
	[String[]]$DataScanString,
  [parameter(Mandatory=$false)]
	[switch]$MyIP,
  [parameter(Mandatory=$false)]
	[ValidateLength(40,40)]
	[string[]]$APIKey
  )
 <#
	.SYNOPSIS 
	Get IP information from onyphe.io web service

	.DESCRIPTION
	send HTTP request to onyphe.io web service and convert back JSON information to an hashtable

	.PARAMETER searchtype Geoloc
	-IP string{IP} -searchtype Geoloc string{IP}
	look for geoloc information about a specfic ip address in onyphe database

	.PARAMETER myip
	-Myip
	look for information about my public IP
	
	.PARAMETER searchtype Inetnum
	-IP string{IP} -searchtype Inetnum -APIKey string{APIKEY}
	look for an ip address in onyphe database

	.PARAMETER searchtype Threatlist
	-IP string{IP} -searchtype Threatlist -APIKey string{APIKEY}
	look for threat info about a specific IP in onyphe database.
	
	.PARAMETER searchtype Pastries
	-IP string{IP} -searchtype Pastries -APIKey string{APIKEY}
	look for an pastbin data about a specific IP in onyphe database.
	
	.PARAMETER searchtype Synscan
	-IP string{IP} -searchtype Synscan -APIKey string{APIKEY}
	look for open ports info for a specific IP in onyphe database.

	.PARAMETER searchtype Reverse
	-IP string{IP} -searchtype Reverse string{IP} -APIKey string{APIKEY}
	look for xxx in onyphe database.

	.PARAMETER searchtype Forward
	-IP string{IP} -searchtype Forward -APIKey string{APIKEY}
	look for xxx in onyphe database.
	
	.PARAMETER Datascan
	-IP string{IP} -Datascan string -APIKey string{APIKEY}
	look for an tcp service info for a specific IP in onyphe database.

	.PARAMETER IP
	-IP string{IP} -APIKey string{APIKEY}
	get all information available for a specific IP in onyphe database.
	
	.PARAMETER APIKey
	-APIKey string{APIKEY}
	set your APIKEY to be able to use Onyphe API.
	
	.OUTPUTS
	TypeName: System.Management.Automation.PSCustomObject
	
	count   : 32
	error   : 0
	myip    : 1.1.1.1
	results : {@{@category=geoloc; @timestamp=2017-12-14T07:10:53.000Z; @type=ip; asn=AS15169; city=; country=US;
			  country_name=United States; geolocation=37.7510,-97.8220; ip=8.8.8.8; ipv6=false; latitude=37.7510;
			  longitude=-97.8220; organization=Google LLC; subnet=8.8.0.0/19}, @{@category=inetnum;
			  @timestamp=1970-01-01T00:00:00.000Z; @type=ip; country=US; information=System.Object[]; netname=Undisclosed;
			  seen_date=1970-01-01; source=Undisclosed; subnet=Undisclosed}, @{@category=pastries;
			  @timestamp=2017-12-14T04:13:51.000Z; @type=pastebin; domain=System.Object[]; hostname=System.Object[];
			  ip=System.Object[]; key=pNhLGvpT; seen_date=2017-12-14}, @{@category=pastries;
			  @timestamp=2017-12-13T22:35:02.000Z; @type=pastebin; domain=System.Object[]; hostname=System.Object[];
			  ip=System.Object[]; key=ViArHJ18; seen_date=2017-12-13}...}
	status  : ok
	took    : 0.154
	total   : 3646

	.EXAMPLE
	C:\PS> Invoke-WebOnypheRequest -ip "192.168.1.5" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	C:\PS> Invoke-WebOnypheRequest -myip
	C:\PS> Invoke-WebOnypheRequest -ip "8.8.8.8" -searchtype Geoloc
	C:\PS> Invoke-WebOnypheRequest -ip "8.8.8.8" -searchtype Reverse -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	C:\PS> Invoke-WebOnypheRequest -ip "8.8.8.8" -searchtype DataScan -datascanstring "IIS" -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
#>

	Begin {
		$global:onypheurl = "https://www.onyphe.io/api/"
		if ($global:OnypheAPIKey) {
			$APIKEY = $global:OnypheAPIKey
		}
	} Process {
			If (($Searchtype -eq "Geoloc") -and (!$IP)) {
				$errorvalue = @()
				$errorvalue += "Please provide an IP adress with -IP parameter to use searchtype"
				if ($debug -or $verbose) {
						write-warning "incorrect parameter - Please provide an IP adress with -IP parameter to use searchtype"
				}
			}
			If (($Searchtype -eq "DataScan") -and (!$DataScanString)) {
				$errorvalue = @()
				$errorvalue += "Please provide a string to search for DataScan using -DataScanString parameter"
				if ($debug -or $verbose) {
					write-warning "incorrect parameter - Please provide an IP adress with -IP parameter to use DataScan"
				}
			}
			If ($MyIP.IsPresent -eq $false) {
				If (((!$IP) -or (!$APIKEY)) -and ($Searchtype -ne "Geoloc")) {
					$errorvalue = @()
					$errorvalue += "Please provide an IP adress with -IP parameter. Please provide an APIKEY adress with -APIKEY parameter to use Searchtype. The only searchtype available without APIKEY is Geoloc"
					if ($debug -or $verbose) {
						write-warning "incorrect parameter - Please provide an IP adress with -IP parameter. Please provide an APIKEY adress with -APIKEY parameter to use Searchtype. The only searchtype available without APIKEY is Geoloc"
					}
				}
			} 
			If (-not $errorvalue) {
				if ($IP) {
					$request = "ip/$($IP)?apikey=$($APIKEY)"
					
				}
				If ($searchtype) {
					switch ($searchtype) {
						"Geoloc" {$request = "geoloc/$($IP)"}
						"Inetnum" {$request = "inetnum/$($IP)?apikey=$($APIKEY)"}
						"Pastries" {$request = "pastries/$($IP)?apikey=$($APIKEY)"}
						"SynScan" {$request = "synscan/$($IP)?apikey=$($APIKEY)"}
						"Reverse" {$request = "reverse/$($IP)?apikey=$($APIKEY)"}
						"Forward" {$request = "forward/$($IP)?apikey=$($APIKEY)"}
						"Threatlist" {$request = "threatlist/$($IP)?apikey=$($APIKEY)"}
						"DataScan" {$request = "datascan/$($IP),$($DatascanString)?apikey=$($APIKEY)"}
					}
					
				}
				If ($MyIP.IsPresent) {
					$request = "myip/"
					
				}
				If ($request) {
					try {
						$onypheresult = invoke-webrequest "$($global:onypheurl)$($request)"
					} catch {
						if ($debug -or $verbose) {
							write-warning "Not able to use onyphe online service - KO"
							write-warning "Note : proxified connection not managed currently"
							write-warning "Error Type: $($_.Exception.GetType().FullName)"
							write-warning "Error Message: $($_.Exception.Message)"
							write-warning "HTTP error code:$($_.Exception.Response.StatusCode.Value__)"
							write-warning "HTTP error message:$($_.Exception.Response.StatusDescription)"
						}
					   $errorvalue = @()
					   $errorvalue += [PSCustomObject]@{
							Count = 0
							error = $_.Exception.Response.StatusCode.Value__
							myip = 0
							results = "Rate limit exceeded - $($_.Exception.Response.StatusDescription)"
							status = "ko"
							took = 0
							total = 0
						}
					}
				}
				if (-not $errorvalue) {
					try {
						
						$temp = $onypheresult.Content | convertfrom-json
						#$temp = Fix-JSONHash $temp
					} catch {
						if ($debug -or $verbose) {
							write-warning "unable to convert result into a powershell object - json error"
							write-warning "Error Type: $($_.Exception.GetType().FullName)"
							write-warning "Error Message: $($_.Exception.Message)"
						}
						$errorvalue = @()
						$errorvalue += "$($_.Exception.GetType().FullName) - $($_.Exception.Message) : $($onypheresult.Content)"
					}
				}

			}
	} End {
		if ($temp) {return $temp}
		if ($errorvalue) {return $errorvalue}
	}			
}

function Export-OnypheInfoToFile {
  [cmdletbinding()]
  Param (
  [parameter(Mandatory=$true)]
  [ValidateScript({test-path "$($_)"})]
	$tofolder,
  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
  [ValidateScript({(($_ | Get-Member | Select-Object -ExpandProperty TypeName -Unique) -eq 'System.Management.Automation.PSCustomObject') -or (($_ | Get-Member | Select-Object -ExpandProperty TypeName -Unique) -eq 'Selected.RSJob')})]
	$inputobject
  )
<#
	.SYNOPSIS 
	Export psobject containing Onyphe info to files

	.DESCRIPTION
	Export psobject containing Onyphe info to files
	One root folder is created and a dedicated csv file is created by category.
	Note : for the datascan category, the data attribute content is exported in a separated text file to be more readable.
	Note 2 : in this version, there is an issue if you pipe a psobject containing an array of onyphe result to the function. to be investigated.

	.PARAMETER tofolder
	-tofolcer string{target folder}
	path to the target folder where you want to export onyphe data

	.PARAMETER inputobject
	-inputobject $obj{output of Invoke-WebOnypheRequest or Get-OnypheInfoFromCSV functions}
	look for information about my public IP
		
	.OUTPUTS
	none
	
	.EXAMPLE
	C:\PS> Export-OnypheInfoToFile -tofolder C:\temp -inputobject $onypheresult
#>

  foreach ($result in $inputobject) {
	$tempfolder = $null
	$tempfolder = join-path $tofolder $((get-date).ticks)
	md $tempfolder -force | out-null
	$filterbaseobj = $result | select count,error,myip,status,took,total
	$filterbaseobj | Export-Csv -NoTypeInformation -path "$($tempfolder)\request_info.csv" -delimiter ";"
	If ($result.results.'@category' -eq 'geoloc') {
		$filteredobj = $result.results | where {$_.'@category' -eq 'geoloc'} | select '@type',asn,city,country_name,country,geolocation,ip,ipv6,latitude,longitude,organization,subnet,'@timestamp'
		$tempfilename = join-path $tempfolder "Geoloc.csv"
		$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter ";"
	}
	If ($result.results.'@category' -eq 'inetnum') {
		$filteredobj = $result.results | where {$_.'@category' -eq 'inetnum'} | select seen_date,'@type',country,@{Name='information';Expression={[string]::join(",",($_.information))}},netname,source,subnet,'@timestamp'
		$tempfilename = join-path $tempfolder "inetnum.csv"
		$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter ";"
	}	
 	If ($result.results.'@category' -eq 'synscan') {
		$filteredobj = $result.results | where {$_.'@category' -eq 'synscan'} | select seen_date,'@type',asn,country,ip,location,organization,os,port,'@timestamp'
		$tempfilename = join-path $tempfolder "synscan.csv"
		$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter ";"
	}
	If ($result.results.'@category' -eq 'resolver') {
		$filteredobj = $result.results | where {$_.'@category' -eq 'resolver'} | select seen_date,'@type',domain,forward,reverse,ip,ipv6,'@timestamp'
		$tempfilename = join-path $tempfolder "resolver.csv"
		$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter ";"
	}	
	If ($result.results.'@category' -eq 'threatlist') {
		$filteredobj = $result.results | where {$_.'@category' -eq 'threatlist'}
		$tempfilename = join-path $tempfolder "threatlist.csv"
		$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter ";" | select seen_date,'@type',subnet,threatlist,ipv6,'@timestamp'
	}
	If ($result.results.'@category' -eq 'Pastries') {
		$filteredobj = $result.results | where {$_.'@category' -eq 'pastries'} | select seen_date,'@type',@{Name='domain';Expression={[string]::join(",",($_.domain))}},@{Name='hostname';Expression={[string]::join(",",($_.hostname))}},@{Name='ip';Expression={[string]::join(",",($_.ip))}},key
		$tempfilename = join-path $tempfolder "Pastries.csv"
		$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter ";"
	}
	If ($result.results.'@category' -eq 'datascan') {
		$filteredobj = $result.results | where {$_.'@category' -eq 'datascan'} | select seen_date,'@type',ip,ipv6,port,protocol,product,productversion,os,asn,city,country,location,organization,'@timestamp'
		$filteredobjfull = $result.results | where {$_.'@category' -eq 'datascan'} | select seen_date,'@type',ip,ipv6,port,protocol,product,data,productversion,os,asn,city,country,location,organization,'@timestamp'
		$tempfilename = join-path $tempfolder "datascan.csv"
		$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter ";"
		foreach ($dataresult in $filteredobjfull) {
			$temptimestamp = $dataresult.'@timestamp' -replace ":","_"
			$tempfiledataresult = "$($temptimestamp)_$($dataresult.port)_$($dataresult.protocol).txt"
			$tempdataexportfile = join-path $tempfolder $tempfiledataresult
			$dataresult.data | add-content -path $tempdataexportfile
		}
	}
  }
  
}

function Fix-JSONHash {
    [cmdletbinding()]
	param(
        [parameter(Mandatory=$true)]
		$ObjToFix
    )
<#
	.SYNOPSIS 
	fix convertfrom-json issue

	.DESCRIPTION
	fix convertfrom-json issue

#>
		$hash = @{}
		$keys = $ObjToFix | gm -MemberType NoteProperty | select -exp Name
		$keys | foreach-object {
			$key=$_
			$obj=$ObjToFix.$($_)
			if($obj -match "@{"){
				$nesthash=Fix-JSONHash $obj
				$hash.add($key,$nesthash)
			} else {
			   $hash.add($key,$obj)
			}
		}
		return $hash
}

Function Get-ScriptDirectory {
<#
	.SYNOPSIS 
	retrieve current script directory

	.DESCRIPTION
	retrieve current script directory

#>
	#$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	#Split-Path $Invocation.MyCommand.Path
	Split-Path -Parent $PSCommandPath
}

Function Set-OnypheAPIKey {
  [cmdletbinding()]
  Param (
    [parameter(Mandatory=$false)]
    [ValidateLength(40,40)]
	[string[]]$APIKey,
	[parameter(Mandatory=$false)]
	[switch]$Remove
  )
  <#
	.SYNOPSIS 
	set and remove onyphe API key as global variable

	.DESCRIPTION
	set and remove onyphe API key as global variable
	
	.PARAMETER APIKEY
	-APIKey string{APIKEY}
	Set APIKEY as global variable.
	
	.PARAMETER Remove
	-Remove
	Remove your current APIKEY from global variable.
	
	.OUTPUTS
	none - write-host given apikey
	
	.EXAMPLE
	C:\PS> Set-OnypheAPIKey -apikey "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
	C:\PS> Set-OnypheAPIKey -remove

  #>
  if ($Remove.IsPresent) {
	$global:OnypheAPIKey = $Null
  } Else {
	$global:OnypheAPIKey = $APIKey
	return $global:OnypheAPIKey
  }
}

Export-ModuleMember -Function Invoke-WebonypheRequest, Fix-JSONHash, Get-OnypheInfoFromCSV, Get-ScriptDirectory, Set-OnypheAPIKey, Export-OnypheInfoToFile
