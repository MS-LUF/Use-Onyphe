	Function Get-OnypheLoggingConfig {
	<#
		.SYNOPSIS
		read and normalize the Logging section of the Use-Onyphe configuration

		.DESCRIPTION
		Returns the Config.Logging block with every key defaulted when absent, so callers never
		need to null-check. Configs written before the logging feature existed have no Logging
		key at all, which normalizes to Enabled = $false (opt-in). MinimumLevel and Mode are
		validated against their known sets; an invalid value falls back to the default and
		emits one Write-Warning per session rather than failing every log call.

		.PARAMETER Config
		the parsed configuration object returned by Read-OnypheConfigFile

		.OUTPUTS
		PSCustomObject

		.EXAMPLE
		Get-OnypheLoggingConfig -Config (Read-OnypheConfigFile)
	#>
	[cmdletbinding()]
	Param (
		[parameter(Mandatory=$true)]
			[PSCustomObject]$Config
	)
		$Logging = $Config.Logging

		$Enabled = $false
		if ($Logging -and ($null -ne $Logging.Enabled)) { $Enabled = [bool]$Logging.Enabled }

		$MinimumLevel = 'Information'
		if ($Logging -and $Logging.MinimumLevel) {
			if ($script:LogLevelSeverity.ContainsKey($Logging.MinimumLevel)) {
				$MinimumLevel = $Logging.MinimumLevel
			} elseif (!$script:LoggingConfigWarned) {
				$script:LoggingConfigWarned = $true
				Write-Warning "Logging.MinimumLevel '$($Logging.MinimumLevel)' is not one of Debug/Information/Warning/Error; using 'Information'."
			}
		}

		$Mode = 'File'
		if ($Logging -and $Logging.Mode) {
			if (($Logging.Mode -eq 'File') -or ($Logging.Mode -eq 'EventLog')) {
				$Mode = $Logging.Mode
			} elseif (!$script:LoggingConfigWarned) {
				$script:LoggingConfigWarned = $true
				Write-Warning "Logging.Mode '$($Logging.Mode)' is not one of File/EventLog; using 'File'."
			}
		}

		$FilePath = '%USERPROFILE%\Documents\Use-Onyphe\Logs'
		if ($Logging -and $Logging.File -and $Logging.File.Path) { $FilePath = $Logging.File.Path }

		$FileName = 'Use-Onyphe-{yyyyMMdd}.log'
		if ($Logging -and $Logging.File -and $Logging.File.FileName) { $FileName = $Logging.File.FileName }

		$EventLogName = 'Application'
		if ($Logging -and $Logging.EventLog -and $Logging.EventLog.LogName) { $EventLogName = $Logging.EventLog.LogName }

		$EventSource = 'Use-Onyphe'
		if ($Logging -and $Logging.EventLog -and $Logging.EventLog.Source) { $EventSource = $Logging.EventLog.Source }

		$EventIdInformation = 1000
		if ($Logging -and $Logging.EventLog -and $Logging.EventLog.EventIdInformation) {
			$EventIdInformation = [int]$Logging.EventLog.EventIdInformation
		}

		$EventIdWarning = 2000
		if ($Logging -and $Logging.EventLog -and $Logging.EventLog.EventIdWarning) {
			$EventIdWarning = [int]$Logging.EventLog.EventIdWarning
		}

		$EventIdError = 3000
		if ($Logging -and $Logging.EventLog -and $Logging.EventLog.EventIdError) {
			$EventIdError = [int]$Logging.EventLog.EventIdError
		}

		[PSCustomObject]@{
			Enabled      = $Enabled
			MinimumLevel = $MinimumLevel
			Mode         = $Mode
			File         = [PSCustomObject]@{
				Path     = $FilePath
				FileName = $FileName
			}
			EventLog     = [PSCustomObject]@{
				LogName            = $EventLogName
				Source             = $EventSource
				EventIdInformation = $EventIdInformation
				EventIdWarning     = $EventIdWarning
				EventIdError       = $EventIdError
			}
		}
	}
