#Definice promennych
$Temp="D:\Temp"

. D:\Functions.ps1

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
	{@("1920", "1650", "1366", "1280")}
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

#######################################################
#Mapovani plochy prezentacniho computeru v ucebne B921#
#######################################################

$physicalAddresses = Get-WmiObject win32_networkadapterconfiguration | select -ExpandProperty macaddress

#Musi byt zmeneno pri zmene hardwaru
$physicalAddressLector = '00:0E:0C:C5:E5:AE'

if ($physicalAddresses.Contains($physicalAddressLector))
{
    $interfaceAlias = Get-NetAdapterHardwareInfo | Where Bus -eq 0 | Select-Object -ExpandProperty Name

    Write-Host "Setting IP address of the OnBoard NIC to 192.168.0.1 ..." -foregroundcolor green

    New-NetIPAddress -InterfaceAlias $interfaceAlias -IPAddress "192.168.0.1" -PrefixLength 24

    Sleep -s 5

    Write-Host "Mapping Desktop of MiniPC ..." -foregroundcolor green

    cmdkey /add:192.168.0.2 /user:'Student' /pass:'Pa$$w0rd'

    New-SmbMapping -LocalPath L: -RemotePath '\\192.168.0.2\C$\Users\Student\Desktop' -UserName 'Student' -Password 'Pa$$w0rd' -Persistent:1
    
    if(!(Test-Path L:\Prezentace))
    {
        New-Item -Path L:\Prezentace -ItemType directory
    }

    Write-Host "Creating Desktop shortcut for the network drive ..." -foregroundcolor green

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$Home\Desktop\Prezentace.lnk")
    $Shortcut.TargetPath = "\\192.168.0.2\C$\Users\Student\Desktop\Prezentace"
    $Shortcut.Save()
}
