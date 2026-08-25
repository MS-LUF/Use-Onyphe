BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Export-OnypheDataShot' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
	}

	It 'writes a jpg file for a datashot-category result with an image' {
		$Folder = Join-Path $TestDrive 'shots1'
		New-Item -ItemType Directory -Path $Folder | Out-Null
		$Base64Image = [Convert]::ToBase64String([byte[]](0xFF, 0xD8, 0xFF, 0xE0))
		$InputObj = [PSCustomObject]@{
			results = @(
				[PSCustomObject]@{
					'@category' = 'datashot'
					datamd5     = 'abc123'
					app         = [PSCustomObject]@{ screenshot = [PSCustomObject]@{ image = $Base64Image } }
				}
			)
		}

		Export-OnypheDataShot -tofolder $Folder -InputOnypheObject $InputObj

		(Get-ChildItem -Path $Folder -Filter '*.jpg').Count | Should -Be 1
	}

	It 'writes a jpg file for an onionshot-category result' {
		$Folder = Join-Path $TestDrive 'shots2'
		New-Item -ItemType Directory -Path $Folder | Out-Null
		$Base64Image = [Convert]::ToBase64String([byte[]](0xFF, 0xD8))
		$InputObj = [PSCustomObject]@{
			results = @(
				[PSCustomObject]@{
					'@category' = 'onionshot'
					datamd5     = 'def456'
					app         = [PSCustomObject]@{ screenshot = [PSCustomObject]@{ image = $Base64Image } }
				}
			)
		}

		Export-OnypheDataShot -tofolder $Folder -InputOnypheObject $InputObj

		(Get-ChildItem -Path $Folder -Filter '*.jpg').Count | Should -Be 1
	}

	It 'writes nothing for non-datashot/onionshot categories' {
		$Folder = Join-Path $TestDrive 'shots3'
		New-Item -ItemType Directory -Path $Folder | Out-Null
		$InputObj = [PSCustomObject]@{
			results = @(
				[PSCustomObject]@{ '@category' = 'geoloc'; country = 'US' }
			)
		}

		Export-OnypheDataShot -tofolder $Folder -InputOnypheObject $InputObj

		(Get-ChildItem -Path $Folder).Count | Should -Be 0
	}

	It 'accepts -InputOnypheObject from the pipeline' {
		$Folder = Join-Path $TestDrive 'shots5'
		New-Item -ItemType Directory -Path $Folder | Out-Null
		$Base64Image = [Convert]::ToBase64String([byte[]](0xFF, 0xD8, 0xFF, 0xE0))
		$InputObj = [PSCustomObject]@{
			results = @(
				[PSCustomObject]@{
					'@category' = 'datashot'
					datamd5     = 'piped123'
					app         = [PSCustomObject]@{ screenshot = [PSCustomObject]@{ image = $Base64Image } }
				}
			)
		}

		$InputObj | Export-OnypheDataShot -tofolder $Folder

		(Get-ChildItem -Path $Folder -Filter '*.jpg').Count | Should -Be 1
	}

	It 'skips results with no screenshot image present' {
		$Folder = Join-Path $TestDrive 'shots4'
		New-Item -ItemType Directory -Path $Folder | Out-Null
		$InputObj = [PSCustomObject]@{
			results = @(
				[PSCustomObject]@{ '@category' = 'datashot'; datamd5 = 'none'; app = [PSCustomObject]@{ screenshot = [PSCustomObject]@{ image = $null } } }
			)
		}

		Export-OnypheDataShot -tofolder $Folder -InputOnypheObject $InputObj

		(Get-ChildItem -Path $Folder).Count | Should -Be 0
	}
}
