######################################################
#
#SCRIPT_NAME: Prepare_Custom_OS.ps1
#AUTHOR_NAME: Lukas Keicher
#DATE: 30.1.2014
#VERSION: 1.0
#DESCRIPTION: Skript zajistujici nakopirovani aktualni verze skriptu Custom_OS.ps1 ze site na lokalni disk
#
######################################################

#Podminka, zda v pocitaci existuje starsi verze skriptu Custom_OS.ps1 a pokud ano, smaze jej
$Test_Custom_OS_Path=Test-Path -path "D:\Custom_OS.ps1"
if ($Test_Custom_OS_Path -eq "true") 
{
	write-host "Previous version of Custom_OS.ps1 detected..." -foregroundcolor Yellow
	write-host "Deleting previous version of Custom_OS.ps1..." -foregroundcolor green
	remove-item "D:\Custom_OS.ps1" -force
} 
else 
{
	write-host "Previous Custom_OS.ps1 not detected..." -foregroundcolor Yellow
}

#Kopirovani aktualni verze skriptu Custom_OS.ps1 ze site na lokalni disk
write-host "Copying Custom_OS.ps1..." -foregroundcolor green
Copy-Item "Z:\Accessories\Custom_OS.ps1" "D:\Custom_OS.ps1"

#Spusteni skriptu Custom_OS.ps1
write-host "Executing Custom_OS.ps1..." -foregroundcolor green
C:\Windows\System32\WindowsPowerShell\v1.0\powershell -file "D:\Custom_OS.ps1"


