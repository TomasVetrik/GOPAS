write-host "Changing home page and setting homepage to www.gopas.cz" -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Internet Explorer\Main" -Name 'Start Page' -Value "http://www.gopas.cz"
 
Copy-Item "D:\Temp\Kopírování na studentské PC.exe" -Destination "C:\Users\$env:username\Desktop\Kopírování na studentské PC.exe"
