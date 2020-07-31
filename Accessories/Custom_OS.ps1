######################################################
#
#SCRIPT_NAME: Custom_OS.ps1
#AUTHOR_NAME: Lukas Keicher
#DATE: 25.2.2014
#VERSION: 4.0
#DESCRIPTION: Skript provadejici prislusna nastaveni na zaklade prazske pobocky
#
######################################################

#Definice promennych
$Temp="D:\Temp"

$Test_TempPath=Test-Path -path $Temp
$Network=gwmi Win32_NetworkAdapterConfiguration | select DNSDomain
if(Test-Path D:\Functions.ps1)
{
	. D:\Functions.ps1
	# Prida ovladace pokial sa nenachadza na gopasej sieti
	if (!(($Network -like "*gopas*") -or ($Network -like "*skola*"))) 
	{
		Drivers-Add
	}
}

#Rozhodovani, zda se pocitac nachazi na siti GOPAS - pokud ano, smaze predchozi verze skriptu a stahne si nove verze
if (($Network -like "*gopas*") -or ($Network -like "*skola*")) 
{
	write-host "GOPAS network detected..." -foregroundcolor green
	
	Copy-Item "Z:\Accessories\Functions.ps1" "D:\"
	
	. D:\Functions.ps1
	
	if ($Test_TempPath -eq "true") 
	{		
		write-host "Previous versions of scripts in $Temp detected..." -foregroundcolor Yellow
		write-host "Deleting previous scripts from $Temp" -foregroundcolor green
		
		Kill-Process "*GDS*"
		Kill-Service "GDS_Service"
		Kill-Service "GDSClient_Service"
		Kill-Process "*HONMSW_CLIENT*"
		Kill-Process "*GDSAgent*"
		Kill-Process "armsvc*"
		Kill-Process "AdobeARM*"
		Kill-Service "AdobeARMservice"
		Disable-Service "AdobeARMservice"
		Kill-Process "Ank_Service"
		Kill-Process "AnK"
		Kill-Process "ePrezence"
		Kill-Process "OfficeClickToRun"		
		
		Start-Sleep 5
		
		$TempNoDrivers = get-childitem D:\Temp -exclude "Drivers"
		remove-item $TempNoDrivers -force -recurse >> $null
	} 
	else 
	{
		write-host "Previous versions of scripts in $Temp not detected..." -foregroundcolor Yellow
	}
	$errorActionPreference = "SilentlyContinue"	
	
	write-host "Copying new version of scripts..." -foregroundcolor green	
	get-childitem "z:\Custom_OS" | % {copy-item $_.FullName $Temp -force -recurse}
	if(!(Test-Path "$Temp\Functions.ps1"))
	{		
		#Spusteni skriptu Custom_OS.ps1
		write-host "Executing Custom_OS.ps1..." -foregroundcolor green
		. "D:\Custom_OS.ps1"
	}
}
else
{
	write-host "No GOPAS network detected..." -foregroundcolor Yellow
	write-host "Applying settings based on latest branch detected..." -foregroundcolor green
}

#Vypise podrobnosti o pocitaci
Write-Header

Proxy-OFF

#Import certifikatu
AddCert

#Aplikovani nastaveni pro prazskou pobocku (Mapovani sitoveho disku, instalace ovladacu, prejmenovani pocitace, nastaveni powerscheme)
write-host ""
write-host "Executing $Temp\Drivers.ps1..." -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
. "$Temp\Drivers.ps1" -verb runas
write-host ""
write-host "Executing $Temp\Rename.ps1..." -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
. "$Temp\Rename.ps1" -verb runas
Write-Host ""
Set-WOL
write-host ""
write-host "Rearming Office and installing KBs..." -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
. "$Temp\Office_rearm.ps1" -verb runas
write-host ""
write-host "Setting Global Settings..." -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
. "$Temp\GlobalSettings.ps1" -verb runas
write-host ""
write-host "Setting User Settings..." -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
. "$Temp\UserSettings.ps1" -verb runas
write-host ""
write-host "Starting GDS Postinstall phase..." -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run -Name "Prepare_UserSettings" -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell -windowstyle hidden $Temp\Prepare_UserSettings.ps1"
write-host "Registering Gopas Client Service" -foregroundcolor Yellow
. "$Temp\GDSClient\GDSClient_Create_Service.ps1"

