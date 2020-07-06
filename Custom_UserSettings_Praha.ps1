#Definice promennych
$Temp="D:\Temp"

. D:\Functions.ps1

if(!(Test-Path -Path D:\Temp\Computers))
{
	SaveComputersInfos
}

CreateShadowRDPShortcuts

write-host "Changing home page and setting homepage to www.gopas.cz" -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" -Name 'Start Page' -Value "http://www.gopas.cz"
 
Copy-Item "D:\Temp\KopirovaninaStudentskePC.exe" -Destination "C:\Users\$env:username\Desktop\KopirovaninaStudentskePC.exe"

$VideoController = Get-WmiObject -class "Win32_VideoController"
write-host "Setting $Temp\GOPAS_Background.bmp as desktop background..." -foregroundcolor green 
switch($VideoController.CurrentHorizontalResolution)
{
	"2560"
	{
		$GopasBackgroundPath = "$Temp\GOPAS_Background_2560x1080.jpg"
	}
	default
	{
		$GopasBackgroundPath = "$Temp\GOPAS_Background_1920x1080.jpg"
	}
}

Set-WallPaper $GopasBackgroundPath

#Z nejakeho duvodu mame v imagich nastaveny jako sifrovaci protokol SSL 3.0 a TLS 1.0. Nejake weby ale vyzaduji TLS 1.2. 
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
