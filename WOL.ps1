Write-Host "Setting WOL" -ForegroundColor Yellow -BackgroundColor DarkCyan
$Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
cd "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
$dirs = Get-ChildItem $Path -ErrorAction SilentlyContinue
foreach($dir in $dirs){	
    $dir = $dir -replace "HKEY_LOCAL_MACHINE","HKLM:"
	$info = Get-ItemProperty -Path "$dir"
	$prop = (Get-ItemProperty $dir)."*WakeOnMagicPacket"
	Set-ItemProperty -Path $dir -Name "*WakeOnMagicPacket" -Value 1 -Type "String"
	Set-ItemProperty -Path $dir -Name "EnablePME" -Value 1 -Type "String"
	Set-ItemProperty -Path $dir -Name "ReduceSpeedOnPowerDown" -Value 0 -Type "String"
	Set-ItemProperty -Path $dir -Name "WakeON" -Value 6 -Type "String"
	# Update 24.10.2014
	Set-ItemProperty -Path $dir -Name "PnPCapabilities" -Value 0 -Type "Dword"
	Set-ItemProperty -Path $dir -Name "WakeOnLink" -Value 2 -Type "String"
	Set-ItemProperty -Path $dir -Name "WakeOnPattern" -Value 1 -Type "String"
	Set-ItemProperty -Path $dir -Name "SipsEnabled" -Value 0 -Type "String"
	Set-ItemProperty -Path $dir -Name "PnPdwValue" -Value 56 -Type "Dword"
	Set-ItemProperty -Path $dir -Name "ShowNicdwValue" -Value 1	-Type "String"
}
$Path = "HKLM:\SYSTEM\ControlSet001\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
cd "HKLM:\SYSTEM\ControlSet001\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
$dirs = Get-ChildItem $Path -ErrorAction SilentlyContinue
foreach($dir in $dirs){	
    $dir = $dir -replace "HKEY_LOCAL_MACHINE","HKLM:"
	$info = Get-ItemProperty -Path "$dir"
	$prop = (Get-ItemProperty $dir)."*WakeOnMagicPacket"
	Set-ItemProperty -Path $dir -Name "*WakeOnMagicPacket" -Value 1 -Type "String"
	Set-ItemProperty -Path $dir -Name "EnablePME" -Value 1 -Type "String"
	Set-ItemProperty -Path $dir -Name "ReduceSpeedOnPowerDown" -Value 0 -Type "String"
	Set-ItemProperty -Path $dir -Name "WakeON" -Value 6 -Type "String"
	# Update 24.10.2014
	Set-ItemProperty -Path $dir -Name "PnPCapabilities" -Value 0 -Type "Dword"
	Set-ItemProperty -Path $dir -Name "WakeOnLink" -Value 2 -Type "String"
	Set-ItemProperty -Path $dir -Name "WakeOnPattern" -Value 1 -Type "String"
	Set-ItemProperty -Path $dir -Name "SipsEnabled" -Value 0 -Type "String"
	Set-ItemProperty -Path $dir -Name "PnPdwValue" -Value 56 -Type "Dword"
	Set-ItemProperty -Path $dir -Name "ShowNicdwValue" -Value 1	-Type "String"
}
cd C:
If ((gwmi win32_operatingsystem).caption -match "Windows 8")
{
    powercfg -h off
}

$TurnOffDevice = $true
$WakeComputer = $true
$AllowMagicPacketsOnly = $true

