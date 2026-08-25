	Function Write-OnypheEventLogEntry {
	<#
		.SYNOPSIS
		write one entry to the configured Windows Event Log, creating the source if needed

		.DESCRIPTION
		Ensures the configured event source exists (registering it under the configured log
		name via New-EventLog if not - this requires an elevated session the first time), then
		writes the entry with the EventId/EntryType matching its level. Debug-level entries are
		written as Information entries (there is no dedicated Debug event ID or entry type in
		Windows Event Log) with the message prefixed [DEBUG].

		Never throws: a failure (source creation denied, log unreachable, or running on a
		PowerShell host without the Windows Event Log cmdlets - e.g. PowerShell Core, which does
		not ship Write-EventLog/New-EventLog) is surfaced once per session via Write-Warning and
		that entry is skipped, so a broken logging destination never interrupts the calling
		cmdlet's actual Onyphe API work.

		.PARAMETER EventLog
		the Logging.EventLog section as returned by Get-OnypheLoggingConfig

		.PARAMETER Entry
		the log entry object (Timestamp, Level, UserName, CmdletName, Message) as built by
		Write-OnypheLog

		.OUTPUTS
		none

		.EXAMPLE
		Write-OnypheEventLogEntry -EventLog $LoggingConfig.EventLog -Entry $Entry
	#>
	[cmdletbinding()]
	Param (
		[parameter(Mandatory=$true)]
			[PSCustomObject]$EventLog,
		[parameter(Mandatory=$true)]
			[PSCustomObject]$Entry
	)
		try {
			if (!(Get-Command -Name 'Write-EventLog' -ErrorAction SilentlyContinue)) {
				if (!$script:LoggingSinkFailed) {
					$script:LoggingSinkFailed = $true
					Write-Warning "Use-Onyphe event log logging is not available on this PowerShell host (Write-EventLog not found) and will be skipped for the rest of this session."
				}
				return
			}

			if (!(Test-OnypheEventSourceExists -Source $EventLog.Source)) {
				New-EventLog -LogName $EventLog.LogName -Source $EventLog.Source
			}

			$EntryType = [System.Diagnostics.EventLogEntryType]::Information
			$EventId   = $EventLog.EventIdInformation
			if ($Entry.Level -eq 'Warning') {
				$EntryType = [System.Diagnostics.EventLogEntryType]::Warning
				$EventId   = $EventLog.EventIdWarning
			} elseif ($Entry.Level -eq 'Error') {
				$EntryType = [System.Diagnostics.EventLogEntryType]::Error
				$EventId   = $EventLog.EventIdError
			}

			$Prefix = ''
			if ($Entry.Level -eq 'Debug') { $Prefix = '[DEBUG] ' }
			$Message = "$Prefix[$($Entry.UserName)] [$($Entry.CmdletName)] $($Entry.Message)"

			Write-EventLog -LogName $EventLog.LogName -Source $EventLog.Source -EntryType $EntryType -EventId $EventId -Message $Message
		} catch {
			if (!$script:LoggingSinkFailed) {
				$script:LoggingSinkFailed = $true
				Write-Warning "Use-Onyphe event log logging failed and will be skipped for the rest of this session: $_"
			}
		}
	}
