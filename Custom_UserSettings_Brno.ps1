#Definice promennych
$Temp="D:\Temp"

. D:\Functions.ps1

SaveComputersInfos

CreateShadowRDPShortcuts
write-host "Changing home page and setting homepage to www.gopas.cz" -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" -Name 'Start Page' -Value "http://www.gopas.cz"