. D:\Functions.ps1
if(($env:computername -like "*LEKTOR*"))
{
    Start-Sleep 5
    SetDisplayDuplicate
    Set-Autologon 0
    Start-Sleep 5
    New-Item -Path D:\temp\SetDisplayDuplicate.txt -ItemType "file" -Value "DONE"
    logoff
}