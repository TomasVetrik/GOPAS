#Definice promennych
$Temp="D:\Temp"

. D:\Functions.ps1

SaveComputersInfos

CreateRDPShorctus

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
switch($VideoController.CurrentHorizontalResolution)
{
	"2560"
	{
		$GopasBackgroundPath = "$Temp\GOPAS_Background_2560x1080.png"
	}
	"1920"
	{
		$GopasBackgroundPath = "$Temp\GOPAS_Background_1920x1080.bmp"	
	}
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name Wallpaper -Value $GopasBackgroundPath
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name WallpaperStyle -Value "2"