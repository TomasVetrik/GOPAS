######################################################
#
#SCRIPT_NAME: Prepare_UserSettings.ps1
#AUTHOR_NAME: Lukas Keicher
#DATE: 22.6.2015
#VERSION: 1.0
#DESCRIPTION: Skript, ktery detekuje aktualne prihlaseneho uzivatele (v pripade profilu vytvoreneho GOPASem, profil nastavi dle nasich hodnot)
#
######################################################

#Definice promennych
$Temp="D:\Temp"

. D:\Functions.ps1

$profile=$env:USERNAME
$users="Student", "StudentCZ", "StudentEN", "StudentSK", "Administrator", "Profile", "ECDL_CZ", "ECDL_SK", "ECDL_EN"

Proxy-OFF

if ($users -match $profile)
{
	Write-Host "User $profile detected..." -ForegroundColor Green
	Write-Host "GOPAS Profile detected..." -ForegroundColor Green
	Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-file $Temp\UserSettings.ps1" -Verb RunAs -WindowStyle Hidden
	Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-file $Temp\Map_disc.ps1"	-Verb RunAs -WindowStyle Hidden
	Save-Current-Logon-User
}
else
{
	Write-Host "User $profile detected..." -ForegroundColor Yellow
	Write-Host "Strange Profile detected..." -ForegroundColor Yellow
}

if(!(Test-Path "D:\Temp\SetDisplayDuplicate.txt") -and ($env:computername -like "*LEKTOR*"))
{	
    Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "-file $Temp\SetDisplayDuplicate.ps1" -Verb RunAs -WindowStyle Hidden	
}
