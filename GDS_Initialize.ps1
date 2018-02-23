$Temp="D:\Temp"

#smazani ramdisk
bcdedit /delete '{ramdiskoptions}' /f

#vytvoreni nove ramdisk
bcdedit /create '{ramdiskoptions}' /d "Ramdisk options"

bcdedit /set '{ramdiskoptions}' ramdisksdidevice partition=d: 

bcdedit /set '{ramdiskoptions}' ramdisksdipath \Temp\boot.sdi
bcdedit /set '{ramdiskoptions}' description "GDS Initialize" 

#vytvoreni zaznamu pro winpe
bcdedit /create /d "GDS Initialize" /application osloader > $Temp\bcdedit.txt

#vyfiltrovani guid
$guid=Get-Content $Temp\bcdedit.txt
$guid=$guid -replace ".*{", "" -replace "}.*", ""
$guid="{"+"$guid"+"}"

#vytvoreni zaznamu pro GDS_Initialize.wim
cmd /c "Bcdedit /set $guid device ramdisk=[D:]\Temp\GDS_initialize.wim,{ramdiskoptions}"
cmd /c "Bcdedit /set $guid osdevice ramdisk=[D:]\Temp\GDS_initialize.wim,{ramdiskoptions}"

Bcdedit /set $guid path \windows\system32\boot\winload.exe
Bcdedit /set $guid systemroot \windows
Bcdedit /set $guid winpe yes
Bcdedit /set $guid detecthal yes
bcdedit /displayorder $guid /addlast

#write-host "Setting default record in bcd to WinPE with ID $guid..." -foreground green
bcdedit /bootsequence $guid

#write-host "Setting dualboot timeout to 3 seconds..." -foreground green
bcdedit /timeout 3


shutdown -r -t 10 -f -c "Restaring to WinPE"