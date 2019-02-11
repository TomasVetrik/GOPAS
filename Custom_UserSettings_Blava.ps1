. D:\Functions.ps1

switch -wildcard ($env:USERNAME) 
{ 
    "StudentEN" {$Arguments = 'intl.cpl,,/f:"D:\temp\Config_EN.xml"'}
 	"StudentSK" {$Arguments = 'intl.cpl,,/f:"D:\temp\Config_SK.xml"'}
    "StudentCZ" {$Arguments = 'intl.cpl,,/f:"D:\temp\Config_CZ.xml"'} 
    default {$Arguments = 'intl.cpl,,/f:"D:\temp\Config_SK.xml"'}
}
Write-Host "Setting Regional Settings"
Run -Path "C:\Windows\System32\control.exe" $Arguments

write-host "Changing home page and setting homepage to www.gopas.sk" -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" -Name 'Start Page' -Value "http://www.gopas.sk"