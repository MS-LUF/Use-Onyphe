	Function Save-OnypheConfigFile {
	<#
		.SYNOPSIS
		write the Use-Onyphe configuration object to the JSON configuration file

		.DESCRIPTION
		write the Use-Onyphe configuration object to the JSON configuration file, creating the
		containing directory if it does not exist yet. Writes to a temporary file in the same
		directory first, then renames it into place, so a crash mid-write cannot leave a
		truncated or corrupted configuration file behind.

		.PARAMETER Config
		the configuration object to persist, as returned by Read-OnypheConfigFile

		.OUTPUTS
		none

		.EXAMPLE
		Save-OnypheConfigFile -Config $Config
	#>
	[cmdletbinding()]
	Param (
		[parameter(Mandatory=$true)]
			[PSCustomObject]$Config
	)
		$ConfigPath = Get-OnypheConfigPath
		$ConfigDir = Split-Path -Path $ConfigPath -Parent
		if (!(Test-Path -Path $ConfigDir)) {
			New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
		}
		$TempConfigPath = Join-Path -Path $ConfigDir -ChildPath ([System.IO.Path]::GetRandomFileName())
		$Config | ConvertTo-Json -Depth 10 | Set-Content -Path $TempConfigPath -Encoding UTF8
		Move-Item -Path $TempConfigPath -Destination $ConfigPath -Force
	}
