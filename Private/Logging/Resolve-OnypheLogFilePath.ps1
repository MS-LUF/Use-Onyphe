	Function Resolve-OnypheLogFilePath {
	<#
		.SYNOPSIS
		resolve the full log file path from the Logging.File configuration

		.DESCRIPTION
		Expands environment variables in the configured Path (e.g. %USERPROFILE%) and any
		{DateFormatToken} placeholders in the configured FileName (e.g. {yyyyMMdd}) using .NET
		date format strings evaluated against the current date, then ensures the target
		directory exists.

		.PARAMETER File
		the Logging.File section (Path, FileName) as returned by Get-OnypheLoggingConfig

		.OUTPUTS
		string

		.EXAMPLE
		Resolve-OnypheLogFilePath -File $LoggingConfig.File
	#>
	[cmdletbinding()]
	Param (
		[parameter(Mandatory=$true)]
			[PSCustomObject]$File
	)
		$ExpandedPath = [System.Environment]::ExpandEnvironmentVariables($File.Path)

		$ExpandedFileName = [regex]::Replace($File.FileName, '\{([^}]+)\}', {
			param($match)
			(Get-Date).ToString($match.Groups[1].Value)
		})

		if (!(Test-Path -Path $ExpandedPath)) {
			New-Item -ItemType Directory -Path $ExpandedPath -Force | Out-Null
		}

		Join-Path -Path $ExpandedPath -ChildPath $ExpandedFileName
	}
