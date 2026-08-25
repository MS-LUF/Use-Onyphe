BeforeDiscovery {
	Import-Module (Join-Path $PSScriptRoot '..\..\Use-Onyphe.psd1') -DisableNameChecking -Force
}

Describe 'Export-OnypheInfoToFile' -Tag 'Unit' {
	BeforeEach {
		Mock -ModuleName Use-Onyphe Read-OnypheConfigFile { [PSCustomObject]@{} }
		Mock -ModuleName Use-Onyphe Export-OnypheDataShot { }
	}

	It 'throws when the input object is missing cli-API_info' {
		$Folder = Join-Path $TestDrive 'invalid'
		New-Item -ItemType Directory -Path $Folder | Out-Null
		$InputObj = [PSCustomObject]@{ results = @() }

		{ Export-OnypheInfoToFile -tofolder $Folder -InputOnypheObject $InputObj } | Should -Throw '*invalid Onyphe PSObject*'
	}

	It 'creates a result folder with a request_info.csv and a category-specific csv for a simple category' {
		$Folder = Join-Path $TestDrive 'inetnum-export'
		New-Item -ItemType Directory -Path $Folder | Out-Null
		$InputObj = [PSCustomObject]@{
			'cli-API_info'  = 'inetnum'
			'cli-API_input' = '8.8.8.8'
			ip              = '8.8.8.8'
			results         = @(
				[PSCustomObject]@{ '@category' = 'inetnum'; seen_date = '2026-01-01'; ip = '8.8.8.8' }
			)
		}

		Export-OnypheInfoToFile -tofolder $Folder -InputOnypheObject $InputObj

		$ResultFolder = Get-ChildItem -Path $Folder -Directory | Select-Object -First 1
		$ResultFolder | Should -Not -BeNullOrEmpty
		(Get-ChildItem -Path $ResultFolder.FullName -Filter '*_request_info.csv').Count | Should -Be 1
		(Get-ChildItem -Path $ResultFolder.FullName -Filter '*_inetnum.csv').Count | Should -Be 1
	}

	It 'uses the custom -csvdelimiter when writing the request_info.csv' {
		$Folder = Join-Path $TestDrive 'custom-delimiter'
		New-Item -ItemType Directory -Path $Folder | Out-Null
		$InputObj = [PSCustomObject]@{
			'cli-API_info'  = 'inetnum'
			'cli-API_input' = '8.8.8.8'
			ip              = '8.8.8.8'
			results         = @(
				[PSCustomObject]@{ '@category' = 'inetnum'; seen_date = '2026-01-01'; ip = '8.8.8.8' }
			)
		}

		Export-OnypheInfoToFile -tofolder $Folder -InputOnypheObject $InputObj -csvdelimiter ','

		$ResultFolder = Get-ChildItem -Path $Folder -Directory | Select-Object -First 1
		$InfoFile = Get-ChildItem -Path $ResultFolder.FullName -Filter '*_request_info.csv' | Select-Object -First 1
		(Get-Content -Path $InfoFile.FullName -TotalCount 1) | Should -Match ','
	}

	It 'calls Export-OnypheDataShot for a datashot-category result' {
		$Folder = Join-Path $TestDrive 'datashot-export'
		New-Item -ItemType Directory -Path $Folder | Out-Null
		$InputObj = [PSCustomObject]@{
			'cli-API_info'  = 'datashot'
			'cli-API_input' = '8.8.8.8'
			ip              = '8.8.8.8'
			results         = @(
				[PSCustomObject]@{ '@category' = 'datashot'; seen_date = '2026-01-01'; ip = '8.8.8.8' }
			)
		}

		Export-OnypheInfoToFile -tofolder $Folder -InputOnypheObject $InputObj

		Should -Invoke -ModuleName Use-Onyphe Export-OnypheDataShot -Times 1 -Exactly
	}

	It 'writes a separate content file per pastries entry' {
		$Folder = Join-Path $TestDrive 'pastries-export'
		New-Item -ItemType Directory -Path $Folder | Out-Null
		$InputObj = [PSCustomObject]@{
			'cli-API_info'  = 'pastries'
			'cli-API_input' = '8.8.8.8'
			ip              = '8.8.8.8'
			results         = @(
				[PSCustomObject]@{ '@category' = 'pastries'; seen_date = '2026-01-01'; ip = '8.8.8.8'; key = 'paste123'; content = 'leaked data here' }
			)
		}

		Export-OnypheInfoToFile -tofolder $Folder -InputOnypheObject $InputObj

		$ResultFolder = Get-ChildItem -Path $Folder -Directory | Select-Object -First 1
		(Get-ChildItem -Path $ResultFolder.FullName -Filter '*_pastries_paste123.txt').Count | Should -Be 1
	}
}
