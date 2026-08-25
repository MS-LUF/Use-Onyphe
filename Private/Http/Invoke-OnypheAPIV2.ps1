	Function Invoke-OnypheAPIV2 {
	[cmdletbinding()]
	Param (
		  [parameter(Mandatory=$true)]
		  [ValidateNotNullOrEmpty()]
			  [string[]]$request,
		  [parameter(Mandatory=$false)]
		  [ValidateNotNullOrEmpty()]
			  [string[]]$data,
		  [parameter(Mandatory=$false)]
		  [ValidateNotNullOrEmpty()]
			  [string]$file,
		  [parameter(Mandatory=$false)]
		  [Validateset("GET","POST")]
			  [string]$Method = "GET",
		  [parameter(Mandatory=$true)]
		  [ValidateNotNullOrEmpty()]
			  [string[]]$APIInfo,
		  [parameter(Mandatory=$true)]
		  [ValidateNotNullOrEmpty()]
			  [string[]]$APIInput,
		  [parameter(Mandatory=$true)]
			  [Bool]$APIKeyrequired,
		  [parameter(mandatory=$false)]
		  [ValidateNotNullOrEmpty()]
		  	  [hashtable]$FuncInput,
		  [parameter(Mandatory=$false)]
		  [ValidateNotNullOrEmpty()]
		  	  [string]$QueryValue,
		  [parameter(Mandatory=$false)]
		  [ValidateScript({$_ -match "^((?!0)\d+)$"})]
			  [string[]]$page,
		  [parameter(Mandatory=$false)]
		  [ValidateRange(1,10000)]
			  [int]$size,
		  [parameter(Mandatory=$false)]
			  [switch]$TrackQuery,
		  [parameter(Mandatory=$false)]
			  [switch]$Calculated,
		  [parameter(Mandatory=$false)]
			  [switch]$UseBetaFeatures,
		  [parameter(Mandatory=$false)]
			  [switch]$Stream,
		  [parameter(Mandatory=$false)]
		  	  [string]$OutFile,
		  [parameter(Mandatory=$false)]
		  [ValidateRange(1,[int]::MaxValue)]
			  [int]$TimeoutSec = 100
	)
	Process {
	  if ($UseBetaFeatures) {
		  $onypheurl = "https://test.onyphe.io/api/"
		  write-verbose -message "using beta Onyphe service - https://test.onyphe.io"
	  } else {
		  $onypheurl = "https://www.onyphe.io/api/"
		  write-verbose -message "using production Onyphe service - https://www.onyphe.io"
	  }
	  $DateRequest = get-date
	  if (($APIKeyrequired)-and(!$global:OnypheAPIKey)) {
		  write-verbose -message "incorrect parameter - Please provide an APIKey with -APIKEY parameter"
		  throw "Please provide an APIKey with -APIKEY parameter"
	  }
	  try {
		  $CertCallbackOverridden = $false
		  $OriginalCertCallback = $null
		  $fullonypheurl = "$($onypheurl)$($request)"
		  $queryStringParams = @()
		  if ($QueryValue) { $queryStringParams += "q=$([System.Uri]::EscapeDataString($QueryValue))" }
		  if ($page) { $queryStringParams += "page=$($page)" }
		  if ($size) { $queryStringParams += "size=$($size)" }
		  if ($TrackQuery) { $queryStringParams += "trackquery=true" }
		  if ($Calculated) { $queryStringParams += "calculated=true" }
		  if ($queryStringParams.Count -gt 0) {
			  $fullonypheurl = "$($fullonypheurl)?$($queryStringParams -join '&')"
		  }
		  if ($global:OnypheProxyParams) {
			  $params = $global:OnypheProxyParams.clone()
			  If (!$params.UseBasicParsing){
				  $params.add('UseBasicParsing', $true)
			  }
			  If (!$params.URI) {
				  $params.add('URI', "$($fullonypheurl)")
			  } Else {
				  $params['URI'] = "$($fullonypheurl)"
			  }
		  } Else {
			  $params = @{}
			  $params.add('UseBasicParsing', $true)
			  $params.add('URI', "$($fullonypheurl)")
		  }
		  If (!$params.TimeoutSec) {
			  $params.add('TimeoutSec', $TimeoutSec)
		  }
		  if ($UseBetaFeatures) {
			  if ($host.Version.Major -lt 6) {
				  try {
				  if (-not ([System.Management.Automation.PSTypeName]'ServerCertificateValidationCallback').Type) {
					  $certCallback = @"
							  using System;
							  using System.Net;
							  using System.Net.Security;
							  using System.Security.Cryptography.X509Certificates;
							  public class ServerCertificateValidationCallback
							  {
									  public static void Ignore()
									  {
											  if(ServicePointManager.ServerCertificateValidationCallback ==null)
											  {
													  ServicePointManager.ServerCertificateValidationCallback +=
															  delegate
															  (
																	  Object obj,
																	  X509Certificate certificate,
																	  X509Chain chain,
																	  SslPolicyErrors errors
															  )
															  {
																	  return true;
															  };
											  }
									  }
							  }
"@
						  Add-Type $certCallback
				  }
				  $OriginalCertCallback = [System.Net.ServicePointManager]::ServerCertificateValidationCallback
				  [ServerCertificateValidationCallback]::Ignore()
				  $CertCallbackOverridden = $true
				  } catch {
					  throw "impossible to add a new type, check your PowerShell Constrained Language settings or run PowerShell as Admin"
				  }
			  } else {
				  $params.add('SkipCertificateCheck', $true)
			  }
		  }
		  if ($data) {
			  $params.add('Method','Post')
			  $params.add('Body', $data)
			  $params.add('ContentType', 'application/json')
		  }
		  if ($file) {
			$params.add('Method','Post')
			$params.add('Infile', $file)
			$params.add('ContentType', 'application/json')
		  }
		  if (($Method -eq "POST") -and !$params.Method) {
			  $params.add('Method','Post')
		  }
		  if ($APIKeyrequired) {
			  $params.add('Headers', @{'Authorization' = 'apikey {0}' -f $global:OnypheAPIKey})
		  }
		  if ($Stream -and $OutFile) {
			$params.add('OutFile', $OutFile)
		  }
		  if ($params.Headers) {
			  $redactedHeaders = $params.Headers.Clone()
			  if ($redactedHeaders.ContainsKey('Authorization')) {
				  $redactedHeaders['Authorization'] = 'apikey ***redacted***'
			  }
			  write-verbose -message "Request Headers : $($redactedHeaders | out-string)"
		  } else {
			  write-verbose -message "Request Headers : none"
		  }
		  $onypheresult = invoke-webrequest @params
	  } catch {
			  write-verbose -message "Not able to use onyphe online service - KO"
			  write-verbose -message "Error Type: $($_.Exception.GetType().FullName)"
			  write-verbose -message "Error Message: $($_.Exception.Message)"
			  write-verbose -message "HTTP error code:$($_.Exception.Response.StatusCode.Value__)"
			  write-verbose -message "HTTP error message:$($_.Exception.Response.StatusDescription)"
			  $errorvalue = $null
			  try {
				  if ($_.ErrorDetails.Message) {
					  $errorvalue = $_.ErrorDetails.Message | Convertfrom-Json
				  } elseif (get-member -InputObject $_.Exception.Response -MemberType Method | Where-Object {$_.name -eq "GetResponseStream"}){
					$result = $_.Exception.Response.GetResponseStream()
					$reader = New-Object System.IO.StreamReader($result)
					$reader.BaseStream.Position = 0
					$httpbody = $reader.ReadToEnd()
					$errorvalue = $httpbody | Convertfrom-Json
				  }
			  } catch {
				  $errorvalue = $null
			  }
			  if (-not $errorvalue) {
				  $errorvalue = [PSCustomObject]@{
					  Count = 0
					  error = ""
					  myip = 0
					  results = ''
					  'cli-error_results' = "$($_.Exception.GetType().FullName) - $($_.Exception.Message) : $($onypheresult.Content)"
					  status = "ko"
					  took = 0
					  total = 0
				  }
			  }
	  } finally {
		  if ($CertCallbackOverridden) {
			  [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $OriginalCertCallback
		  }
	  }
	  if ((-not $errorvalue) -and $onypheresult.Content) {
			write-verbose -message "Response Headers : $($onypheresult.Headers | out-string)"
			write-verbose -message "Web Content : $($onypheresult.Content)"
			$reqresult = $onypheresult.Content
	   } else {
		$reqresult = $null
	   }
	   if ($errorvalue) {
			  $errorvalue.PSObject.TypeNames.Insert(0,"PSOnyphe")
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_info' -Value $APIInfo
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_input' -Value $APIInput
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-API_version' -Value "2"
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-key_required' -Value $APIKeyrequired
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-Request_Date' -Value $DateRequest
			  $errorvalue | add-member -MemberType NoteProperty -Name 'cli-func_input' -value $FuncInput
			  $defaultDisplaySet = $errorvalue.psobject.properties.name | Where-Object {$_ -notlike "cli-*"}
			  $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet",[string[]]$defaultDisplaySet)
			  $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
			  $errorvalue | Add-Member MemberSet PSStandardMembers $PSStandardMembers
			  $errorvalue
		} elseif ($reqresult) {
				$tempobj = $reqresult | Convertfrom-Json
				$tempobj.PSObject.TypeNames.Insert(0,"PSOnyphe")
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-API_info' -Value $APIInfo
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-API_input' -Value $APIInput
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-API_version' -Value "2"
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-key_required' -Value $APIKeyrequired
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-Request_Date' -Value $DateRequest
				$tempobj | add-member -MemberType NoteProperty -Name 'cli-func_input' -value $FuncInput
				$defaultDisplaySet = $tempobj.psobject.properties.name | Where-Object {$_ -notlike "cli-*"}
				$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet",[string[]]$defaultDisplaySet)
				$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
				$tempobj | Add-Member MemberSet PSStandardMembers $PSStandardMembers
				if ($size -and ($null -ne $tempobj.count) -and ($null -ne $tempobj.total) -and ($tempobj.count -lt $size) -and ($tempobj.total -gt $tempobj.count)) {
					Write-Warning -Message "Onyphe returned $($tempobj.count) result(s) for this page, fewer than the requested -Size $($size) - this account/subscription's real per-page ceiling is lower than what was requested (the API silently falls back to its default page size instead of erroring). Use -Page to retrieve additional results rather than relying on a larger -Size."
				}
				$tempobj
		}
	  }
	}