function Get-PhysicalNICs {	
	[CmdletBinding()]
	param ()
	$NICs = Get-WmiObject Win32_NetworkAdapter -filter "AdapterTypeID = '0' `
	AND PhysicalAdapter = 'true' `
	AND NOT Description LIKE '%Centrino%' `
	AND NOT Description LIKE '%wireless%' `
	AND NOT Description LIKE '%virtual%' `
	AND NOT Description LIKE '%WiFi%' `
	AND NOT Description LIKE '%Bluetooth%'"
	Return $NICs
}

function Set-NICPowerManagement {	
	[CmdletBinding()]
	param
	(
		$NICs
	)
	
	foreach ($NIC in $NICs) {
		#Write-Host "NIC:"$NIC.Name
		#Write-Host "Allow the computer to turn off this device....." -NoNewline
		$NICPowerManage = Get-WmiObject MSPower_DeviceEnable -Namespace root\wmi | Where-Object { $_.instancename -match [regex]::escape($nic.PNPDeviceID) }
		If ($NICPowerManage.Enable -ne $TurnOffDevice) {
			$NICPowerManage.Enable = $TurnOffDevice
			$HideOutput = $NICPowerManage.psbase.Put()
		}
		If ($NICPowerManage.Enable -eq $TurnOffDevice) {
			#Write-Host "Success" -ForegroundColor Yellow
		} else {
			#Write-Host "Failed" -ForegroundColor Red
		}
		#Write-Host "Allow this device to wake the computer....." -NoNewline
		$NICPowerManage = Get-WmiObject MSPower_DeviceWakeEnable -Namespace root\wmi | Where-Object { $_.instancename -match [regex]::escape($nic.PNPDeviceID) }
		If ($NICPowerManage.Enable -ne $WakeComputer) {
			$NICPowerManage.Enable = $WakeComputer
			$HideOutput = $NICPowerManage.psbase.Put()
		}
		If ($NICPowerManage.Enable -eq $WakeComputer) {
			#Write-Host "Success" -ForegroundColor Yellow
		} else {
			#Write-Host "Failed" -ForegroundColor Red
		}
		#Write-Host "Only allow a magic packet to wake the computer....." -NoNewline
		$NICPowerManage = Get-WmiObject MSNdis_DeviceWakeOnMagicPacketOnly -Namespace root\wmi | Where-Object { $_.instancename -match [regex]::escape($nic.PNPDeviceID) }
		If ($NICPowerManage.EnableWakeOnMagicPacketOnly -ne $AllowMagicPacketsOnly) {
			$NICPowerManage.EnableWakeOnMagicPacketOnly = $AllowMagicPacketsOnly
			$HideOutput = $NICPowerManage.psbase.Put()
		}
		If ($NICPowerManage.EnableWakeOnMagicPacketOnly -eq $AllowMagicPacketsOnly) {
			#Write-Host "Success" -ForegroundColor Yellow
		} else {
			#Write-Host "Failed" -ForegroundColor Red
		}
	}
}

If ((gwmi win32_operatingsystem).caption -match "Windows 10")
{
    powercfg -h off
    $PhysicalNICs = Get-PhysicalNICs
    Set-NICPowerManagement -NICs $PhysicalNICs	
	$FindHiberbootEnabled = Get-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Control\Session?Manager\Power" -ErrorAction SilentlyContinue
    If ($FindHiberbootEnabled.HiberbootEnabled -eq 1)
    {
        Set-ItemProperty -Path $FindHiberbootEnabled.PSPath -Name "HiberbootEnabled" -Value 0 -type DWORD -Force | Out-Null
    }
    Else
    {
        #Write-Host "HiberbootEnabled is already DISABLED"
    }	
}

$FindEEELinkAd = Get-ChildItem "hklm:\SYSTEM\ControlSet001\Control\Class" -Recurse -ErrorAction SilentlyContinue | % {Get-ItemProperty $_.pspath} -ErrorAction SilentlyContinue | ? {$_.EEELinkAdvertisement} -ErrorAction SilentlyContinue
If ($FindEEELinkAd.EEELinkAdvertisement -eq 1)
{
    Set-ItemProperty -Path $FindEEELinkAd.PSPath -Name EEELinkAdvertisement -Value 0    
    $FindEEELinkAd = Get-ChildItem "hklm:\SYSTEM\ControlSet001\Control\Class" -Recurse -ErrorAction SilentlyContinue | % {Get-ItemProperty $_.pspath} | ? {$_.EEELinkAdvertisement}
    If ($FindEEELinkAd.EEELinkAdvertisement -eq 1)
    {
        #write-output "$($env:computername) - ERROR - EEELinkAdvertisement set to $($FindEEELinkAd.EEELinkAdvertisement)"
    }
    Else
    {
       #write-output "$($env:computername) - SUCCESS - EEELinkAdvertisement set to $($FindEEELinkAd.EEELinkAdvertisement)"
    }
}
Else
{
    #Write-Host "EEELinkAdvertisement is already turned OFF"
}
Write-Host "WOL: OK" -ForegroundColor Green