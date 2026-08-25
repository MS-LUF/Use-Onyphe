	Function Test-OnypheEventSourceExists {
	<#
		.SYNOPSIS
		return whether a Windows Event Log source is already registered

		.DESCRIPTION
		Thin wrapper around [System.Diagnostics.EventLog]::SourceExists(), extracted into its
		own function so Write-OnypheEventLogEntry's source-creation branch can be unit tested
		with a mock instead of depending on real Windows Event Log state or elevation.

		.PARAMETER Source
		the event source name to check

		.OUTPUTS
		bool

		.EXAMPLE
		Test-OnypheEventSourceExists -Source 'Use-Onyphe'
	#>
	[cmdletbinding()]
	Param (
		[parameter(Mandatory=$true)]
			[string]$Source
	)
		[System.Diagnostics.EventLog]::SourceExists($Source)
	}
