	Function Export-OnypheDataShot {
	<#
	  .SYNOPSIS 
	  Export encoded base64 jpg file from a datashot category object
  
	  .DESCRIPTION
	  Export encoded base64 jpg file from a datashot category object
	  
	  .OUTPUTS
	  jpg file
	  
	  .EXAMPLE
	  Export all screenshots available in powershell object $temp into C:\temp folder
	  C:\PS> Export-OnypheDataShot -tofolder C:\temp -InputOnypheObject $temp
	#>
		[cmdletbinding()]
		Param (
			[parameter(Mandatory=$true)]
			[ValidateScript({test-path "$($_)"})]
				[string]$tofolder,
			[parameter(ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true,Mandatory=$true)]
			[Alias("input")]
			[ValidateScript({($_ -is [System.Management.Automation.PSCustomObject]) -or ($_ -is [Deserialized.System.Management.Automation.PSCustomObject])})]
				[array]$InputOnypheObject
			)
			Process {
				$Config = Read-OnypheConfigFile
				Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters
				$ticks = (get-date).ticks.ToString()
				foreach ($result in $InputOnypheObject) {
					$datashotsfilter = $result.results | Where-Object {($_.'@category' -eq 'datashot') -or ($_.'@category' -eq 'onionshot')}
					foreach ($datashot in $datashotsfilter) {
						if ($datashot.app.screenshot.image) {
							$file = "$($ticks)_$($datashot.datamd5)_$((Get-Random -Maximum 999).tostring()).jpg"
							$fullfilepath = join-path $tofolder $file
							if ($host.Version.Major -ge 6) {
								[System.Convert]::FromBase64String($datashot.app.screenshot.image) | Set-Content $fullfilepath -AsByteStream -Force
							} else {
								[System.Convert]::FromBase64String($datashot.app.screenshot.image) | Set-Content $fullfilepath -Encoding Byte -Force
							}
						}
					}
				}
			}
	}
