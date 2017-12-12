. D:\Functions.ps1
Run -Path "C:\Windows\System32\control.exe" 'intl.cpl,,/f:"D:\temp\Config_SK.xml"'

Write-Host ""
# Nastavi automaticke spustanie Aplikacii na kopirovanie
Write-Host "Setting ANK" -foreground $Global:UserInputColor -BackgroundColor $Global:bgColor
SetAnK