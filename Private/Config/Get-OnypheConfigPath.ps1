	Function Get-OnypheConfigPath {
	<#
		.SYNOPSIS
		resolve the full path to the Use-Onyphe JSON configuration file

		.DESCRIPTION
		resolve the full path to the Use-Onyphe JSON configuration file, stored in the user's
		profile ($home\Use-Onyphe\Use-Onyphe-Config.json) rather than the module install
		directory, so it survives module upgrades/reinstalls and stays writable even when the
		module itself is installed AllUsers-scope (read-only to standard users).

		.OUTPUTS
		string

		.EXAMPLE
		Get-OnypheConfigPath
	#>
	[cmdletbinding()]
	Param ()
		if (!$home) {
			$global:home = $env:userprofile
		}
		Join-Path -Path $home -ChildPath 'Use-Onyphe\Use-Onyphe-Config.json'
	}