Write-Host ""
#Odpojeni sitovych disku, ktere v ramci procesu pouzivany, odpojeni registru defaultniho profilu, vypnuti automatickeho prihlasovani
write-host "Cleaning footprints" -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
write-host "Unloading Default profile registry hive..." -foregroundcolor green
reg unload HKU\Default 2>null | Out-Null

CheckNotebookPassword
ChangeBootLink
Set-ePrezence

Write-Host ""
Write-host "Upgrade Autologon" -ForegroundColor $Global:UserInputColor -BackgroundColor $Global:bgColor 
Save-Current-Logon-User
Remove-Autologon-Registry
#Set-Password-By-UserName
Set-AutologonAutomatic
Set-Autologon 0

#Rozhodovani, zde se v registru nachazi definice pro AutologonCount
$AutoLogonCount="HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\"
$AutoLogonCount_Value=(Get-ItemProperty $AutologonCount).AutoLogonCount
If ($AutoLogonCount_Value -eq $null)
{
	write-host "AutologonCount registry value not exist..." -foregroundcolor Yellow
}
else
{
	write-host "AutologonCount registry value exist..." -foregroundcolor green
	write-host "Removing AutologonCount registry value..." -foregroundcolor green
	Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount
}

Copy-Item D:\Temp\Exchange.bat C:\Windows\System32\Exchange.bat -Force
Copy-Item D:\Temp\Exchange.bat C:\Windows\System32\Outlook.bat -Force

$Windows_version=wmic os get name
if (($Windows_version -like "*Windows 8*") -or ($Windows_version -like "*Windows 10*"))
{
	net user Profile /active:no 2>null | Out-Null
}

$ServerName = Get-ServerName

Write-Host ""
Write-host "Running Custom Scripts for Branch $ServerName" -ForegroundColor $Global:UserInputColor -BackgroundColor $Global:bgColor 
switch -wildcard ($ServerName) 
{ 
    "PrahaImage" 
	{
		write-host "Run Custom Scripts for Praha" -foregroundcolor Yellow
		. "D:\Temp\Custom_Praha.ps1"
	}
 	"BrnoImage" 
	{
		write-host "Run Custom Scripts for Brno" -foregroundcolor Yellow
		. "D:\Temp\Custom_Brno.ps1"
	}
    "BlavaImage" 
	{
		write-host "Run Custom Scripts for Bratislava" -foregroundcolor Yellow
		. "D:\Temp\Custom_Blava.ps1"
	}	
    default {}
}

write-host ""

write-host "Resetting time..." -foregroundcolor green
ResetTime

$wshell = new-object -comobject wscript.shell -erroraction stop		
if (Test-Path -path $Temp\Password.txt) {Remove-Item $Temp\Password.txt -Force}	
bcdedit /timeout 10 | Out-Null

if (($Network -like "*gopas*") -or ($Network -like "*skola*")) 
{	
	TimeSynch -ServerName $ServerName	
	write-host ""
	write-host "Installing PostInstalls" -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
	. "$Temp\InstallFromImage_With_Destination.ps1"
}
Kill-Process "armsvc*"
Kill-Process "AdobeARM*"
Kill-Service "AdobeARMservice"
Disable-Service "AdobeARMservice"
Get-ScheduledTask | where { $_.TaskName -like "Adobe*" } | Disable-ScheduledTask
#SetDisplayDuplicateForLector
DeleteBadBCDRecord
RemoveFeature 'IIS-WebServerRole'
Restart