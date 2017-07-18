######################################################
#
#SCRIPT_NAME: Rename.ps1
#AUTHOR_NAME: Lukas Keicher
#DATE: 22.6.2015
#VERSION: 3.0
#DESCRIPTION: Skript slouzici pro automaticke pojmenovani pocitace, pokud je operacni system ve VHD
#
######################################################

#Definice promennych
$Temp="D:\Temp"

. $Temp\Functions.ps1

$Test_VHDPath=Test-Path -path D:\Configuration.txt
$Network=gwmi Win32_NetworkAdapterConfiguration | select DNSDomain


#Rozhodovani, zda je system ve VHD - pokud ano, prejmenuje se, pokud ne, neudela nic
if ($Test_VHDPath -eq "true")
{
	write-host "Operating system is in VHD installed..." -foregroundcolor green
	write-host "Renaming OS..." -foregroundcolor Yellow
	RenamePCConfig	
}
else
{
	write-host "Operating system is not in VHD installed..." -foregroundcolor Yellow
	write-host "This PC will be renamed via GHOST..." -foregroundcolor green
}