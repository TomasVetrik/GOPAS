######################################################
#
#SCRIPT_NAME: Map_disc.ps1
#AUTHOR_NAME: Lukas Keicher
#DATE: 15.2.2014
#VERSION: 2.0
#DESCRIPTION: Skript pro mapovani sitoveho disku \\prahaservice\materialy
#
######################################################

# Rozhodovani, zda se pocitac nachazi na siti GOPAS - pokud ano, pripoji \\prahaservice\materialy, pokud ne, disk nepripoji a vypne proxy
$Network=gwmi Win32_NetworkAdapterConfiguration | select DNSDomain
if (($Network -like "*gopas*") -or ($Network -like "*skola*")) 
{
	write-host "Connecting to prahaservice..." -foregroundcolor green
	net use z: \\prahaservice\materialy /user:student '""' /persistent:no
} 
else 
{
	write-host "Disabling proxy server..." -foregroundcolor green
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value "0"
}