######################################################
#
#SCRIPT_NAME: Office_rearm.ps1
#AUTHOR_NAME: Lukas Keicher
#DATE: 17.2.2014
#UPDATE: 12.4.2017 By Tomas Vetrik
#VERSION: 3.0
#DESCRIPTION: Skript slouzici pro rearm a instalovanie KBs zdetekovane verze Office (funguje pro Office 2010, 2013 a 2016)
#
######################################################

#Definice promennych, detekce verze Office
$Temp="D:\Temp"
. $Temp\Functions.ps1

function Install_Office_KBs($Path = "")
{
	write-host "Installing Office KBs from $Path" -foreground Yellow
	$Network=gwmi Win32_NetworkAdapterConfiguration | select DNSDomain
	$Path_Temp = "D:\Temp\Office_KBs"
	if (($Network -like "*gopas*") -or ($Network -like "*skola*")) 
	{
		DetectMapNetworkShares
		if(Test-Path $Path)
		{
			if(Test-Path $Path_Temp)
			{
				Remove-Item $Path_Temp -Force -Recurse
			}
			write-host "Downloading $Path" -foreground Yellow
			Copy-Item $Path $Path_Temp -Force -Recurse
		}
	}
	if(Test-Path $Path_Temp)
	{
		$Path = "$Path_Temp\*.exe" 
		$KBs_Files = Get-ChildItem $Path -Recurse
		foreach($KBs_File_Path in $KBs_Files)
		{					
			$ArgList = "/quiet /norestart"
			Run $KBs_File_Path $ArgList
		}	
	}	
}

#Rearm Office 2010
#-----------------
$ProgramFiles="Program Files"
$Test_Office2010_Path=Test-Path -path "C:\$ProgramFiles\Common Files\Microsoft Shared\OfficeSoftwareProtectionPlatform\ospprearm.exe"
if($Test_Office2010_Path -eq $false)
{
	$ProgramFiles="Program Files (x86)"
	$Test_Office2010_Path=Test-Path -path "C:\$ProgramFiles\Common Files\Microsoft Shared\OfficeSoftwareProtectionPlatform\ospprearm.exe"
}
if($Test_Office2010_Path -eq "$true")
{
	write-host "Office 2010 detected..." -foregroundcolor green
	$Bit_version = Get-ItemPropertyValue "HKLM:\Software\Microsoft\Office\14.0\Outlook" -Name "Bitness"
	if ($Bit_version -eq "x64") 
	{					
		$Office_KBs_Path = "Z:\Office_KBs\x64\2010\"
	} 
	else 
	{
		$Office_KBs_Path = "Z:\Office_KBs\x86\2010\"
	}
	Install_Office_KBs -Path $Office_KBs_Path
	write-host "Rearming Office installation..." -foregroundcolor green	
	$OBJ = Start-Process -filepath "C:\$ProgramFiles\Common Files\Microsoft Shared\OfficeSoftwareProtectionPlatform\ospprearm.exe" -wait -verb runas
}

#Rearm Office 2013
#-----------------
$ProgramFiles="Program Files"
$Test_Office2013_Path=Test-Path -path "C:\$ProgramFiles\Microsoft Office\Office15\OSPPREARM.EXE"
if($Test_Office2013_Path -eq $false)
{
	$ProgramFiles="Program Files (x86)"	
	$Test_Office2013_Path=Test-Path -path "C:\$ProgramFiles\Microsoft Office\Office15\OSPPREARM.EXE"	
}
if($Test_Office2013_Path -eq "$true")
{
	write-host "Office 2013 detected..." -foregroundcolor green	
    $Bit_version = Get-ItemPropertyValue "HKLM:\Software\Microsoft\Office\15.0\Outlook" -Name "Bitness"
	if ($Bit_version -eq "x64") 
	{					
		$Office_KBs_Path = "Z:\Office_KBs\x64\2013\"
	} 
	else 
	{
		$Office_KBs_Path = "Z:\Office_KBs\x86\2013\"
	}
	Install_Office_KBs -Path $Office_KBs_Path
	
	write-host "Rearming Office installation..." -foregroundcolor green
	Start-Process -filepath "C:\$ProgramFiles\Microsoft Office\Office15\ospprearm.exe" -wait	
}

#Rearm Office 2016
#-----------------
$ProgramFiles="Program Files"
$Test_Office2016_Path=Test-Path -path "C:\$ProgramFiles\Microsoft Office\Office16\OSPPREARM.EXE"
if($Test_Office2016_Path -eq $false)
{
	$ProgramFiles="Program Files (x86)"	
	$Test_Office2016_Path=Test-Path -path "C:\$ProgramFiles\Microsoft Office\Office16\OSPPREARM.EXE"
}
if($Test_Office2016_Path -eq "$true")
{
	write-host "Office 2016 detected..." -foregroundcolor green	
    $Bit_version = Get-ItemPropertyValue "HKLM:\Software\Microsoft\Office\16.0\Outlook" -Name "Bitness"
	if ($Bit_version -eq "x64") 
	{					
		$Office_KBs_Path = "Z:\Office_KBs\x64\2016\"
	} 
	else 
	{
		$Office_KBs_Path = "Z:\Office_KBs\x86\2016\"
	}

	Install_Office_KBs -Path $Office_KBs_Path	
	write-host "Rearming Office installation..." -foregroundcolor green
	Start-Process -filepath "C:\$ProgramFiles\Microsoft Office\Office16\ospprearm.exe" -wait
	sleep -s 5
	Start-Process -filepath "C:\$ProgramFiles\Microsoft Office\Office16\ospprearm.exe" -wait	
}
