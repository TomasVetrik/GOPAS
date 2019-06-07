######################################################
#
#SCRIPT_NAME: Branch_detection.ps1
#AUTHOR_NAME: Lukas Keicher
#DATE: 4.3.2014
#VERSION: 2.0
#DESCRIPTION: Skript detekujici pobocku, ve ktere se pocitac nachazi a spusteni prislusnych z dane pobocky - Prepare_Custom_OS.ps1
#
######################################################

#Definice promennych
$Driverpath = "D:\Temp\Drivers\*\Net\"
$ServerName = ""

. D:\Functions.ps1

GhostClientRemove

Function Drivers-Add
{
	write-host "Starting configuration scripts..." -foregroundcolor green
	write-host "Adding NIC drivers to Driverstore" -foregroundcolor green	
    write-host $Driverpath
	AddDrivers $Driverpath		
	write-host "All NIC drivers added to Driverstore..." -foregroundcolor green
}

function wait-for-network($tries = 5, $CounterError = 0)
{
	$Networks = gwmi -class Win32_NetworkAdapterConfiguration `
			-filter DHCPEnabled=TRUE |
					where { $_.DefaultIPGateway -ne $null }

	if (($Networks | measure).count -gt 0 ) 
	{
		return
	}
	if($tries -eq $CounterError)
	{
		Drivers-Add
		return
	}
	$CounterError++;	
	write-host "Waiting for Network" -foregroundcolor Yellow
	start-sleep -s 5
	wait-for-network $tries $CounterError
}

Function ConnectToServer($COUNTER = 0)
{
	if($ServerName -ne "")
	{
		write-host "GOPAS network detected..." -foregroundcolor green
		write-host "Branch detected: $ServerName " -foregroundcolor green
		write-host "Deleting map network shares..." -foregroundcolor Yellow
		net use * /y /d 2>null | Out-Null
		write-host "Connecting to $ServerName ..." -foregroundcolor green
		$out = net use z: \\$ServerName\Startup_OS$ /user:ghostinstall ghostinstall /persistent:no 2>&1
		if ($LASTEXITCODE -ne 0) 
		{
			net use z: \\$ServerName\Startup_OS$  2>null| Out-Null
		}
		if(Test-Path "Z:\")
		{
			write-host "Copying Prepare_Custom_OS.ps1..." -foregroundcolor green
			Copy-Item "Z:\Accessories\Prepare_Custom_OS.ps1" "D:\"
			write-host "Executing Prepare_Custom_OS.ps1..." -foregroundcolor green
			C:\Windows\System32\WindowsPowerShell\v1.0\powershell -file "D:\Prepare_Custom_OS.ps1"	
		}
		else				
		{
			$COUNTER++
			if($COUNTER -eq 5)
			{
				write-host "Not connected $ServerName FAILED..." -ForegroundColor Red
				read-host				
			}
			else
			{
				write-host "Not connected $ServerName Retry..." -ForegroundColor Yellow
				Start-Sleep 5
				ConnectToServer $COUNTER
			}			
		}		
	}
}

#Definice funkce pro pocitac nachazejici, ktery nezdetekoval zadnou sit	
Function No_GOPAS_Network
{
	write-host "No GOPAS network detected..." -foregroundcolor Yellow
	write-host "Using older settings from D:\Custom_OS.ps1..." -foregroundcolor green
	C:\Windows\System32\WindowsPowerShell\v1.0\powershell -file "D:\Custom_OS.ps1"
}

MouseClick(0,0)

# Instalace ovladacu k sitovkam, ktere Windows nativne neznaji
Drivers-Add

wait-for-network

# Spusti explorer, ak nie je spusteni a odklikne action center
RepairACandExplorer

# Detekce pobocky na zaklade vychozi brany. Funguje jak pro ucebnovou, tak privatni sit na kazde podobcce
$gateway=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).DefaultIPGateway
write-host "Gateway $gateway detected..." -foregroundcolor green

#Rozhodovani, jaka funkce pro pobocku bude pouzita na zaklade detekce vychozi brany
switch -wildcard ($gateway) 
{ 
    "10.1.0.1" {$ServerName = "PrahaImage"}
 	"10.2.0.1" {$ServerName = "PrahaImage"}
    "10.101.0.1" {$ServerName = "BrnoImage"}
	"10.102.0.1" {$ServerName = "BrnoImage"} 
    "10.201.0.1" {$ServerName = "BlavaImage"}
	"10.202.0.1" {$ServerName = "BlavaImage"}   
    default {No_GOPAS_Network}
}
ConnectToServer