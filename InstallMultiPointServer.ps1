if(Test-Path D:\Temp\MultiPointManagerAlreadyInstalled.txt)
{
	write-host "MultiPoint already configure, exiting!" -foregroundcolor red
	Exit
}

function GetUserLogon
{
	switch -wildcard (Get-LocalUser | where {$_.Enabled -eq $True})
	{
		"Administrator"
		{
			$Login = 'Administrator'
			$Password = 'Pa$$w0rd'
		}
		"Student*"
		{
			$Login = 'StudentCZ'
		}
		"Student"
		{
			$Login = 'Student'
			$Password = 'Pa$$w0rd'
		}
	}
	$Login = New-Object -TypeName psobject -Property @{
                Login = $Login
				Password = $Password
            }
	return $Login
}

if((Get-WindowsOptionalFeature -Online -FeatureName "Multipoint-Connector").State -ne "Enabled")
{
	#Lector
	write-host "Enabling MultiPoint-Connector..." -ForegroundColor Green
	Enable-WindowsOptionalFeature -Online -FeatureName "Multipoint-Connector" -NoRestart -All
	
	$Login = GetUserLogon
	
	#Nastaveni scriptu do registru po spusteni
	write-host "Setting autologon..." -ForegroundColor Green
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" -Name InstallMultiPoint -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell D:\Temp\InstallMultiPointServer.ps1"
	
	#Zapnuti automatickeho prihlasovani
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -Value "1"
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -Value $Login.Password
	Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -Value $Login.Login

	write-host "Restarting computer..." -ForegroundColor Green
	pause
	start-sleep -s 5
	Restart-Computer -force
}

net stop wms
net start wms

$IPAddresses = New-Object System.Collections.ArrayList
$ComputerName = New-Object System.Collections.ArrayList
Get-childitem D:\Temp\Computers\STUDENT*my | % {
	[xml]$XMLFile = Get-Content $_.FullName
	$IPAddress = $XMLFile.ComputerDetailsData.IPAddress
	$Name = $XMLFile.ComputerDetailsData.Name
	$IPAddresses.Add($IPAddress) > $null
	$ComputerName.Add($Name) > $null
}

write-host "Enabling MultiPoint-Connector-Services on classroom computers..." -ForegroundColor Green
Invoke-Command -ScriptBlock {Enable-WindowsOptionalFeature -FeatureName "MultiPoint-Connector-Services" -All -Online -NoRestart} -ComputerName $IPAddresses
write-host "Restarting classroom computers..." -ForegroundColor Green
Restart-Computer -ComputerName $IPAddresses -Force -Wait 

$Login = GetUserLogon

# Add computers to inventory
$pass = ConvertTo-SecureString -String ($Login.Password) -AsPlainText -Force
$cred = [pscredential]::new(($Login.Login), $pass)
Add-WmsSystem -ComputerName $ComputerName -ManagedSystemsType PersonalComputers -Credential $cred

foreach($computer in $ComputerName)
{
Set-WmsSystem -Server $computer `
              -SuppressPrivacyNotification $true `
              -AdminOrchestration $true `
              -DesktopMonitoring $true `
       	      -IM $true
}

# Reboot All Computers
Restart-Computer -ComputerName $IPAddresses -Force -Wait

# List connected computers
Get-WmsSystem | Select-Object -ExpandProperty ManagedServers

Out-File D:\Temp\MultiPointManagerAlreadyInstalled.txt -force