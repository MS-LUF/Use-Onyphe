	Function Write-OnypheFileLogEntry {
	<#
		.SYNOPSIS
		append one formatted log line to the configured log file

		.DESCRIPTION
		Resolves the log file path from the Logging.File configuration and appends a single
		line. Never throws: a failure (bad path, permissions, locked file) is surfaced once per
		session via Write-Warning and silently skipped afterwards, so a broken logging
		destination never interrupts the calling cmdlet's actual Onyphe API work.

		.PARAMETER File
		the Logging.File section (Path, FileName) as returned by Get-OnypheLoggingConfig

		.PARAMETER Entry
		the log entry object (Timestamp, Level, UserName, CmdletName, Message) as built by
		Write-OnypheLog

		.OUTPUTS
		none

		.EXAMPLE
		Write-OnypheFileLogEntry -File $LoggingConfig.File -Entry $Entry
	#>
	[cmdletbinding()]
	Param (
		[parameter(Mandatory=$true)]
			[PSCustomObject]$File,
		[parameter(Mandatory=$true)]
			[PSCustomObject]$Entry
	)
		try {
			$LogPath = Resolve-OnypheLogFilePath -File $File

			$Line = '{0:yyyy-MM-dd HH:mm:ss.fff} [{1}] [{2}] [{3}] {4}' -f `
				$Entry.Timestamp, $Entry.Level.ToUpper(), $Entry.UserName, $Entry.CmdletName, $Entry.Message

			Add-Content -Path $LogPath -Value $Line -Encoding UTF8
		} catch {
			if (!$script:LoggingSinkFailed) {
				$script:LoggingSinkFailed = $true
				Write-Warning "Use-Onyphe file logging failed and will be skipped for the rest of this session: $_"
			}
		}
	}
