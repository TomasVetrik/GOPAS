Write-Host "Setting WOL" -ForegroundColor Yellow -BackgroundColor DarkCyan
$Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
cd "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
$dirs = Get-ChildItem $Path -ErrorAction SilentlyContinue
foreach($dir in $dirs){	
    $dir = $dir -replace "HKEY_LOCAL_MACHINE","HKLM:"
	$info = Get-ItemProperty -Path "$dir"
	$prop = (Get-ItemProperty $dir)."*WakeOnMagicPacket"
	Set-ItemProperty -Path $dir -Name "*WakeOnMagicPacket" -Value 1
	Set-ItemProperty -Path $dir -Name "EnablePME" -Value 1
	Set-ItemProperty -Path $dir -Name "ReduceSpeedOnPowerDown" -Value 0
	Set-ItemProperty -Path $dir -Name "WakeON" -Value 6
	# Update 24.10.2014
	Set-ItemProperty -Path $dir -Name "PnPCapabilities" -Value 0
	Set-ItemProperty -Path $dir -Name "WakeOnLink" -Value 2
	Set-ItemProperty -Path $dir -Name "WakeOnPattern" -Value 1
	Set-ItemProperty -Path $dir -Name "SipsEnabled" -Value 0	
	Set-ItemProperty -Path $dir -Name "PnPdwValue" -Value 56
	Set-ItemProperty -Path $dir -Name "ShowNicdwValue" -Value 1	
}
cd C:
powercfg /hibernate off
Write-Host "WOL: OK" -ForegroundColor Green