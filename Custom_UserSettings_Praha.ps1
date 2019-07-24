#Definice promennych
$Temp="D:\Temp"

. D:\Functions.ps1

write-host "Changing home page and setting homepage to www.gopas.cz" -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" -Name 'Start Page' -Value "http://www.gopas.cz"
 
Copy-Item "D:\Temp\KopirovaninaStudentskePC.exe" -Destination "C:\Users\$env:username\Desktop\KopirovaninaStudentskePC.exe"

$VideoController = Get-WmiObject -class "Win32_VideoController"
write-host "Setting $Temp\GOPAS_Background.bmp as desktop background..." -foregroundcolor green 
if($VideoController.CurrentHorizontalResolution -eq "2560")
{
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name Wallpaper -Value "$Temp\GOPAS_Background_2560x1080.png"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name WallpaperStyle -Value "2"
}
else
{
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name Wallpaper -Value "$Temp\GOPAS_Background_1920x1080.bmp"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name WallpaperStyle -Value "2"
}

#Nastaveni screensaveru - musi byt zde kvuli Multiprofile instalaci (pod uctem StudentEN jinak Screensaver nefunguje)
write-host "Setting screensaver..." -foregroundcolor green
if($VideoController.CurrentHorizontalResolution -eq "2560")
{
	regedit /s "C:\Program Files\Screensaver\screensaver2560x1080.reg"			
}
else
{
	regedit /s "C:\Program Files\Screensaver\screensaver1920x1080.reg"
}