[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
Function GeneralRebuild($vhd)
{
	If (Test-Path -Path "D:\gateway_detection.bat")
    		{
        		$disk_letter="D"
    		}
	else
    		{
        		$disk_letter="C"
    		}
	write-host -foreground green "Disk $disk_letter detected..."
	if ($disk_letter -eq "D")
			{
				bcdedit /export d:\bcd_backup
				Write-host "Chosen Windows version $vhd..." -foreground green
				#Vytvoreni kontrolni souboru s verzi Windows, na kterou bude PC preinstalovano
				echo "$vhd" > "D:\Desired_VHD.txt"
				if($DelDriveECheckBox.Checked -eq $true){"Yes" | out-file "D:\Desired_VHD.txt" -append}else{"No" | out-file "D:\Desired_VHD.txt" -append}
				if($DelDiffCheckBox.Checked -eq $true ){"Yes" | out-file "D:\Desired_VHD.txt" -append}else{"No" | out-file "D:\Desired_VHD.txt" -append}
				write-host "Creating Desired_VHD..." -foreground green
				
				#smazani ramdisk
				bcdedit /delete '{ramdiskoptions}' /f

				#vytvoreni nove ramdisk
				bcdedit /create '{ramdiskoptions}' /d "Ramdisk options"

				bcdedit /set '{ramdiskoptions}' ramdisksdidevice partition=d: 

				bcdedit /set '{ramdiskoptions}' ramdisksdipath \Temp\boot.sdi
				bcdedit /set '{ramdiskoptions}' description "Global Rebuild" 

				#vytvoreni zaznamu pro winpe
				bcdedit /create /d "Global Rebuild" /application osloader > D:\Temp\bcdedit.txt

				#vyfiltrovani guid
				$guid=Get-Content D:\Temp\bcdedit.txt
				$guid=$guid -replace ".*{", "" -replace "}.*", ""
				$guid="{"+"$guid"+"}"

				#vytvoreni zaznamu pro Global Rebuild.wim
				cmd /c "Bcdedit /set $guid device ramdisk=[D:]\Global_Rebuild_Local.wim,{ramdiskoptions}"
				cmd /c "Bcdedit /set $guid osdevice ramdisk=[D:]\Global_Rebuild_Local.wim,{ramdiskoptions}"

				Bcdedit /set $guid path \windows\system32\boot\winload.exe
				Bcdedit /set $guid systemroot \windows
				Bcdedit /set $guid winpe yes
				Bcdedit /set $guid detecthal yes
				bcdedit /displayorder $guid /remove

				#write-host "Setting default record in bcd to WinPE with ID $guid..." -foreground green
				bcdedit /bootsequence $guid

				#write-host "Setting dualboot timeout to 3 seconds..." -foreground green
				bcdedit /timeout 3			
				
				shutdown -r -t 10 -f -c "Restaring to WinPE"
			}
		else
			{
				bcdedit /import "C:\bcd_backup"
				write-host "Restoring bcd from backup..." -foreground green
				Write-host "Chosen Windows version"$vhd"..." -foreground green
				$path_base = "C:\$vhd"+"_base.vhd"
				$path_diff = "C:\$vhd"+"_diff.vhd"
				$path_diff_bcd = "[C:]\$vhd"+"_diff.vhd"
				write-host "Base vhd for selected Windows version detected in $path_base..." -foreground green
				
				$Desired_VHD = get-content C:\Desired_VHD.txt
				if($Desired_VHD[1] -eq "Yes")
				{
				$diskpartskript = @"
					sel disk 0
					sel par 2
					format fs = ntfs quick override
					exit
"@
					$diskpartskript | diskpart
					Write-Host "Formatting Drive E:\..." -foreground green
					Write-Host ""
				}
				else
				{
					Write-Host "Leaving Drive E:\ alone..." -foreground green
					Write-Host ""
				}
				if($Desired_VHD[2] -eq "Yes")
				{
					#Odstraneni stavajiciho differencniho disku
					if(Test-Path -path $path_diff)
						{
							Remove-Item $path_diff -force
							Write-host "Deleting old differencing disk..." -foregroundcolor green
							Write-Host ""
						}
					#Vytvoreni noveho differencniho disku
					Write-host "Creating new differencing disk for $vhd..." -foregroundcolor green
					Write-Host ""
					$diskpartskript = @"
						create vdisk file=$path_diff parent $path_base
						exit
"@
					$diskpartskript | diskpart
					Write-host "Differencing disk for"$vhd"succesfully created..." -foregroundcolor green
					Write-Host ""
				}
				bcdedit /set '{default}' device vhd=$path_diff_bcd
				bcdedit /set '{default}' osdevice vhd=$path_diff_bcd
				bcdedit /set '{default}' description "$vhd"
				bcdedit /timeout 10
				write-host "Setting dualboot timeout to default values..." -foreground green
				Write-Host ""
				Write-Host "Setting default record in bcd to $path_diff_bcd..." -foregroundcolor green
				Write-Host ""
				Write-Host "Setting description for default record in bcd to $vhd..." -foregroundcolor green
				start-sleep -s 10
				write-host "Deleting Desired_VHD.txt ..." -foreground green
				Remove-Item C:\Desired_VHD.txt -force
				wpeutil reboot
			}
}
If (Test-Path -Path "D:\gateway_detection.bat")
    {
        $disk_letter="D"
    }
else
    {
        $disk_letter="C"
    }
#Zjisteni, zda je na D:\ dostatek mista na rebuild v pripade, ze je na D:\ vice nez 1 VHD
$VHDcount=(get-childItem D:\*.vhd).Count
if(($VHDCount -gt 2) -and ($disk_letter -eq "D")){
	$FreeSpace = ((get-wmiobject win32_logicaldisk) | where {$_.DeviceID -like "D:"}).FreeSpace/1GB
	if($FreeSpace -lt "35"){
		[System.Windows.Forms.MessageBox]::Show("Na D:\ je prilis malo mista pro Rebuild. Pokud jsi tam vytvarel nejake dokumenty, smaz jej prosim. V opacnem pripade kontaktuj technika.","Info", "OK")
		exit
	}
}
write-host "Disk $disk_letter detected..." -foreground green
$txt_path = "$Disk_letter"+":\Desired_VHD.txt"
$Disk_letter = $Disk_letter + ":\"
If (Test-Path -Path $txt_path)
    {
		$vhd = "$disk_letter"+"Desired_VHD.txt"
		$vhd = Get-Content $vhd
		$vhd = $vhd[0]
		Write-host "Chosen VHD version"$vhd"..." -foreground green
		GeneralRebuild($vhd)
    }
elseif(!(Test-Path -Path "$Disk_Letter*_base.vhd"))
    {
        Write-Host "
                    This is not GlobalRebuild image !!!

                    Type 'Y' for restart
                   " -ForegroundColor Red
                   $RestartChoose = read-host
                   if($RestartChoose -eq "Y")
                   {
                        wpeutil reboot
                   }
                   else
                   {
                        write-host "Exiting..."
                        exit
                   }
    }
else
    {
		$MainForm=New-Object System.Windows.Forms.Form
		$MainForm.Text = "Global Windows Rebuild"
		$MainForm.Size = New-Object System.Drawing.Size(500,450) 
		$MainForm.StartPosition = "CenterScreen"

		$objLabel = New-Object System.Windows.Forms.Label
		$objLabel.Size = '400,30'
		$objLabel.Text = "Vyberte verzi Windows, na kterou chcete PC preinstalovat"
		$objLabel.Location = New-Object System.Drawing.Size(5,10)
		$MainForm.Controls.Add($objLabel)
        
        $VHD_counter = 0
        $Position_Counter = 1
        $VHDs = Get-ChildItem $Disk_letter* -include "*_base.vhd"
        foreach($_ in $VHDs)
        {
            [int]$position = $Position_Counter * 45
            $VHD_button = New-Object System.Windows.Forms.Button
            $VHD_button.Name = "VHD_Button$VHD_counter"
            $vhd = $_.BaseName -replace "_base", ""
            $VHD_button.Text = $vhd
            $VHD_button.Location = New-Object System.Drawing.Size(150, $position)
            $VHD_button.Size = '200,20'
            $MainForm.Controls.Add($VHD_button) 
            $VHD_counter++
            $Position_Counter++
        }        
        $VHDObjects = $MainForm.Controls | % {
            $AddClick = $_
            $Name = $_.name
        
        switch($Name)
        {
            "VHD_Button0"
            {
                if($VHD_counter -eq "1")
                {
                    $AddClick.Add_Click({
                        write-host $VHDs
                        $vhd = $VHDs.BaseName
                        $vhd = $vhd -replace "C:", ""
                        $vhd = $vhd -replace "_base",""
                        GeneralRebuild $vhd
                    })
                }
                else
                {
                     $AddClick.Add_Click({
                        write-host $VHDs[0]
                        $vhd = $VHDs[0].BaseName
                        $vhd = $vhd -replace "C:", ""
                        $vhd = $vhd -replace "_base",""
                        GeneralRebuild $vhd
                    })
                }
            }
            "VHD_Button1"
            {
                $AddClick.Add_Click({
                    write-host $VHDs[1]
                    $vhd = $VHDs[1].BaseName
                    $vhd = $vhd -replace "C:", ""
                    $vhd = $vhd -replace "_base",""
                    GeneralRebuild $vhd
                })
            }
            "VHD_Button2"
            {
                $AddClick.Add_Click({
                    write-host $VHDs[2]
                    $vhd = $VHDs[2].BaseName
                    $vhd = $vhd -replace "C:", ""
                    $vhd = $vhd -replace "_base",""
                    GeneralRebuild $vhd
                })
            }
            "VHD_Button3"
            {
                $AddClick.Add_Click({
                    write-host $VHDs[3]
                    $vhd = $VHDs[3].BaseName
                    $vhd = $vhd -replace "C:", ""
                    $vhd = $vhd -replace "_base",""
                    GeneralRebuild $vhd
                })
            }
            "VHD_Button4"
            {
                $AddClick.Add_Click({
                    write-host $VHDs[4]
                    $vhd = $VHDs[4].BaseName
                    $vhd = $vhd -replace "C:", ""
                    $vhd = $vhd -replace "_base",""
                    GeneralRebuild $vhd
                })
            }
            "VHD_Button5"
            {
                $AddClick.Add_Click({
                    write-host $VHDs[5]
                    $vhd = $VHDs[5].BaseName
                    $vhd = $vhd -replace "C:", ""
                    $vhd = $vhd -replace "_base",""
                    GeneralRebuild $vhd
                })
            }
			"VHD_Button6"
            {
                $AddClick.Add_Click({
                    write-host $VHDs[6]
                    $vhd = $VHDs[6].BaseName
                    $vhd = $vhd -replace "C:", ""
                    $vhd = $vhd -replace "_base",""
                    GeneralRebuild $vhd
                })
            }
			"VHD_Button7"
            {
                $AddClick.Add_Click({
                    write-host $VHDs[7]
                    $vhd = $VHDs[7].BaseName
                    $vhd = $vhd -replace "C:", ""
                    $vhd = $vhd -replace "_base",""
                    GeneralRebuild $vhd
                })
            }
			"VHD_Button8"
            {
                $AddClick.Add_Click({
                    write-host $VHDs[8]
                    $vhd = $VHDs[8].BaseName
                    $vhd = $vhd -replace "C:", ""
                    $vhd = $vhd -replace "_base",""
                    GeneralRebuild $vhd
                })
            }
			"VHD_Button9"
            {
                $AddClick.Add_Click({
                    write-host $VHDs[9]
                    $vhd = $VHDs[9].BaseName
                    $vhd = $vhd -replace "C:", ""
                    $vhd = $vhd -replace "_base",""
                    GeneralRebuild $vhd
                })
            }
			"VHD_Button10"
            {
                $AddClick.Add_Click({
                    write-host $VHDs[10]
                    $vhd = $VHDs[10].BaseName
                    $vhd = $vhd -replace "C:", ""
                    $vhd = $vhd -replace "_base",""
                    GeneralRebuild $vhd
                })
            }
        }  
        }
		$CMD_button = New-Object Windows.Forms.Button
		$CMD_button.Location = New-Object System.Drawing.Size(150,225)
		$CMD_button.Size = New-Object System.Drawing.Size(200,20)
		$CMD_button.Text = "CMD"
		$CMD_button.Add_Click({start cmd.exe})
		$MainForm.Controls.Add($CMD_button)

		$Restart_button = New-Object Windows.Forms.Button
		$Restart_button.Location = New-Object System.Drawing.Size(150,260)
		$Restart_button.Size = New-Object System.Drawing.Size(200,20)
		$Restart_button.Text = "Restart"
		$Restart_button.Add_Click({wpeutil reboot})
		$MainForm.Controls.Add($Restart_button)
		
		$DelDriveECheckBox = New-Object Windows.Forms.CheckBox
		$DelDriveECheckBox.Location = New-Object System.Drawing.Size(20,30)
		$DelDriveECheckBox.Size = New-Object System.Drawing.Size(125,50)
		$DelDriveECheckBox.Text = "Mam formatovat E:\?"
		$DelDriveECheckBox.Checked = $True
		$MainForm.Controls.Add($DelDriveECheckBox)
		
		$DelDiffCheckBox = New-Object Windows.Forms.CheckBox
		$DelDiffCheckBox.Location = New-Object System.Drawing.Size(20,75)
		$DelDiffCheckBox.Size = New-Object System.Drawing.Size(125,50)
		$DelDiffCheckBox.Text = "Mam smazat puvodni a vytvorit novy diff?"
		$DelDiffCheckBox.Checked = $True
		$MainForm.Controls.Add($DelDiffCheckBox)
		
		$MainForm.ShowDialog()
	}