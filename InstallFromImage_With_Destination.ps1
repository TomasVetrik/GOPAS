. D:\Temp\Functions.ps1

$MacAddress=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).MACAddress

$ComputerFileName = GetComputerNameFromServerByMac -Mac $MacAddress

$TempDrive = "Z:\PostInstallers"

$Bit_version=(Get-WMIObject win32_operatingsystem).osarchitecture

if ($Bit_version -like "*32*") 
{
	$Bit_version="x86"
} 
else 
{
	$Bit_version="x64"
}
$SilverLightName = "D:\Temp\Silverlight_"+$Bit_version+".exe"
Run $SilverLightName "/q"

Write-Host "Detected MacAddress $MacAddress" -ForegroundColor Green
#Existencia suboru, z ktoreho dostava udaje co ma na pocitac nainstalovat. "Ucebna3.txt"
if(Test-Path $ComputerFileName)
{
	Write-Host "Detected Computer Config FileName $ComputerFileName" -ForegroundColor Green
	#Zisti zo suboru co ma nainstalovat na ucebnu
	$lines = Get-Content $ComputerFileName

	#jeden riadok znamena nainstalovat jednu vec, takze prejde vsetky riadky, ktore su v subore
	foreach ($line in $lines) 
	{
		#osetrenie prazdneho suboru a prazdnych riadkov
		if ($line.Length -gt 0) 
		{
			if($line -like "Post Install||*")
			{
				$InstallationsSplitter = $line.Split('||') | Where { $_.length -gt 0 } 
				if($InstallationsSplitter[1] -like '*,*')
				{
					$Installations = $InstallationsSplitter[1].Split(',') | Where { $_.length -gt 0 } 
					foreach($Installation in $Installations)
					{					
						if($Installation.Length -gt 0)
						{
							if($Installation.Contains("*"))
							{
								$Installation = $Installation.Replace("*","")
								$Installation = $Installation.Substring(0, $Installation.Length -1)
							}
							#Zisti ci existuje priecinok s instalaciou
							if(Test-Path $TempDrive\$Installation)
							{	
								Write-Host "Detected installation $Installation" -ForegroundColor Green
								if(Test-Path $TempDrive\$Installation\CopyDestination.txt)
								{						
									#****************************
									#Dostane cestu, kde ma subory nakopirovat
									$Destination = Get-Content $TempDrive\$Installation\CopyDestination.txt					
									if(($Destination.length -le 3) -or ($Destination[$Destination.length-1] -eq '\'))
									{
										$Destination = $Destination.Substring(0,$Destination.length-1)
									}
									if(Test-Path $Destination\$Installation)
									{
										Write-Host "Deleting old files" -ForegroundColor Yellow
										Remove-Item $Destination -Recurse -Force >> $null
									}
									Write-Host "Copy files to $Destination" -ForegroundColor Yellow
									Copy-Item -Path $TempDrive\$Installation\ -Destination $Destination\ -Recurse -Force
									#Spusti batak ktory to nainsatluje	                    			
									$msbuild = $Destination+"\Start.bat"
								}
								else
								{
									if(Test-Path D:\Temp\PostInstallers\$Installation)
									{
										Write-Host "Deleting old files" -ForegroundColor Yellow
										Remove-Item D:\Temp\PostInstallers\$Installation -Force -Recurse >> $null
									}
									#Nakopiruje aktualny priecinok s instalaciou
									Write-Host "Copy files to Temp" -ForegroundColor Yellow
									Copy-Item -Path $TempDrive\$Installation -Destination D:\Temp\PostInstallers\$Installation -Recurse -Force
								
									#Spusti batak ktory to nainsatluje				
									$msbuild = "D:\Temp\PostInstallers\$Installation\Start.bat"
								}
								Write-Host "Run the installation $Installation" -ForegroundColor Yellow
								Start-Process -FilePath $msbuild -Wait -Verb RunAs
							}
							else
							{
								#Ak sa nepodarilo najst dany priecinok s instalaciou
								$A = Get-Date							
								Write-Host "`n$A - $env:ComputerName - Neznama instalacia $Installation" -ForegroundColor Red
							}
						}
					}
				}				
			}
		}
	}
}