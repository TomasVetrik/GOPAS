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
				Write-host "Chosen Windows version $vhd..." -foreground green
				#Vytvoreni kontrolni souboru s verzi Windows, na kterou bude PC preinstalovano
				echo "$vhd" > "D:\Desired_VHD.txt"
				write-host "Creating Desired_VHD..." -foreground green
				
				Write-Host "Searching in bcd for local version of WinPE..." -foreground green
				
				$Objects = bcdedit /enum
				foreach($Object in $Objects)
					{
						if (($Object -like "identifier*") -or ($Object -like "identifikátor*") )
							{
								$ID = $Object
							}
					}
					if($ID -like "identifier*")
					{
						$ID = $ID.replace(' ','')
						$ID = $ID.replace("identifier",'')
					}	
                	if($ID -like "identifikátor*")
					{
						$ID = $ID.replace(' ','')
						$ID = $ID.replace("identifikátor",'')
					}
				write-host "Setting default record in bcd to WinPE with ID $ID..." -foreground green
				bcdedit /default $ID
				write-host "Setting dualboot timeout to 3 seconds..." -foreground green
				bcdedit /timeout 3
				shutdown -r -t 10 -f -c "Restaring to WinPE"
			}
		else
			{
				if(Test-Path -path "w:\*")
				{
					#Kopirovani Password.txt pro pozdejsi uziti
					Copy-Item "w:\Deployment\Accessories\Password.txt" "C:\Password.txt" -force
					#Pokud se nejedna o lokalni rebuild, tak jeste promaze velkej _LOG
					$MacAddress=(Get-WmiObject win32_NetworkAdapterConfiguration | where {($_.dnsdomain -like "*skola*") -or ($_.dnsdomain -like "*gopas*")}).MACAddress
					$Database=(import-csv -path "w:\deployment\Database.csv" | where {$_.mac1 -eq $MacAddress -or $_.mac2 -eq $MacAddress})
					$Ucebna=($Database).Ucebna
					$Student=($Database).Office
					$LogName = $Student + "_LOG.txt"
					Clear-Content -path "w:\Deployment\Classroom\$Ucebna\$LogName"
				}
				else
				{
					Copy-Item "x:\Windows\System32\Password.txt" "C:\Password.txt" -force
				}
				bcdedit /import "C:\bcd_backup"
				write-host "Restoring bcd from backup..." -foreground green
				Write-host "Chosen Windows version"$vhd"..." -foreground green
				$path_base = "C:\$vhd"+"_base.vhd"
				$path_diff = "C:\$vhd"+"_diff.vhd"
				$path_diff_bcd = "[C:]\$vhd"+"_diff.vhd"
				write-host "Base vhd for selected Windows version detected in $path_base..." -foreground green
				#Odstraneni stavajiciho differencniho disku
				if(Test-Path -path "C:\*_diff.vhd")
					{
						Remove-Item "C:\*_diff.vhd"
						Write-host "Deleting old differencing disks..." -foregroundcolor green
						Write-Host ""
					}
				else
					{
						Write-Host "Old differencing disks not detected..." -foregroundcolor magenta
						Write-Host ""
					}
				#Vytvoreni noveho differencniho disku
				Write-host "Creating new differencing disk for $vhd..." -foregroundcolor green
				Write-Host ""
$diskpartskript = @"
			create vdisk file=$path_diff parent $path_base
			sel disk 0
			sel par 2
			format fs = ntfs quick override
			exit
"@
		$diskpartskript | diskpart
				Write-host "Differencing disk for"$vhd"succesfully created..." -foregroundcolor green
				Write-Host ""
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
write-host "Disk $disk_letter detected..." -foreground green
$txt_path = "$Disk_letter"+":\Desired_VHD.txt"
$Disk_letter = $Disk_letter + ":\"
If (Test-Path -Path $txt_path)
    {
		$vhd = "$disk_letter"+"Desired_VHD.txt"
		$vhd = Get-Content $vhd
		Write-host "Chosen VHD version"$vhd"..." -foreground green
		Remove-Item $txt_path
		write-host "Deleting Desired_VHD.txt ..." -foreground green
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
		$MainForm.ShowDialog()
	}