######################################################
#
#SCRIPT_NAME: Map_disc.ps1
#AUTHOR_NAME: Lukas Keicher
#DATE: 15.2.2014
#UPDATE: 9.10.2017 | Tomáš Vetrík
#VERSION: 3.0
#DESCRIPTION: Skript pro mapovani sitoveho disku \\$ServerName\materialy
#
######################################################

# Rozhodovani, zda se pocitac nachazi na siti GOPAS - pokud ano, pripoji \\$ServerName\materialy, pokud ne, disk nepripoji a vypne proxy
$gateway=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).DefaultIPGateway
write-host "Gateway $gateway detected..." -foregroundcolor green
switch -wildcard ($gateway) 
{ 
	"10.1.0.1" {$ServerName = "prahaservice"}
	"10.2.0.1" {$ServerName = "prahaservice"}
	"10.101.0.1" {$ServerName = ""}
	"10.102.0.1" {$ServerName = ""} 
	"10.201.0.1" {$ServerName = "blavaservice"}
	"10.202.0.1" {$ServerName = "blavaservice"}   
	default 
	{
		$ServerName = ""
		write-host "Disabling proxy server..." -foregroundcolor green
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name ProxyEnable -Value "0"
	}
}
if($ServerName -ne "")
{		
	write-host "Connecting to $ServerName..." -foregroundcolor green
	net use z: \\$ServerName\materialy /user:student '""' /persistent:no
}