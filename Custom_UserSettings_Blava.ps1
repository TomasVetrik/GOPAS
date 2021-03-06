#Definice promennych
$Temp="D:\Temp"

. D:\Functions.ps1

switch -wildcard ($env:USERNAME) 
{ 
    "StudentEN" {$Arguments = 'intl.cpl,,/f:"D:\temp\Config_EN.xml"'}
 	"StudentSK" {$Arguments = 'intl.cpl,,/f:"D:\temp\Config_SK.xml"'}
    "StudentCZ" {$Arguments = 'intl.cpl,,/f:"D:\temp\Config_CZ.xml"'} 
    default {$Arguments = 'intl.cpl,,/f:"D:\temp\Config_SK.xml"'}
}
Write-Host "Setting Regional Settings"
Run -Path "C:\Windows\System32\control.exe" $Arguments

write-host "Changing home page and setting homepage to www.gopas.sk" -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" -Name 'Start Page' -Value "http://www.gopas.sk"

$VideoController = Get-WmiObject -class "Win32_VideoController"
write-host "Setting $Temp\GOPAS_Background.bmp as desktop background..." -foregroundcolor green 
$GopasBackgroundPath = "$Temp\GOPAS_Background_1920x1080.bmp"
switch($VideoController.CurrentHorizontalResolution)
{
	"2560"
	{
		$GopasBackgroundPath = "$Temp\GOPAS_Background_2560x1080.jpg"
	}	
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name Wallpaper -Value $GopasBackgroundPath
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name WallpaperStyle -Value "2"

RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters, 1, true

SaveComputersInfos

CreateShadowRDPShortcuts

Copy-Item "D:\Temp\Chocoi.exe" "C:\Users\Public\Desktop\Chocoi.exe" -force