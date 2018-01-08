######################################################
#
#SCRIPT_NAME: Drivers.ps1
#AUTHOR_NAME: Lukas Keicher, Tomas Vetrik
#DATE: 13.02.2017
#VERSION: 6.0
#DESCRIPTION: Skript slouzici pro instalaci ovladacu
#
######################################################

#Definice promennych
$Temp="D:\Temp"
. $Temp\Functions.ps1
$MacAddress=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).MACAddress
if($Motherboard -eq $null)
{
	$Motherboard = $Global:HWModel
}

$Windows_version=wmic os get name
$Bit_version=(Get-WMIObject win32_operatingsystem).osarchitecture
$Network=gwmi Win32_NetworkAdapterConfiguration | select DNSDomain
#Zjisteni bitove verze OS
if ($Bit_version -like "*32*") 
{
	$Bit_version="x86"
} 
else 
{
	$Bit_version="x64"
}
write-host "$Bit_version bit version detected..." -foregroundcolor green
$OS = Get-OSAbrivation

$Driverpath="D:\Temp\Drivers\$OS"
$Test_DriverPath=Test-Path -path $Driverpath
#Rozhodavni, zda se pocitac nachazi na siti GOPAS - pokud ano, smaze predchozi verzi ovladacu, pokud ne, pouzije drive stazene ovladace
if (($Network -like "*gopas*") -or ($Network -like "*skola*")) 
{
	DetectMapNetworkShares
	
	write-host "GOPAS network detected..." -foregroundcolor green
	if(Test-Path "Z:\Drivers")
	{
		if ($Test_DriverPath -eq "true") 
		{					
			write-host "Nothing to delete from $Driverpath" -ForegroundColor Yellow
		} 
		else 
		{
			write-host "$OS OS detected..." -ForegroundColor Green
			write-host "$Motherboard motherboard detected..." -ForegroundColor Green		
			write-host "Copying new drivers from \\$ServerName\Drivers\$OS\$Motherboard\" -foregroundcolor Yellow
			Copy-With-ProgressBar "Z:\Drivers\$OS\$Motherboard\" $Driverpath
			write-host "Copying drivers - DONE" -ForegroundColor Green	
		}		
	}				
	write-host "Adding drivers to Driverstore" -foregroundcolor Yellow		
	AddDrivers -Driverpath $Driverpath
	write-host "All drivers added to Driverstore" -foregroundcolor green
	write-host "Cleaning footprints" -foregroundcolor Yellow			
}
else
{
	write-host "No GOPAS network detected..." -foregroundcolor Yellow
	write-host "No drivers will be deleted from $Driverpath" -foregroundcolor Yellow	
	write-host "Adding drivers to DriverStore" -foregroundcolor Yellow		
	AddDrivers -Driverpath $Driverpath
	write-host "All drivers added to Driverstore" -foregroundcolor green
}	
