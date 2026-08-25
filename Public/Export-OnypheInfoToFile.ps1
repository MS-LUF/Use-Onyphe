	Function Export-OnypheInfoToFile {
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

		.PARAMETER InputOnypheObject
		-InputOnypheObject $obj{output of Get-OnypheInfo or Get-OnypheInfoFromCSV functions}
		look for information about my public IP

		.PARAMETER csvdelimiter
		-csvdelimiter string{csv separator}
		set your csv separator. default is ;
			
		.OUTPUTS
		none
		
		.EXAMPLE
		Exporting onyphe results containing into $onypheresult object to flat files in folder C:\temp
		C:\PS> Export-OnypheInfoToFile -tofolder C:\temp -InputOnypheObject $onypheresult

		.EXAMPLE
		Exporting onyphe results containing into $onypheresult object to flat files in folder C:\temp using ',' as csv separator
		C:\PS> Export-OnypheInfoToFile -tofolder C:\temp -InputOnypheObject $onypheresult -csvdelimiter ","
	#>
  [cmdletbinding()]
  Param (
  [parameter(Mandatory=$true)]
  [ValidateScript({test-path "$($_)"})]
		$tofolder,
  [parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
  [ValidateScript({($_ -is [System.Management.Automation.PSCustomObject]) -or ($_ -is [Deserialized.System.Management.Automation.PSCustomObject])})]
		[array]$InputOnypheObject,
  [parameter(Mandatory=$false)]
    $csvdelimiter
  )
  process {
	$Config = Read-OnypheConfigFile
	Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
	if (!$csvdelimiter) {$csvdelimiter = ";"}
	$ticks = (get-date).ticks.ToString()
	If ($InputOnypheObject.'cli-API_info') {
		$tmpinputobject = [Management.Automation.PSSerializer]::Serialize($InputOnypheObject)
		$InputOnypheObject = [Management.Automation.PSSerializer]::DeSerialize($tmpinputobject)
	} else {
		throw "invalid Onyphe PSObject provided"
	}
	foreach ($result in $InputOnypheObject) {
	  $tempfolder = $null
	  $tempattrib = $result.'cli-API_input' -replace ("[{0}]"-f (([System.IO.Path]::GetInvalidFileNameChars() | ForEach-Object {[regex]::Escape($_)}) -join '|')),'_'
	  $tempfolder = "Onyphe-result-$($tempattrib)"
	  $tempfolder = join-path $tofolder $tempfolder
	  if (!(test-path $tempfolder)) {mkdir $tempfolder -force | out-null}
	  $ticks = (get-date).ticks.ToString()
	  $result | Export-Csv -NoTypeInformation -path "$($tempfolder)\$($ticks)_request_info.csv" -delimiter $csvdelimiter
	  if ($result.ip) {$ip = $result.ip.tostring()}
	  switch ($result.results.'@category') {
		  'geoloc' {
			  $filteredobj = $result.results | where-object {$_.'@category' -eq 'geoloc'} | sort-object -property country
			  $tempfilename = join-path $tempfolder "$($ticks)_$($ip)_Geoloc.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'inetnum' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'inetnum'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_inetnum.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'synscan' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'synscan'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_synscan.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'resolver'{
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'resolver'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_resolver.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'threatlist' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'threatlist'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_threatlist.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'pastries' {
			  $filteredobj = $result.results | where-object {$_.'@category' -eq 'pastries'} | sort-object -property seen_date
			  $tempfilename = join-path $tempfolder "$($ticks)_$($ip)_Pastries.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			  foreach ($contentresult in $filteredobj) {
				  if ($contentresult.ip.count -gt 1) {
					  $ip = "multips-$($contentresult.ip[0].Replace(":","-"))"
					  $allip = $contentresult.ip -join ","
				  } else {
					  $ip = $contentresult.ip
				  }
				  $tempfilecontentresult = "$($ticks)_$($ip)_pastries_$($contentresult.key).txt"
					$tempcontentexportfile = join-path $tempfolder $tempfilecontentresult
				  if ($allip) {
					  set-content -path $tempcontentexportfile -value "########### info ip ###########"
					  add-content -path $tempcontentexportfile -value $allip
					  add-content -path $tempcontentexportfile -value "########### info ip ###########"
				  }
				  $contentresult.content | add-content -path $tempcontentexportfile
			  }
		  }
		  'sniffer' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'sniffer'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_Sniffer.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
		  }
		  'datascan' {
			  $filteredobj = $result.results | where-object {$_.'@category' -eq 'datascan'} | sort-object -property seen_date
			  $tempfilename = join-path $tempfolder "$($ticks)_$($ip)_datascan.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			  foreach ($dataresult in $filteredobj) {
				  if ($dataresult.ip.count -gt 1) {
					  $ip = "multips-$($dataresult.ip[0].Replace(":","-"))"
					  $allip = $dataresult.ip -join ","
				  } else {
					  $ip = $dataresult.ip
				  }
				  $tempfiledataresult = "$($ticks)_$($ip)_$($dataresult.port)_$($dataresult.protocol).txt"
					$tempdataexportfile = join-path $tempfolder $tempfiledataresult
				  if ($allip) {
					  set-content -path $tempdataexportfile -value "########### info ip ###########"
					  add-content -path $tempdataexportfile -value $allip
					  add-content -path $tempdataexportfile -value "########### info ip ###########"
				  }
				  $dataresult.data | add-content -path $tempdataexportfile
			  }
		  }
		  'onionscan' {
			  $filteredobj = $result.results | where-object {$_.'@category' -eq 'onionscan'} | sort-object -property seen_date
			  $tempfilename = join-path $tempfolder "$($ticks)_$($ip)_onionscan.csv"
			  $filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			  foreach ($dataresult in $filteredobj) {
				  if ($dataresult.ip.count -gt 1) {
					  $ip = "multips-$($dataresult.ip[0].Replace(":","-"))"
					  $allip = $dataresult.ip -join ","
				  } else {
					  $ip = $dataresult.ip
				  }
				  $tempfiledataresult = "$($ticks)_$($ip)_$($dataresult.port)_$($dataresult.protocol).txt"
				  $tempdataexportfile = join-path $tempfolder $tempfiledataresult
					if ($allip) {
					  set-content -path $tempdataexportfile -value "########### info ip ###########"
					  add-content -path $tempdataexportfile -value $allip
					  add-content -path $tempdataexportfile -value "########### info ip ###########"
				  }
				  $dataresult.data | add-content -path $tempdataexportfile
			  }
			}
			'ctl' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'ctl'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_ctl.csv"
			  	$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			}
			'datashot' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'datashot'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_datashot.csv"
				$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
				Export-OnypheDataShot -tofolder $tempfolder -InputOnypheObject $result
			}
			'vulnscan' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'vulnscan'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_vulnscan.csv"
			  	$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			}
			'topsite' {
				$filteredobj = $result.results | where-object {$_.'@category' -eq 'topsite'} | sort-object -property seen_date
				$tempfilename = join-path $tempfolder "$($ticks)_$($ip)_topsite.csv"
			  	$filteredobj | Export-Csv -NoTypeInformation -path "$($tempfilename)" -delimiter $csvdelimiter
			}
	  }
	}
  }
	}
