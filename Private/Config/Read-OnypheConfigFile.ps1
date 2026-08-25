	Function Read-OnypheConfigFile {
	<#
		.SYNOPSIS
		read the Use-Onyphe JSON configuration file, migrating legacy Clixml files if found

		.DESCRIPTION
		read the Use-Onyphe JSON configuration file, migrating legacy Clixml files if found.
		Reads fresh from disk on every call, no in-memory cache. When the JSON file does not
		exist yet but a legacy Use-Onyphe-Config.xml and/or Onyphe-Data-Model.xml is found, the
		legacy data is transparently migrated into the new JSON file. Returns a default empty
		configuration object when neither the JSON file nor any legacy XML file exists yet.

		.OUTPUTS
		PSCustomObject

		.EXAMPLE
		Read-OnypheConfigFile
	#>
	[cmdletbinding()]
	Param ()
		$ConfigPath = Get-OnypheConfigPath
		if (Test-Path -Path $ConfigPath -PathType Leaf) {
			try {
				Get-Content -Path $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
			} catch {
				throw "Use-Onyphe configuration file '$($ConfigPath)' is corrupted or not valid JSON: $($_.Exception.Message)"
			}
		} else {
			$LegacyConfig = ConvertFrom-OnypheLegacyConfig
			if ($LegacyConfig) {
				Save-OnypheConfigFile -Config $LegacyConfig
				$LegacyConfig
			} else {
				[PSCustomObject]@{
					version   = '1.0'
					APIKey    = [PSCustomObject]@{ Salt = $null; EncryptedAPIKey = $null }
					Proxy     = [PSCustomObject]@{}
					DataModel = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null }
					Logging   = [PSCustomObject]@{}
				}
			}
		}
	}
