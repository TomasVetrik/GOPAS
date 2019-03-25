. D:\Functions.ps1

Function SetDisplayDuplicate-Registry
{
	$Monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorBasicDisplayParams

	$MonitorsID = @()
	Write-Host "Getting Monitors ID..." -ForegroundColor Yellow -NoNewLine
	foreach($Monitor in $Monitors)
	{
		If($Monitor.InstanceName -like "*\*")
		{
			$MonitorID = $Monitor.InstanceName.Split('\')[1]
			$MonitorsID += $MonitorID
		}
	}
	Write-Host "Success" -ForegroundColor Green

	if($MonitorsID.Count -eq 2)
	{
		$MonitorFirst = $MonitorsID[0]
		$MonitorSecond = $MonitorsID[1]		
		$DateInHex = [Convert]::ToString([Math]::Round((Get-Date).ToFileTime()),16)
		$registryFolders = Get-ChildItem "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Configuration"    
		Foreach($registryFolder in $registryFolders)
		{                        
			if($registryFolder.PSChildName -like "$MonitorFirst*+$MonitorSecond*" -or $registryFolder.PSChildName -like "$MonitorSecond*+$MonitorFirst*")
			{				
				$RegistryChildName = $registryFolder.PSChildName            
				Write-Host "Removing Registry Folder..." -ForegroundColor Yellow -NoNewLine
				Remove-Item -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Configuration\$RegistryChildName" -Force -Recurse >> $null
				Write-Host "Success" -ForegroundColor Green			
			}
		}
		$registryFolders = Get-ChildItem "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity"    
		Foreach($registryFolder in $registryFolders)
		{
			if($registryFolder.PSChildName -like "$MonitorFirst*^$MonitorSecond*" -or $registryFolder.PSChildName -like "$MonitorSecond*^$MonitorFirst*")
			{
				$RegistryChildName = $registryFolder.PSChildName 
				$RegistryChildNameSplitter = $RegistryChildName.Split('^')
				$ID = $RegistryChildNameSplitter[0]+"*"+$RegistryChildNameSplitter[1]                                                      
				$itemProperty = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" -Name "eXtend" -ErrorAction SilentlyContinue
				if(!($itemProperty -eq $null))
				{
					$ID = $itemProperty.eXtend
					Write-Host "Removing Registry Item extend..." -ForegroundColor Yellow -NoNewLine
					Remove-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" -Name "eXtend" -ErrorAction SilentlyContinue
					Write-Host "Success" -ForegroundColor Green	
					$ID = $ID.Replace('+','*').Substring(0,$ID.Length-1)
				}            
				if(!(Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" "Clone" -ErrorAction SilentlyContinue))                                
				{
					Write-Host "Creating Registry Item Clone..." -ForegroundColor Yellow -NoNewLine
					New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" -Name "Clone" -Value $ID -Force >> $null                  
					Write-Host "Success" -ForegroundColor Green	
				} 
				if(!(Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" "Recent" -ErrorAction SilentlyContinue))                                
				{
					Write-Host "Creating Registry Item Recent..." -ForegroundColor Yellow -NoNewLine
					New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" -Name "Recent" -Value $ID -Force >> $null
					Write-Host "Success" -ForegroundColor Green	
				}             
				else
				{
					Write-Host "Setting Registry Item Recent..." -ForegroundColor Yellow -NoNewLine
					Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Connectivity\$RegistryChildName" -Name "Recent" -Value $ID -Force >> $null
					Write-Host "Success" -ForegroundColor Green	
				}
				$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
				$utf8 = new-object -TypeName System.Text.UTF8Encoding
				$hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($ID)))
				$hash = $hash.Replace('-','')              
				$ID_HASH ="$ID^$hash"
				if(!(Test-Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Configuration\$ID_HASH"))
				{
					if(Test-Path D:\Temp\SetDisplayDuplicate_Template.reg)
					{						
						$ContentOfRegistry = (Get-Content -Path D:\Temp\SetDisplayDuplicate_Template.reg).Replace("ID_WITH_HASH", $ID_HASH).Replace("ID_WITHOUT_HASH", $ID)
						Set-Content -Path D:\Temp\SetDisplayDuplicate.reg -Value $ContentOfRegistry
						Write-Host "Importing registry..." -ForegroundColor Yellow -NoNewLine
						& reg import D:\Temp\SetDisplayDuplicate.reg 2>null | Out-Null
						Write-Host "Success" -ForegroundColor Green
						Write-Host "Setting Registry Item Timestamp..." -ForegroundColor Yellow -NoNewLine
						Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\GraphicsDrivers\Configuration\$ID_HASH" -Name "TimeStamp" -Value "0x$DateInHex" >> $null
						Write-Host "Success" -ForegroundColor Green	
					}
				}
			}
		}
	}
}
if(!(Test-Path D:\temp\SetDisplayDuplicate.txt))
{
	SetDisplayDuplicate-Registry
	New-Item -Path D:\temp\SetDisplayDuplicate.txt -ItemType "file" -Value "DONE" >> $null
}