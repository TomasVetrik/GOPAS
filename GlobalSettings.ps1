######################################################
#
#SCRIPT_NAME: GlobalSettings.ps1
#AUTHOR_NAME: Lukas Keicher
#DATE: 21.7.2014
#VERSION: 6.0
#DESCRIPTION: Skript slouzici pro obecne nastaveni OS
#
######################################################

#Definice promennych
$Temp="D:\Temp"

. D:\Functions.ps1

$Settings_applied = "C:\Users\$env:username\Documents\GlobalSettings.ps1"
$UserSettings = "$Temp\GlobalSettings.ps1"
#Nastaveni skryti error hlasek, pokud se standardnimu uzivateli nepodari zapsat do registru
$ErrorActionPreference = "SilentlyContinue"

$Executed = $false
if((Test-Path $Settings_applied))
{
	if((Compare-Object $(Get-Content $Settings_applied) $(Get-Content $UserSettings)).SideIndicator.Length -ne $null)
	{
		if((Compare-Object $(Get-Content $Settings_applied) $(Get-Content $UserSettings)).SideIndicator.Length -eq 0)
		{
			$Executed = $True
		}
	}
	elseif([io.file]::ReadAllText($UserSettings) -eq [io.file]::ReadAllText($Settings_applied))
	{
		$Executed = $True
	}		
}
if($Executed)
{
	#Rozhodovani, zda jsou nastaveni jiz aplikovana	
	write-host "Setting already applied..." -foregroundcolor green	
}
else 
{	
	#***************************************
	# Zapnutie Remote Desktop(Computer Properties)	
	netsh advfirewall firewall set rule group="Remote Desktop" new enable=Yes
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

	$Windows_version=wmic os get name
	$Logon="C:\Windows\System32\OOBE\info\Backgrounds\"
	$Test_LogonPath=Test-Path -path $Logon
	$ScreenSaver="C:\Program Files\Screensaver"
	$Test_ScreenSaverPath=Test-Path -path $ScreenSaver
	
	$Network=gwmi Win32_NetworkAdapterConfiguration | select DNSDomain
	#Vycisteni kose
	$Shell = New-Object -ComObject Shell.Application 
	$RecBin = $Shell.Namespace(0xA) 
	$RecBin.Items() | %{Remove-Item $_.Path -Recurse -Confirm:$false}

	#RepairGhostPubCert
	
	MuteSounds
	SetRunAsAdmin "D:\Temp\GDSClient\HONMSW_CLIENT.exe"
	#Nastavi v ovladacom panely zobrazenie na Large icons
	Set-ControlPanelViewToLargeIcons
	
	StandbyAndMonitorTimeout
	
	Set-WallPaper "$Temp\GOPAS_Background.jpg"

	#Rozhodovani, zda bude nastaveno pozadi na prihlasovaci obrazovce na zaklade verze operacniho systemu
	if (($Windows_version -like "*Windows 7*") -or ($Windows_version -like "*2008 R2*"))
	{
		Logon_background
	}
	else
	{
		No_Logon_background
	}

	#Rozhodovani, zda se jedna o serverovy operacni system a na zaklade zdetekovane verze, aplikovani nastaveni (IE ESC, zapnuti feature a roli)
	$Servers_OS="2008 R2", "2012", "2016"
	foreach ($Server_OS in $Servers_OS)
	{		
		if ($Windows_version -like "*$Server_OS*")
		{			
			write-host "Windows Server OS detected..."  -foregroundcolor green
			write-host "Turning IE ESC off..."  -foregroundcolor green
			IE_SEC_OFF
			write-host "Turning off Server Manager after startup..."  -foregroundcolor green
			Set-ItemProperty -Path "HKLM:\Software\Microsoft\ServerManager" -Name DoNotOpenServerManagerAtLogon -Value "1"
			write-host "Disabling Shutdown Even Tracker" -foregroundcolor green 			
			If (!(Test-Path -path $ShutDownEventTracker)) 
			{
				write-host "Shutdown Even Tracker registry path not exist..." -foregroundcolor Yellow
				write-host "Creating Shutdown Even Tracker registry path..." -foregroundcolor green
				New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" >> $null
			}
			Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Reliability" -Name ShutdownReasonOn -Value "0"
			write-host "Enabling feature Wireless-Networking..."  -foregroundcolor green
			if ($Windows_version -like "*2008 R2*")
			{
				Set-ItemProperty -Path "HKLM:\Software\Microsoft\ServerManager\Oobe" -Name DoNotOpenInitialConfigurationTasksAtLogon -Value "1"
				servermanagercmd -install Wireless-Networking >> $null
			}
			else
			{
				Add-WindowsFeature Wireless-Networking >> $null
			}
		}
	}	
	
	if($Windows_version -like "*Windows 10*") 
	{ 				
		#Kill-Service "wuauserv"
		Disable-Service "wuauserv"
	}

	#Nakopirovani screensaver	
	if ($Test_ScreenSaverPath -eq "true") 
	{
		write-host "Previous version of screensaver in $ScreenSaver detected..." -foregroundcolor Yellow
		write-host "Deleting previous version of screensaver..." -foregroundcolor green
		remove-item $ScreenSaver -force -recurse
		$SCRSVR_Path="C:\SCRSVR"
		$Test_SCRSVR_Path=Test-Path -Path $SCRSVR_Path
		if ($Test_SCRSVR_Path -eq "true")
		{
			 remove-item C:\SCRSVR -force -recurse
		}    
	} 
	else 
	{
		write-host "Previous version of screensaver in $ScreenSaver not detected..." -foregroundcolor Yellow
	}
	New-Item -ItemType directory -Path "C:\Program Files\Screensaver\" >> $null
	write-host "Copying new version of screensaver..." -foregroundcolor green
	Copy-Item "$Temp\Screensaver\*" "C:\Program Files\Screensaver\"
			
	#Povoleni RDP
	write-host "Enabling RDP..."  -foregroundcolor green
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name fDenyTSconnections -Value "0"

    #Vypnutie Automatickeho Instalovania Ovladacov z Windows Update
	write-host "Turn off automatic device driver update..."  -foregroundcolor green
	Set-ItemProperty -Path "HKLM:\Software\\Microsoft\Windows\CurrentVersion\DriverSearching" -Name SearchOrderConfig -Value "0"

	#Vypnuti firewallu
	write-host "Disabling firewall..."  -foregroundcolor green
	netsh advfirewall set allprofiles state off >> $null

	#GPO settings for all OS versions
	#################################
	write-host "Enabling Do not require CTRL+ALT+DELETE..." -foregroundcolor green
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system" -Name disablecad -Value "1"

	write-host "Disabling Limit local account use of blank passwords..." -foregroundcolor green
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name LimitBlankPasswordUse -Value "0"

	write-host "Enabling Allowing system to be shut down without having to log on..." -foregroundcolor green
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name ShutdownWithoutLogon -Value "1"

	#Nakopirovani ikonek (TC, WinRAR, WinZip) do C:\Windows\System32
	write-host "Copying icons for downloadable apps..." -foregroundcolor green
	Copy-Item "$Temp\Icons\*" "C:\Windows\System32\" -recurse

	#Nastaveni obrazku uzivatelskeho uctu a obrazku do vlastnosti pocitace
	Copy-Item "$Temp\OEM.bmp" "C:\Windows\OEM.bmp"
	if (($Windows_version -like "*Windows 7*") -or ($Windows_version -like "*2008 R2*"))
	{
		write-host "Setting user account picture..." -foregroundcolor green
		Remove-Item "C:\ProgramData\Microsoft\User Account Pictures\User.bmp"
		Copy-Item "$Temp\W7_User.bmp" "C:\ProgramData\Microsoft\User Account Pictures\User.bmp"
	}
	else
	{
		write-host "Setting user account picture..." -foregroundcolor green
		Remove-Item "C:\ProgramData\Microsoft\User Account Pictures\user.bmp"
		Remove-Item "C:\ProgramData\Microsoft\User Account Pictures\user.png"
		Remove-Item "C:\ProgramData\Microsoft\User Account Pictures\user-40.png"
		Remove-Item "C:\ProgramData\Microsoft\User Account Pictures\user-200.png"
		Copy-Item "$Temp\User-448.bmp" "C:\ProgramData\Microsoft\User Account Pictures\user.bmp"
		Copy-Item "$Temp\User-448.png" "C:\ProgramData\Microsoft\User Account Pictures\user.png"
		Copy-Item "$Temp\User-40.png" "C:\ProgramData\Microsoft\User Account Pictures\user-40.png"
		Copy-Item "$Temp\User-200.png" "C:\ProgramData\Microsoft\User Account Pictures\user-200.png"
	}

	#Nastaveni PowerOptions - High Performance
	write-host "Setting Power Scheme as High Performance..." -foregrou ndcolor green
	Powercfg /setactive "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" 2>null | Out-Null

	#Vytvoreni lokalniho servisniho uctu pro potreby PSRemoting
	$OBJ = net user GOPAS_Service 'Pa$$w0rd' /add 2>null | Out-Null 
	$OBJ = net localgroup administrators GOPAS_Service /add 2>null | Out-Null

	#Rozhodovani, zda se v registru nachazi definice pro skryti uctu GOPAS_Service z nabidky uctu na prihlasovaci obrazovce
	$HiddenAccount="HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts"
	If (!(Test-Path -path $HiddenAccount))
	{
		write-host "Special accounts registry path not exist..." -foregroundcolor Yellow
		write-host "Creating Special accounts registry path..." -foregroundcolor green
		New-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts" >> $null
		New-Item -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" >> $null
		New-ItemProperty -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList" -Name GOPAS_Service -Value 0 -PropertyType "dword" >> $null 
	}
	else
	{
		write-host "Special accounts registry path already exist..." -foregroundcolor Yellow
	} 

	#Nastaveni vsech sitovych profilu na hodnotu Private
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\*\" -Name "Category" -Value 1
	restart-Service -Name NlaSvc -Force
	Start-Sleep -Seconds 10

	#Rozhodovani, zde se v registru nachazi definice pro vzdaleny pristup, zapnuti a konfigurace sluzby winrm
	$TokenPolicy="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system\"
	$TokenPolicy_Value=(Get-ItemProperty $TokenPolicy).LocalAccountTokenFilterPolicy
	If ($TokenPolicy_Value -eq $null)
	{
		write-host "Token Policy registry value not exist..." -foregroundcolor Yellow
		write-host "Creating Token Policy registry value..." -foregroundcolor green
		New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system" -Name "LocalAccountTokenFilterPolicy" -Value 1 -PropertyType "dword" >> $null
	}
	else
	{
		write-host "Token Policy registry value already exist..." -foregroundcolor Yellow
		Write-Host "Setting Token Policy registry value..." -ForegroundColor Green
		Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\policies\system" -Name "LocalAccountTokenFilterPolicy" -Value 1
	}

	#Nastaveni obrazu na rezim Clone
	$MacAddress=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).MACAddress
	$Lektor = import-csv "$Temp\Database.csv" | where {(($_.mac1 -eq $MacAddress) -or ($_.mac2 -eq $MacAddress)) -and ($_.OFFICE -like "LEKTOR*")}
	if([bool]$Lektor -eq $true)
	{
		write-host "LEKTOR PC detected setting display to clone" -foregroundcolor green
		displayswitch.exe /clone
	}
	else
	{
		write-host "STUDENT PC detected leaving display settings alone" -foregroundcolor green
	}	Start-Service WinRM | Out-Null	Set-Service WinRM -StartupType Automatic| Out-Null	winrm create winrm/config/Listener?Address=*+Transport=HTTP 2>null | Out-Null
	
	#Vytvoreni kontrolni souboru, zda jsou nastaveni aplikovana
	$TempContent = Get-Content $UserSettings
	if(Test-Path $Settings_applied)
	{
		Remove-Item $Settings_applied -force >> $null
	}	
	Add-Content $Settings_applied $TempContent	
}