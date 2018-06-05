######################################################
#
#SCRIPT_NAME: UserSettings.ps1
#AUTHOR_NAME: Lukas Keicher
#DATE: 21.7.2014
#VERSION: 6.0
#DESCRIPTION: Skript slouzici pro nastaveni prostredi aktualne prihlaseneho uzivatele
#
######################################################

#Definice promennych
$Temp="D:\Temp"

. $Temp\Functions.ps1

$Settings_applied = "C:\Users\$env:username\Documents\UserSettings.ps1"
$UserSettings = "$Temp\UserSettings.ps1"
#Nastaveni skryti error hlasek, pokud se standardnimu uzivateli nepodari zapsat do registru
$ErrorActionPreference = "SilentlyContinue"
$Executed = $False

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
	ChangeBootLink
	
	# Vytvara Tabulky pre totalcommander
	if($env:computername -like "Lektor*")
	{
		$N = GetNumber_ClassRoom
		WriteToTab $N
		
		write-host "Created TotalCommander Tabs" -foreground green
	}

	$gateway=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).DefaultIPGateway
	write-host "Gateway $gateway detected..." -foregroundcolor green

	switch -wildcard ($gateway) 
	{ 
		"10.1.0.1" {Proxy-Praha}
		"10.2.0.1" {Proxy-Praha} 
		default {Proxy-Off}
	}

	$Windows_version=wmic os get name

	#Nakopirovani zastupcu na programy ke stazeni (TC, WinRAR, WinZip) na plochu a jejich ikonek do C:\Windows\System32
	write-host "Copying icons for downloadable apps..." -foregroundcolor green
	Copy-Item "$Temp\Links\*" "C:\Users\$env:username\Desktop\" -recurse

	#Zobrazeni skrytych souboru a slozek, zobrazeni pripon souboru
	write-host "Setting Folder options..." -foregroundcolor green
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -Value "0"
	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Value "1"
		
	#Nastaveni sdileni dokumentu
	$Clients_OS="Windows 7", "Windows 8", "Windows 10"
	foreach ($Client_OS in $Clients_OS)
	{
		if ($Windows_version -like "*$Client_OS*")
		{
			write-host "Detect currently log on user..." -foregroundcolor green
			$User_name=$env:username
			write-host "Currently log on user detected as $User_name" -foregroundcolor green
	
			#Rozhodovani, pod jakym nazvem se dokumenty nasdili, na zaklade jmena aktualne prihlaseneho uzivatele
			write-host "Sharing Documents folder..." -foregroundcolor green
			switch -wildcard ($User_name) 
			{ 
				"StudentCZ" {net share DokumentyCZ=C:\Users\$User_name\Documents '/grant:everyone,full' '/Unlimited'}
				"StudentEN" {net share DocumentsEN=C:\Users\$User_name\Documents '/grant:everyone,full' '/Unlimited'}
				"StudentSK" {net share DokumentySK=C:\Users\$User_name\Documents '/grant:everyone,full' '/Unlimited'}
				"Student" 	{net share Documents=C:\Users\$User_name\Documents '/grant:everyone,full' '/Unlimited'}
			}
			
			#Nastaveni AdminShare
			Write-Host "Setting registry value needed for AdminShare"
			New-ItemProperty -path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value "1" -PropertyType "DWord" >> $null
		}				
	}

	#Rozhodovani, zda se v registru nachazi definice ikon na plose pro aktualni profil, nastaveni defaultnich ikonek na plose pro aktualni profil
	$Desktop_icons_RegistryPath="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
	If (!(Test-Path -path $Desktop_icons_RegistryPath))  
	{
		write-host "Desktop icons registry path not exist..." -foregroundcolor Yellow
		write-host "Creating desktop icons registry path..." -foregroundcolor green
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons" >> $null
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" >> $null
	}
	else
	{
		write-host "Desktop icons registry path already exist..." -foregroundcolor Yellow
	}
	write-host "Setting default desktop icons..." -foregroundcolor green
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' -Value "0"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{59031a47-3f72-44a7-89c5-5595fe6b30ee}' -Value "0"	
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}' -Value "0"	
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}' -Value "0"	
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name '{645FF040-5081-101B-9F08-00AA002F954E}' -Value "0"

	#Rozhodovani, zda se v registru nachazi definice screensaveru pro aktualni profil
	$Screen_Saver_Registry="HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop"
	If (!(Test-Path -path $Screen_Saver_Registry))  
	{
		write-host "Screen saver registry path not exist..." -foregroundcolor Yellow
		write-host "Creating screen saver registry path..." -foregroundcolor green
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Control Panel" >> $null
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop" >> $null
	}
	else
	{
		write-host "Screen saver registry path already exist..." -foregroundcolor Yellow
	}
	write-host "Setting screensaver timeout for 10 minutes..." -foregroundcolor green
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -Name ScreenSaveTimeOut -Value "600"	

	#Rozhodovani, zda se v registru nachazi definice IE pro aktualni profil, nastaveni IE pro aktualni profil
	$InternetExplorer="HKCU:\Software\Policies\Microsoft\Internet Explorer"
	If (!(Test-Path -path $InternetExplorer)) 
	{
		write-host "Internet Explorer registry path not exist..." -foregroundcolor Yellow
		write-host "Creating Internet Explorer registry path..." -foregroundcolor green
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Internet Explorer" >> $null
		New-Item -Path "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" >> $null
	}
	else
	{
		write-host "Internet Explorer registry path already exist..." -foregroundcolor Yellow
	}
	Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" -Name 'DisableFirstRunCustomize' -Value "1" -Type "Dword"	

	#Rozhodovani, zda se v registru nachazi definice TaskBar pro defaultni profil, nastaveni TaskBar pro defaultni profil
	$RegistryKey_Policies="HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies"
	$RegistryKey_Explorer="HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
	If (!(Test-Path -path $RegistryKey_Explorer)) 
	{
		write-host "Action Center registry path not exist..." -foregroundcolor Yellow
		write-host "Creating Action Center registry path..." -foregroundcolor green
		If (!(Test-Path -path $RegistryKey_Policies))
		{
			New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies"
		}
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" >> $null
	}
	else
	{
		write-host "Action Center registry path already exist..." -foregroundcolor Yellow
	}
	write-host "Removing the Action Center icon..." -foregroundcolor green 
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name HideSCAHealth -Value "1" -Type "DWord"

	#Rozhodovani, zda se v registru nachazi definice pozadi na plose pro aktualni profil, nastaveni pozadi na plose pro aktualni profil
	$DesktopBackground="HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
	If (!(Test-Path -path $DesktopBackground)) 
	{
		write-host "Desktop background registry path not exist..." -foregroundcolor Yellow
		write-host "Creating Desktop background registry path..." -foregroundcolor green
		New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" >> $null
	}
	else
	{
		write-host "Desktop background registry path already exist..." -foregroundcolor Yellow
	}
	write-host "Setting $Temp\GOPAS_Background.bmp as desktop background..." -foregroundcolor green 
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name Wallpaper -Value "$Temp\GOPAS_Background.bmp"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name WallpaperStyle -Value "2"
	
	#Nastaveni zobrazovani Language baru
	
	$LanguageBar ="HKCU:\Software\Microsoft\CTF\LangBar"
	if(!(Test-Path -path $LanguageBar))
	{
		Write-Host "Language Bar registry entry does not exists" -foregroundcolor Yellow 
	}	
	else
	{
		Write-Host "Language Bar entry found"
		Write-Host "Setting Language Bar registry property"
		Set-ItemProperty -path "HKCU:\Software\Microsoft\CTF\LangBar" -Name ShowStatus -Value "4" -Type DWORD 
	}
		
	#Odstraneni pouzitych cest v adresnim radku
	write-host "Deleting address bar history..." -foregroundcolor green
	Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths" -Name url*
		
	#Odstraneni historie IE
	#write-host "Deleting IE history..." -foregroundcolor green
	#RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255
	
	#Smazani Explorer MRU
	write-host "Deleting Explorer MRU history..." -foregroundcolor green
	Remove-ITem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Map Network Drive MRU"
		
	#Smazani Run MRU
	write-host "Deleting Run MRU history..." -foregroundcolor green
	Remove-ITem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU"
		
	#Smazani Temp folder u uzivatele
	write-host "Deleting user Temp folder..." -foregroundcolor green
	Get-ChildItem C:\Users\$env:username\AppData\Local\Temp | where {$_.Name -like "*.tmp"} | Remove-Item -Recurse	
		
	#Vypnuti recent a frequently used folders v exploreru (Windows 10)
	if((get-wmiobject win32_operatingsystem).Version -like "10*")
	{
		Set-Itemproperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -name ShowRecent -value 0
		Set-Itemproperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -name ShowFrequent -value 0
	}

	#Restart procesu Explorer.exe z duvodu aplikovani zmen v registrech
	write-host "All settings applied..." -foregroundcolor green
	write-host "Restarting process Explorer.exe for aplying changes ..." -foregroundcolor green
	Stop-Process -processname Explorer
	RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters, 1, true
	write-host "Detecting process Explorer.exe..." -foregroundcolor green
	$Explorer=(Get-Process | where {$_.name -eq "explorer"}).Name
	if ($Explorer -like "explorer") 
	{
		write-host "Process Explorer.exe detected..." -foregroundcolor green
	} 
	else 
	{
		write-host "Process Explorer.exe not detected..." -foregroundcolor Yellow
		write-host "Starting Process Explorer.exe" -foregroundcolor green
		Start-Process explorer.exe
	}			   
	
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 0
	
	#Nastaveni screensaveru - musi byt zde kvuli Multiprofile instalaci (pod uctem StudentEN jinak Screensaver nefunguje)
	write-host "Setting screensaver..." -foregroundcolor green
	regedit /s "C:\Program Files\Screensaver\screensaver.reg"			
	
	if($ServerName -eq "")
	{
		Write-host "Getting Gateway" -ForegroundColor $Global:UserInputColor -BackgroundColor $Global:bgColor
		$gateway=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).DefaultIPGateway
		switch -wildcard ($gateway) 
		{ 
			"10.1.0.1" {$ServerName = "PrahaImage"}
			"10.2.0.1" {$ServerName = "PrahaImage"}
			"10.101.0.1" {$ServerName = "BrnoImage"}
			"10.102.0.1" {$ServerName = "BrnoImage"} 
			"10.201.0.1" {$ServerName = "BlavaImage"}
			"10.202.0.1" {$ServerName = "BlavaImage"}   
			default {$ServerName = ""}
		}
	}
	Write-Host ""
	Write-host "Running Custom Scripts for Branch $ServerName" -ForegroundColor $Global:UserInputColor -BackgroundColor $Global:bgColor 
	switch -wildcard ($ServerName) 
	{ 
		"PrahaImage" 
		{
			write-host "Run Custom Scripts for Praha" -foregroundcolor Yellow
			C:\Windows\System32\WindowsPowerShell\v1.0\powershell -file "D:\Temp\Custom_UserSettings_Praha.ps1"
		}
		"BrnoImage" 
		{
			write-host "Run Custom Scripts for Brno" -foregroundcolor Yellow
			C:\Windows\System32\WindowsPowerShell\v1.0\powershell -file "D:\Temp\Custom_UserSettings_Brno.ps1"
		}
		"BlavaImage" 
		{
			write-host "Run Custom Scripts for Bratislava" -foregroundcolor Yellow
			C:\Windows\System32\WindowsPowerShell\v1.0\powershell -file "D:\Temp\Custom_UserSettings_Blava.ps1"
		}	
		default {}
	}	
	
	#Vytvoreni kontrolni souboru, zda jsou nastaveni aplikovana
	$TempContent = Get-Content $UserSettings
	if(Test-Path $Settings_applied)
	{
		Remove-Item $Settings_applied -force >> $null
	}
	Add-Content $Settings_applied $TempContent	
}

#Vytvoreni odkazu na ostatni PC v ucebne
$DesktopPath = (get-itemproperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders").Desktop
if(!(Test-Path -path C:\Users\$env:username\$DesktopPath\Shares))
{
	if(($env:computername -like "*STUDENT*") -or ($env:computername -like "*LEKTOR*"))
	{
		CreateNetworkShortcuts
	}
}