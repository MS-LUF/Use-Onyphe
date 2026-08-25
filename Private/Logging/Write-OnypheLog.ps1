	Function Write-OnypheLog {
	<#
		.SYNOPSIS
		write a log entry to the configured logging destination (file or Windows Event Log)

		.DESCRIPTION
		Central logging entry point, intended to be called by public cmdlets. Reads and
		normalizes the Logging section of the configuration, filters by MinimumLevel, and
		dispatches to Write-OnypheFileLogEntry or Write-OnypheEventLogEntry depending on Mode.
		Every entry is stamped with the identity of the user running the command
		([System.Environment]::UserName - used instead of WindowsIdentity so this keeps working
		on the PowerShell Core/Linux/macOS hosts this module also targets).

		When -BoundParameters is supplied, its keys/values are appended to the message with
		Credential/Password/Secret/Token/APIKey-named parameters redacted, so secrets - notably
		the -APIKey parameter used throughout this module - never reach a log file or the
		Windows Event Log. Callers typically pass this only on the Debug-level entry-point log
		for each cmdlet invocation.

		No-ops silently when logging is disabled (Logging.Enabled = $false, the default for
		configs that predate this feature) or when Level is below the configured
		MinimumLevel. Never throws - a logging failure must never break the cmdlet's actual
		Onyphe API work.

		.PARAMETER Config
		the parsed configuration object returned by Read-OnypheConfigFile

		.PARAMETER Level
		severity of this entry: Debug, Information, Warning, or Error

		.PARAMETER Message
		the log message

		.PARAMETER CmdletName
		name of the calling cmdlet, e.g. $MyInvocation.MyCommand.Name

		.PARAMETER BoundParameters
		optional. $PSBoundParameters of the calling cmdlet; appended to the message with
		sensitive values redacted

		.OUTPUTS
		none

		.EXAMPLE
		Write-OnypheLog -Config $Config -Level Debug -CmdletName $MyInvocation.MyCommand.Name -Message 'Cmdlet invoked' -BoundParameters $PSBoundParameters

		.EXAMPLE
		Write-OnypheLog -Config $Config -Level Information -CmdletName 'Get-OnypheInfo' -Message 'Retrieved results for category geoloc'
	#>
	[cmdletbinding()]
	Param (
		[parameter(Mandatory=$true)]
			[PSCustomObject]$Config,
		[parameter(Mandatory=$true)]
			[ValidateSet('Debug','Information','Warning','Error')]
			[string]$Level,
		[parameter(Mandatory=$true)]
			[string]$Message,
		[parameter(Mandatory=$true)]
			[string]$CmdletName,
		[parameter(Mandatory=$false)]
			[hashtable]$BoundParameters
	)
		try {
			$LoggingConfig = Get-OnypheLoggingConfig -Config $Config
			if (!$LoggingConfig.Enabled) { return }

			$MinimumSeverity = $script:LogLevelSeverity[$LoggingConfig.MinimumLevel]
			$EntrySeverity   = $script:LogLevelSeverity[$Level]
			if ($EntrySeverity -lt $MinimumSeverity) { return }

			$FullMessage = $Message
			if ($BoundParameters) {
				$Redacted = foreach ($key in ($BoundParameters.Keys | Sort-Object)) {
					if ($key -match 'Credential|Password|Secret|Token|APIKey') {
						"$key=<redacted>"
					} else {
						"$key=$($BoundParameters[$key])"
					}
				}
				$FullMessage = "$Message ($($Redacted -join '; '))"
			}

			$Entry = [PSCustomObject]@{
				Timestamp  = Get-Date
				Level      = $Level
				UserName   = [System.Environment]::UserName
				CmdletName = $CmdletName
				Message    = $FullMessage
			}

			if ($LoggingConfig.Mode -eq 'EventLog') {
				Write-OnypheEventLogEntry -EventLog $LoggingConfig.EventLog -Entry $Entry
			} else {
				Write-OnypheFileLogEntry -File $LoggingConfig.File -Entry $Entry
			}
		} catch {
			if (!$script:LoggingSinkFailed) {
				$script:LoggingSinkFailed = $true
				Write-Warning "Use-Onyphe logging failed and will be skipped for the rest of this session: $_"
			}
		}
	}
