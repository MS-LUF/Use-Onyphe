	Function ConvertFrom-OnypheLegacyConfig {
	<#
		.SYNOPSIS
		build a new JSON configuration object from legacy Clixml configuration files, if present

		.DESCRIPTION
		build a new JSON configuration object from legacy Clixml configuration files, if
		present. Looks for the legacy encrypted-API-key file (Use-Onyphe-Config.xml, user
		profile) and the legacy facets/filters cache (Onyphe-Data-Model.xml, module root)
		independently - either, both, or neither may exist. Returns $null when neither legacy
		file is found, so callers know no migration is needed. The encrypted API key blob and
		its salt are carried over as-is (salt base64-encoded for JSON) - no master password is
		needed to perform this migration step, only to later decrypt the key.

		.OUTPUTS
		PSCustomObject or $null

		.EXAMPLE
		ConvertFrom-OnypheLegacyConfig
	#>
	[cmdletbinding()]
	Param ()
		if (!$home) {
			$global:home = $env:userprofile
		}
		$LegacyAPIKeyPath = Join-Path -Path $home -ChildPath 'Use-Onyphe\Use-Onyphe-Config.xml'
		$LegacyDataModelPath = Join-Path -Path $script:ModuleRoot -ChildPath 'Onyphe-Data-Model.xml'

		$HasLegacyAPIKey = Test-Path -Path $LegacyAPIKeyPath -PathType Leaf
		$HasLegacyDataModel = Test-Path -Path $LegacyDataModelPath -PathType Leaf

		if (!$HasLegacyAPIKey -and !$HasLegacyDataModel) {
			return $null
		}

		$APIKeySection = [PSCustomObject]@{ Salt = $null; EncryptedAPIKey = $null }
		if ($HasLegacyAPIKey) {
			Write-Verbose -Message "migrating legacy API key configuration from $LegacyAPIKeyPath"
			$LegacyAPIKeyConfig = Import-Clixml -Path $LegacyAPIKeyPath
			$APIKeySection = [PSCustomObject]@{
				Salt            = [Convert]::ToBase64String($LegacyAPIKeyConfig.Salt)
				EncryptedAPIKey = $LegacyAPIKeyConfig.EncryptedAPIKey
			}
		}

		$DataModelSection = [PSCustomObject]@{ apis = $null; filters = $null; functions = $null }
		if ($HasLegacyDataModel) {
			Write-Verbose -Message "migrating legacy facets/filters cache from $LegacyDataModelPath"
			$LegacyDataModel = Import-Clixml -Path $LegacyDataModelPath
			$DataModelSection = [PSCustomObject]@{
				apis      = $LegacyDataModel.apis
				filters   = $LegacyDataModel.filters
				functions = $LegacyDataModel.functions
			}
		}

		[PSCustomObject]@{
			version   = '1.0'
			APIKey    = $APIKeySection
			Proxy     = [PSCustomObject]@{}
			DataModel = $DataModelSection
			Logging   = [PSCustomObject]@{}
		}
	}
