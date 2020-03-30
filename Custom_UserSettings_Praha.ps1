#Definice promennych
$Temp="D:\Temp"

. D:\Functions.ps1

SaveComputersInfos

CreateRDPShorctus

write-host "Changing home page and setting homepage to www.gopas.cz" -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" -Name 'Start Page' -Value "http://www.gopas.cz"
 
Copy-Item "D:\Temp\KopirovaninaStudentskePC.exe" -Destination "C:\Users\$env:username\Desktop\KopirovaninaStudentskePC.exe"

$VideoController = Get-WmiObject -class "Win32_VideoController"
write-host "Setting $Temp\GOPAS_Background.bmp as desktop background..." -foregroundcolor green 
switch($VideoController.CurrentHorizontalResolution)
{
	"2560"
	{
		$GopasBackgroundPath = "$Temp\GOPAS_Background_2560x1080.png"
		$ScreenSaverRegistryPath = "C:\Program Files\Screensaver\screensaver2560x1080.reg"	
	}
	{@("1920", "1650", "1366", "1280", "1024")}
	{
		$GopasBackgroundPath = "$Temp\GOPAS_Background_1920x1080.bmp"
		$ScreenSaverRegistryPath = "C:\Program Files\Screensaver\screensaver1920x1080.reg"	
	}
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name Wallpaper -Value $GopasBackgroundPath
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name WallpaperStyle -Value "2"

#Nastaveni screensaveru - musi byt zde kvuli Multiprofile instalaci (pod uctem StudentEN jinak Screensaver nefunguje)
write-host "Setting screensaver..." -foregroundcolor green
regedit /s $ScreenSaverRegistryPath

#Disable shutdown button in start menu
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -PropertyType DWORD -Name "NoClose" -Value 1 -Force

