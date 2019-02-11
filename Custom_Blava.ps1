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

Write-Host ""
# Nastavi automaticke spustanie Aplikacii na kopirovanie
Write-Host "Setting ANK" -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
SetAnK
